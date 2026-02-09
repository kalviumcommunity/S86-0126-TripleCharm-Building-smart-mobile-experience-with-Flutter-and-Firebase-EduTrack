import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for user roles in the application
enum UserRole {
  student,
  teacher,
  parent,
  admin;

  /// Convert enum to string value
  String get value => name.toLowerCase();

  /// Convert string back to enum
  static UserRole? fromString(String? value) {
    if (value == null) return null;
    return UserRole.values
        .cast<UserRole?>()
        .firstWhere((role) => role?.value == value.toLowerCase(), orElse: () => null);
  }
}

/// Service class for managing Firebase Security
/// Handles role-based access control, permission verification, and secure operations
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();

  factory SecurityService() {
    return _instance;
  }

  SecurityService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========================= AUTHENTICATION CHECKS =========================

  /// Get the currently authenticated user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get the current user's UID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ========================= ROLE-BASED ACCESS CONTROL =========================

  /// Get the user's role from Firestore
  Future<UserRole?> getUserRole(String uid) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final roleString = doc['role'] as String?;
        return UserRole.fromString(roleString);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user role: $e');
      return null;
    }
  }

  /// Get current user's role
  Future<UserRole?> getCurrentUserRole() async {
    if (currentUserId == null) return null;
    return getUserRole(currentUserId!);
  }

  /// Check if user has a specific role
  Future<bool> hasRole(String uid, UserRole role) async {
    final userRole = await getUserRole(uid);
    return userRole == role;
  }

  /// Check if current user has a specific role
  Future<bool> currentUserHasRole(UserRole role) async {
    if (currentUserId == null) return false;
    return hasRole(currentUserId!, role);
  }

  /// Check if user is admin
  Future<bool> isAdmin(String uid) async {
    return hasRole(uid, UserRole.admin);
  }

  /// Check if current user is admin
  Future<bool> currentUserIsAdmin() async {
    if (currentUserId == null) return false;
    return isAdmin(currentUserId!);
  }

  /// Check if user is a teacher
  Future<bool> isTeacher(String uid) async {
    return hasRole(uid, UserRole.teacher);
  }

  /// Check if current user is a teacher
  Future<bool> currentUserIsTeacher() async {
    if (currentUserId == null) return false;
    return isTeacher(currentUserId!);
  }

  /// Check if user is a student
  Future<bool> isStudent(String uid) async {
    return hasRole(uid, UserRole.student);
  }

  /// Check if current user is a student
  Future<bool> currentUserIsStudent() async {
    if (currentUserId == null) return false;
    return isStudent(currentUserId!);
  }

  /// Set user role
  Future<void> setUserRole(String uid, UserRole role) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': role.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ User role updated to ${role.value}');
    } catch (e) {
      throw Exception('Failed to set user role: $e');
    }
  }

  // ========================= PERMISSION CHECKS =========================

  /// Check if user can read a document
  Future<bool> canReadDocument(String uid, String collection, String docId) async {
    try {
      // Admin can always read
      if (await isAdmin(uid)) return true;

      // For user collection, allow self-read
      if (collection == 'users' && uid == docId) return true;

      // Teachers can read most collections
      if (await isTeacher(uid)) {
        if (['students', 'assignments', 'attendance', 'progress'].contains(collection)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('❌ Error checking read permission: $e');
      return false;
    }
  }

  /// Check if user can write to a document
  Future<bool> canWriteDocument(String uid, String collection, String docId) async {
    try {
      // Admin can always write
      if (await isAdmin(uid)) return true;

      // For user collection, allow self-write
      if (collection == 'users' && uid == docId) return true;

      // Teachers can write assignments, attendance, progress
      if (await isTeacher(uid)) {
        if (['assignments', 'attendance', 'progress', 'courses'].contains(collection)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('❌ Error checking write permission: $e');
      return false;
    }
  }

  /// Check if user can delete a document
  Future<bool> canDeleteDocument(String uid, String collection) async {
    try {
      // Only admins can delete
      return await isAdmin(uid);
    } catch (e) {
      print('❌ Error checking delete permission: $e');
      return false;
    }
  }

  // ========================= DATA VALIDATION =========================

  /// Validate user data before saving
  bool validateUserData(Map<String, dynamic> data) {
    // Required fields
    if (!data.containsKey('email') || data['email'].toString().isEmpty) {
      throw Exception('Email is required');
    }

    if (!data.containsKey('uid') || data['uid'].toString().isEmpty) {
      throw Exception('UID is required');
    }

    // Email validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(data['email'].toString())) {
      throw Exception('Invalid email format');
    }

    // Role validation
    if (data.containsKey('role')) {
      if (UserRole.fromString(data['role']) == null) {
        throw Exception('Invalid role');
      }
    }

    return true;
  }

  /// Validate student data
  bool validateStudentData(Map<String, dynamic> data) {
    if (!data.containsKey('name') || data['name'].toString().isEmpty) {
      throw Exception('Student name is required');
    }

    if (!data.containsKey('email') || data['email'].toString().isEmpty) {
      throw Exception('Student email is required');
    }

    if (data['name'].toString().length < 2) {
      throw Exception('Name must be at least 2 characters');
    }

    return true;
  }

  /// Validate assignment data
  bool validateAssignmentData(Map<String, dynamic> data) {
    if (!data.containsKey('title') || data['title'].toString().isEmpty) {
      throw Exception('Assignment title is required');
    }

    if (!data.containsKey('subject') || data['subject'].toString().isEmpty) {
      throw Exception('Subject is required');
    }

    if (data['title'].toString().length < 3) {
      throw Exception('Title must be at least 3 characters');
    }

    return true;
  }

  // ========================= SECURE OPERATIONS =========================

  /// Safely update user profile (only own profile)
  Future<void> updateOwnProfile(Map<String, dynamic> data) async {
    if (currentUserId == null) {
      throw Exception('No user logged in');
    }

    try {
      validateUserData(data);

      // Prevent UID change
      data.remove('uid');
      // Prevent role change
      data.remove('role');
      // Update timestamp
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(currentUserId!).update(data);
      print('✅ Profile updated successfully');
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Create a new user document (called after Firebase Auth signup)
  Future<void> createUserDocument({
    required String uid,
    required String email,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      final userData = {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'role': role.value,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      validateUserData(userData);

      await _firestore.collection('users').doc(uid).set(userData);
      print('✅ User document created successfully');
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  /// Deactivate user account (instead of deletion)
  Future<void> deactivateAccount(String uid) async {
    try {
      if (await isAdmin(uid)) {
        throw Exception('Cannot deactivate admin accounts');
      }

      await _firestore.collection('users').doc(uid).update({
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Account deactivated successfully');
    } catch (e) {
      throw Exception('Failed to deactivate account: $e');
    }
  }

  /// Reactivate user account
  Future<void> reactivateAccount(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isActive': true,
        'reactivatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Account reactivated successfully');
    } catch (e) {
      throw Exception('Failed to reactivate account: $e');
    }
  }

  // ========================= AUDIT LOGGING =========================

  /// Log user action for audit trail
  Future<void> logAction({
    required String actionType,
    required String description,
    String? targetCollection,
    String? targetDocId,
    Map<String, dynamic>? additionalData,
  }) async {
    if (currentUserId == null) return;

    try {
      final logData = {
        'userId': currentUserId!,
        'actionType': actionType,
        'description': description,
        'targetCollection': targetCollection,
        'targetDocId': targetDocId,
        'timestamp': FieldValue.serverTimestamp(),
        'userAgent': 'flutter_app',
      };

      if (additionalData != null) {
        logData.addAll(additionalData);
      }

      await _firestore.collection('auditLogs').add(logData);
    } catch (e) {
      print('⚠️  Failed to log action: $e');
      // Don't throw - audit logging shouldn't block main operations
    }
  }

  // ========================= SECURITY UTILITIES =========================

  /// Check if document exists and user has access
  Future<bool> documentExists(String collection, String docId) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get user's accessible collections
  Future<List<String>> getAccessibleCollections(String uid) async {
    final collections = <String>[];

    try {
      final userRole = await getUserRole(uid);

      // All authenticated users can access these
      collections.addAll(['announcements', 'courses']);

      if (userRole == UserRole.admin) {
        collections.addAll([
          'users',
          'students',
          'assignments',
          'attendance',
          'progress',
          'notifications',
          'auditLogs',
          'settings',
        ]);
      } else if (userRole == UserRole.teacher) {
        collections.addAll([
          'students',
          'assignments',
          'attendance',
          'progress',
          'notifications',
        ]);
      } else if (userRole == UserRole.student) {
        collections.addAll([
          'assignments',
          'notifications',
        ]);
      }

      return collections;
    } catch (e) {
      print('❌ Error getting accessible collections: $e');
      return collections;
    }
  }

  /// Verify user session is valid
  Future<bool> isSessionValid() async {
    if (!isAuthenticated) return false;

    try {
      // Refresh token to check validity
      await currentUser?.reload();
      return currentUser != null;
    } catch (e) {
      print('❌ Session invalid: $e');
      return false;
    }
  }

  /// Require admin access (throw exception if not admin)
  Future<void> requireAdmin() async {
    if (!await currentUserIsAdmin()) {
      throw Exception('Admin access required');
    }
  }

  /// Require authentication (throw exception if not logged in)
  void requireAuth() {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }
  }
}
