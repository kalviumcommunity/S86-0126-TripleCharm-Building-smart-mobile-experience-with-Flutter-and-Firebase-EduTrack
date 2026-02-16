import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication Provider - Manages authentication state
class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  String _selectedRole = AppConstants.roleTeacher; // Default role

  bool _onboardingCompleted = false;

  // Getters
  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedRole => _selectedRole;
  bool get isTeacher => _user?.role.toLowerCase().trim() == AppConstants.roleTeacher.toLowerCase();
  bool get isStudent => _user?.role.toLowerCase().trim() == AppConstants.roleStudent.toLowerCase();
  UserModel? get teacher => isTeacher ? _user : null;
  bool get onboardingCompleted => _onboardingCompleted;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    await _checkOnboarding();
    await _loadSavedRole();
    _initializeAuthState();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    _onboardingCompleted = true;
    notifyListeners();
  }
  
  /// Load saved role from SharedPreferences
  Future<void> _loadSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString('user_role');
    if (savedRole != null) {
      _selectedRole = savedRole;
      if (kDebugMode) print('🔄 [AUTH] Loaded saved role: $savedRole');
    }
  }
  
  /// Save user's role to SharedPreferences for future logins
  Future<void> _saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
    if (kDebugMode) print('💾 [AUTH] Saved user role: $role');
  }

  /// Initialize auth state from Firebase
  void _initializeAuthState() {
    AuthService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        _isLoading = true;
        notifyListeners();
        await _loadUserData(firebaseUser.uid);
      } else {
        _user = null;
        _isLoading = false;
        _error = null;
        notifyListeners();
      }
    });
  }

  /// Load user data from Firestore
  Future<void> _loadUserData(String userId) async {
    try {
      if (kDebugMode) print('📥 [AUTH] Loading user data for ID: $userId');
      _isLoading = true;
      _error = null;
      _user = null;
      notifyListeners();

      // Load user data with retry logic
      UserModel? userData;
      int retries = 3;
      
      for (int i = 0; i < retries; i++) {
        userData = await DatabaseService.getUserById(userId);
        
        if (userData != null) break;
        
        if (i < retries - 1) {
          if (kDebugMode) print('⚠️ [AUTH] User data not found, retrying in ${(i + 1) * 500}ms...');
          await Future.delayed(Duration(milliseconds: (i + 1) * 500));
        }
      }
      
      if (userData == null) {
        throw Exception('User data not found in database after $retries attempts');
      }
      
      if (kDebugMode) print('✅ [AUTH] User data loaded: ${userData.email}, role: ${userData.role}');
      
      // Validate user data
      if (userData.name.isEmpty || userData.email.isEmpty || userData.role.isEmpty) {
        throw Exception('User data is incomplete or corrupted');
      }
      
      _user = userData;
      await _saveUserRole(userData.role);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AUTH] Failed to load user data: $e');
      
      // Logout to prevent further issues
      await AuthService.logout();
      
      _error = 'Failed to load user data: $e';
      _user = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set selected role for signup/login
  void setSelectedRole(String role) {
    _selectedRole = role;
    if (kDebugMode) print('🎭 [AUTH] Selected role set to: $_selectedRole');
    notifyListeners();
  }
  
  /// Get saved role from previous session (for auto-suggestion)
  Future<String?> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }
  
  /// Auto-load saved role if available
  Future<void> autoLoadSavedRole() async {
    final savedRole = await getSavedRole();
    if (savedRole != null && savedRole.isNotEmpty) {
      _selectedRole = savedRole;
      if (kDebugMode) print('🔄 [AUTH] Auto-loaded saved role: $savedRole');
      notifyListeners();
    }
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? phone,
  }) async {
    if (kDebugMode) {
      print('📋 [AUTH PROVIDER] Sign up started');
      print('   Name: $name');
      print('   Email: $email');
      print('   Selected Role: $_selectedRole');
      print('   Phone: ${phone ?? "null"}');
    }
        // Check if already signed in
    if (_user != null) {
      if (kDebugMode) print('⚠️ [AUTH PROVIDER] User already signed in, skipping signup');
      return true;
    }
        _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate inputs
      if (name.isEmpty) {
        throw Exception(AppConstants.errorEmptyField);
      }

      if (email.isEmpty) {
        throw Exception(AppConstants.errorInvalidEmail);
      }

      if (!AuthService.isValidEmail(email)) {
        throw Exception(AppConstants.errorInvalidEmail);
      }

      if (password.isEmpty || !AuthService.isStrongPassword(password)) {
        throw Exception(AppConstants.errorWeakPassword);
      }

      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      // For students, validate that email exists in students collection
      if (_selectedRole == AppConstants.roleStudent) {
        if (kDebugMode) print('📋 [AUTH PROVIDER] Validating student email exists...');
        final studentExists = await DatabaseService.checkStudentEmailExists(email);
        if (!studentExists) {
          throw Exception('Student email not found. Please contact your teacher to add you first.');
        }
        if (kDebugMode) print('✅ [AUTH PROVIDER] Student email validated');
      }

      if (kDebugMode) print('📋 [AUTH PROVIDER] Validation passed, calling AuthService.signUp...');
      
      // Sign up user
      final userId = await AuthService.signUp(
        name: name,
        email: email,
        password: password,
        role: _selectedRole,
        phone: phone,
      );
      
      if (kDebugMode) print('✅ [AUTH PROVIDER] Sign up completed successfully with userId: $userId');

      // For students, link the Firebase Auth account with their student record
      if (_selectedRole == AppConstants.roleStudent) {
        if (kDebugMode) print('🔗 [AUTH PROVIDER] Linking student account...');
        
        try {
          final studentId = await DatabaseService.linkStudentAccount(
            email: email,
            userId: userId,
          );
          
          if (studentId != null) {
            if (kDebugMode) print('✅ [AUTH PROVIDER] Student account linked! Student ID: $studentId');
          } else {
            if (kDebugMode) print('⚠️ [AUTH PROVIDER] Student record not found for linking');
          }
        } catch (e) {
          if (kDebugMode) print('❌ [AUTH PROVIDER] Failed to link student account: $e');
          // Don't fail the signup if linking fails - user can still login
        }
      }

      // Note: Loading state will be reset by the auth state listener
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [AUTH PROVIDER] Sign up failed: $e');
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      print('🔐 [AUTH] Login attempt for: $email');
      print('🎭 [AUTH] Using selected role: $_selectedRole');
    }
    
    // Check if already signed in with correct account
    if (_user != null && _user!.email == email) {
      if (kDebugMode) print('✅ [AUTH] User already logged in');
      return true;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception(AppConstants.errorEmptyField);
      }

      if (!AuthService.isValidEmail(email)) {
        throw Exception(AppConstants.errorInvalidEmail);
      }

      if (kDebugMode) print('🔐 [AUTH] Calling AuthService.login...');
      await AuthService.login(
        email: email,
        password: password,
      );

      if (kDebugMode) print('🔐 [AUTH] Login successful, waiting for user data...');
      // Wait for user data to be fully loaded by the auth state listener
      // Check periodically until user is loaded or timeout
      int attempts = 0;
      while (attempts < 100) { // Max 10 seconds (100 * 100ms)
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (_user != null && _user!.role.isNotEmpty && !_isLoading) {
          // User data is loaded successfully
          if (kDebugMode) print('✅ [AUTH] User data loaded: ${_user!.email}, role: ${_user!.role}');
          break;
        }
        
        // Check if there's an error during loading
        if (_error != null) {
          if (kDebugMode) print('❌ [AUTH] Error during data load: $_error');
          throw Exception(_error);
        }
        
        attempts++;
      }

      if (_user == null) {
        if (kDebugMode) print('❌ [AUTH] User data failed to load after timeout');
        await AuthService.logout();
        throw Exception('Failed to load user data. Please check your internet connection and try again.');
      }

      // Validate role matches if a specific role was selected
      if (_selectedRole.isNotEmpty && _user != null) {
        final userRole = _user!.role.toLowerCase().trim();
        final selectedRole = _selectedRole.toLowerCase().trim();
        
        if (kDebugMode) print('🔐 [AUTH] Validating role - User: $userRole, Selected: $selectedRole');
        
        if (userRole != selectedRole) {
          // Role mismatch - user is trying to login with wrong role
          final correctRole = userRole == AppConstants.roleTeacher ? 'Teacher' : 'Student';
          final wrongRole = selectedRole == AppConstants.roleTeacher ? 'Teacher' : 'Student';
          
          if (kDebugMode) print('❌ [AUTH] Role mismatch! User is $userRole but selected $selectedRole');
          
          // Save the correct role for next time
          await _saveUserRole(userRole);
          
          await AuthService.logout();
          _isLoading = false;
          notifyListeners();
          
          throw Exception(
            'Wrong account type! This account is registered as $correctRole, but you selected $wrongRole login.\n\n💡 Please go back and select "$correctRole Login" instead.'
          );
        }
      }

      if (kDebugMode) print('✅ [AUTH] Login completed successfully');
      // Success - auth state listener has already set loading to false
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [AUTH] Login failed: $e');
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await AuthService.logout();

      _user = null;
      _error = null;
      _selectedRole = AppConstants.roleTeacher;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (email.isEmpty) {
        throw Exception(AppConstants.errorInvalidEmail);
      }

      if (!AuthService.isValidEmail(email)) {
        throw Exception(AppConstants.errorInvalidEmail);
      }

      await AuthService.resetPassword(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({required String name, String? phone}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_user == null) throw Exception('No user found');
      
      await DatabaseService.updateUser(_user!.id, {
        'name': name,
        'phone': phone,
      });

      // Reload local user data
      await _loadUserData(_user!.id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword(String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.updatePassword(newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to change password: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

