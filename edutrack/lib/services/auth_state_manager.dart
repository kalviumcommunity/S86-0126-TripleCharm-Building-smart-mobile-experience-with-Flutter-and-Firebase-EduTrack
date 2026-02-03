import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

/// Authentication State Management Helper
/// Demonstrates how to monitor and handle authentication state changes
/// This is useful for implementing persistent login and navigation logic

class AuthStateManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  /// Listen to authentication state changes
  /// Use this in your app root to navigate based on auth state
  /// 
  /// Example usage:
  /// ```dart
  /// FirebaseAuth.instance.authStateChanges().listen((User? user) {
  ///   if (user == null) {
  ///     print('User is signed out');
  ///     // Navigate to login screen
  ///   } else {
  ///     print('User is signed in: ${user.email}');
  ///     // Navigate to home screen
  ///   }
  /// });
  /// ```
  Stream<User?> getAuthStateStream() {
    return _authService.authStateChanges;
  }

  /// Get current user synchronously
  User? getCurrentUser() {
    return _authService.currentUser;
  }

  /// Check if user is currently logged in
  bool isUserLoggedIn() {
    return _authService.currentUser != null;
  }

  /// Get current user's email
  String? getCurrentUserEmail() {
    return _authService.currentUser?.email;
  }

  /// Get current user's UID
  String? getCurrentUserUID() {
    return _authService.currentUser?.uid;
  }

  /// Sign up user with email and password
  Future<User?> signUp(String email, String password) async {
    try {
      return await _authService.signUp(email, password);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in user with email and password
  Future<User?> login(String email, String password) async {
    try {
      return await _authService.login(email, password);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password for email
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }
}

/// Example implementation in main.dart or app root widget:
///
/// ```dart
/// class MyApp extends StatefulWidget {
///   @override
///   State<MyApp> createState() => _MyAppState();
/// }
///
/// class _MyAppState extends State<MyApp> {
///   final _authStateManager = AuthStateManager();
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: StreamBuilder<User?>(
///         stream: _authStateManager.getAuthStateStream(),
///         builder: (context, snapshot) {
///           if (snapshot.connectionState == ConnectionState.waiting) {
///             return const LoadingScreen();
///           }
///
///           if (snapshot.hasData) {
///             // User is logged in
///             return const HomeScreen();
///           }
///
///           // User is not logged in
///           return const AuthScreen();
///         },
///       ),
///     );
///   }
/// }
/// ```
