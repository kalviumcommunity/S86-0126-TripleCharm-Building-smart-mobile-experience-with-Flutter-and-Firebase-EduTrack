import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/constants.dart';
import 'database_service.dart';

/// Firebase Authentication Service
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get auth state changes stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ===== AUTHENTICATION OPERATIONS =====

  /// Sign up with email and password
  static Future<String> signUp({
    required String name,
    required String email,
    required String password,
    required String role, // 'teacher' or 'student'
    String? phone,
  }) async {
    try {
      if (kDebugMode) {
        print('📝 [AUTH SERVICE] Sign up initiated');
        print('   Name: $name');
        print('   Email: $email');
        print('   Role: $role');
        print('   Phone: ${phone ?? "null"}');
      }
      
      // Validate inputs
      if (name.isEmpty || name.length < AppConstants.minNameLength) {
        throw FirebaseAuthException(
          code: 'invalid-name',
          message: 'Name must be at least ${AppConstants.minNameLength} characters.',
        );
      }

      if (password.length < AppConstants.minPasswordLength) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Password must be at least ${AppConstants.minPasswordLength} characters.',
        );
      }

      // Create Firebase Auth user
      if (kDebugMode) print('📝 [AUTH SERVICE] Creating Firebase Auth user...');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;
      if (kDebugMode) print('📝 [AUTH SERVICE] Firebase Auth user created with UID: $userId');

      // Wait briefly to ensure auth token is fully propagated
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Force refresh the auth token to ensure it's valid
      await userCredential.user!.reload();
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Auth user not found after creation');
      }

      // Create user document in Firestore
      if (kDebugMode) print('📝 [AUTH SERVICE] Creating Firestore user document...');
      
      try {
        await DatabaseService.createUser(
          userId: userId,
          name: name,
          email: email,
          role: role,
          phone: phone,
        );
        if (kDebugMode) print('✅ [AUTH SERVICE] Firestore user document created successfully');
      } catch (firestoreError) {
        if (kDebugMode) {
          print('❌ [AUTH SERVICE] Failed to create Firestore user document: $firestoreError');
          print('⚠️ [AUTH SERVICE] Cleaning up Firebase Auth user...');
        }
        
        // If Firestore document creation fails, delete the auth user
        try {
          await userCredential.user!.delete();
          if (kDebugMode) print('🗑️ [AUTH SERVICE] Firebase Auth user deleted');
        } catch (deleteError) {
          if (kDebugMode) print('❌ [AUTH SERVICE] Failed to delete auth user: $deleteError');
        }
        
        throw Exception('Failed to create user account. Please try again. Error: $firestoreError');
      }

      if (kDebugMode) print('✅ [AUTH SERVICE] Sign up completed successfully!');
      return userId;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('❌ [AUTH SERVICE] FirebaseAuthException: ${e.code} - ${e.message}');
      throw FirebaseAuthException(
        code: e.code,
        message: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      if (kDebugMode) print('❌ [AUTH SERVICE] Unexpected error during signup: $e');
      rethrow;
    }
  }

  /// Login with email and password
  static Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) print('🔐 [AUTH SERVICE] Login initiated for: $email');
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;
      if (kDebugMode) print('🔐 [AUTH SERVICE] Login successful, UID: $userId');
      
      // Wait briefly to ensure auth token is fully propagated
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Refresh the auth token
      await userCredential.user!.reload();

      // Try to update last login, but don't fail if it times out
      try {
        await DatabaseService.updateUser(
          userId,
          {'lastLogin': DateTime.now().toIso8601String()},
        ).timeout(const Duration(seconds: 5));
        if (kDebugMode) print('✅ [AUTH SERVICE] Last login updated');
      } catch (e) {
        // Non-critical error - just log it
        if (kDebugMode) print('⚠️ [AUTH SERVICE] Could not update last login: $e');
      }

      return userId;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: _getAuthErrorMessage(e.code),
      );
    }
  }

  /// Logout
  static Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Alias for login (for compatibility)
  static Future<String> signIn({
    required String email,
    required String password,
  }) async {
    return await login(email: email, password: password);
  }

  /// Alias for logout (for compatibility)
  static Future<void> signOut() async {
    return await logout();
  }

  /// Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: _getAuthErrorMessage(e.code),
      );
    }
  }

  /// Update email
  static Future<void> updateEmail(String newEmail) async {
    try {
      if (currentUser == null) throw Exception('No user currently logged in');
      await currentUser!.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      rethrow;
    }
  }

  /// Update password
  static Future<void> updatePassword(String newPassword) async {
    try {
      if (currentUser == null) throw Exception('No user currently logged in');
      await currentUser!.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete account
  static Future<void> deleteAccount() async {
    try {
      if (currentUser == null) throw Exception('No user currently logged in');
      await currentUser!.delete();
    } catch (e) {
      rethrow;
    }
  }

  // ===== HELPER METHODS =====

  /// Get user-friendly error message for Firebase Auth exceptions
  static String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return AppConstants.errorInvalidEmail;
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return AppConstants.errorUserNotFound;
      case 'wrong-password':
        return AppConstants.errorWrongPassword;
      case 'email-already-in-use':
        return AppConstants.errorEmailExists;
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'weak-password':
        return AppConstants.errorWeakPassword;
      case 'too-many-requests':
        return AppConstants.errorTooManyAttempts;
      case 'invalid-name':
        return 'Please enter a valid name.';
      default:
        return 'An authentication error occurred. Please try again.';
    }
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  static bool isStrongPassword(String password) {
    return password.length >= AppConstants.minPasswordLength;
  }
}
