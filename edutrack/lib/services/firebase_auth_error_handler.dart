import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication Error Handling Guide
/// Complete reference for handling Firebase Authentication errors

/// Centralized error handler for Firebase Authentication
class FirebaseAuthErrorHandler {
  /// Convert Firebase Auth exceptions to user-friendly messages
  static String getErrorMessage(FirebaseAuthException exception) {
    return switch (exception.code) {
      // Sign In / Sign Up errors
      'invalid-email' => 'The email address is invalid.',
      'user-disabled' => 'This user account has been disabled.',
      'user-not-found' => 'No account found with this email. Please sign up first.',
      'wrong-password' => 'The password is incorrect. Please try again.',
      'email-already-in-use' => 'An account already exists for this email address.',
      'weak-password' => 'The password must be at least 6 characters long.',
      'operation-not-allowed' => 'Email/password accounts are not enabled.',

      // Network errors
      'network-request-failed' => 'Network error. Please check your internet connection.',
      'too-many-requests' => 'Too many login attempts. Please try again later.',

      // Other errors
      'account-exists-with-different-credential' =>
        'An account already exists with this email but different sign-in credentials.',
      'invalid-credential' => 'Invalid credentials provided.',
      'invalid-verification-code' => 'Invalid verification code.',
      'invalid-verification-id' => 'Invalid verification ID.',
      'credential-already-in-use' => 'This credential is already associated with another account.',

      // Password reset errors
      'user-token-expired' => 'Your session has expired. Please log in again.',
      'user-mismatch' => 'The provided credential does not match the current user.',

      // Default error
      _ => 'Authentication error: ${exception.message ?? exception.code}',
    };
  }

  /// Determine if error is due to network issues
  static bool isNetworkError(FirebaseAuthException exception) {
    return exception.code == 'network-request-failed';
  }

  /// Determine if error is due to invalid credentials
  static bool isInvalidCredentialsError(FirebaseAuthException exception) {
    return exception.code == 'wrong-password' ||
        exception.code == 'invalid-email' ||
        exception.code == 'user-not-found';
  }

  /// Determine if error is due to password being too weak
  static bool isWeakPasswordError(FirebaseAuthException exception) {
    return exception.code == 'weak-password';
  }

  /// Determine if email already exists
  static bool isEmailAlreadyInUseError(FirebaseAuthException exception) {
    return exception.code == 'email-already-in-use';
  }

  /// Determine if user has been disabled
  static bool isUserDisabledError(FirebaseAuthException exception) {
    return exception.code == 'user-disabled';
  }

  /// Determine if rate limit has been exceeded
  static bool isRateLimitError(FirebaseAuthException exception) {
    return exception.code == 'too-many-requests';
  }
}

/// Example: Comprehensive error handling in signup
Future<void> signupExampleWithErrorHandling(
    String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    print('User signed up successfully: ${credential.user?.email}');
  } on FirebaseAuthException catch (e) {
    // Get user-friendly error message
    final errorMessage = FirebaseAuthErrorHandler.getErrorMessage(e);

    // Handle specific error types
    if (FirebaseAuthErrorHandler.isWeakPasswordError(e)) {
      print('Weak password - suggest password requirements');
    } else if (FirebaseAuthErrorHandler.isEmailAlreadyInUseError(e)) {
      print('Email already in use - suggest login instead');
    } else if (FirebaseAuthErrorHandler.isNetworkError(e)) {
      print('Network error - suggest retrying with internet connection');
    } else if (FirebaseAuthErrorHandler.isRateLimitError(e)) {
      print('Rate limited - suggest trying again later');
    }

    print('Error: $errorMessage');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

/// Example: Comprehensive error handling in login
Future<void> loginExampleWithErrorHandling(
    String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    print('User logged in successfully: ${credential.user?.email}');
  } on FirebaseAuthException catch (e) {
    // Get user-friendly error message
    final errorMessage = FirebaseAuthErrorHandler.getErrorMessage(e);

    // Handle specific error types
    if (FirebaseAuthErrorHandler.isInvalidCredentialsError(e)) {
      print('Invalid credentials - show login form with error');
    } else if (FirebaseAuthErrorHandler.isUserDisabledError(e)) {
      print('User disabled - show account disabled message');
    } else if (FirebaseAuthErrorHandler.isNetworkError(e)) {
      print('Network error - show retry button');
    } else if (FirebaseAuthErrorHandler.isRateLimitError(e)) {
      print('Rate limited - show "try again later" message');
    }

    print('Error: $errorMessage');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

/// Example: Error handling in password reset
Future<void> resetPasswordExampleWithErrorHandling(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    print('Password reset email sent to $email');
  } on FirebaseAuthException catch (e) {
    final errorMessage = FirebaseAuthErrorHandler.getErrorMessage(e);
    print('Error: $errorMessage');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

/// Example: Error handling in logout
Future<void> logoutExampleWithErrorHandling() async {
  try {
    await FirebaseAuth.instance.signOut();
    print('User logged out successfully');
  } catch (e) {
    print('Logout error: $e');
  }
}

/// Firebase Auth Error Codes Reference
/// 
/// AUTHENTICATION ERRORS:
/// - invalid-email: Email address is invalid format
/// - user-disabled: User account has been disabled by admin
/// - user-not-found: No user with this email exists
/// - wrong-password: Password is incorrect
/// - email-already-in-use: Email is already registered
/// - weak-password: Password doesn't meet security requirements (min 6 chars)
/// - operation-not-allowed: Email/password auth is not enabled
/// 
/// NETWORK ERRORS:
/// - network-request-failed: Network connection issue
/// - too-many-requests: Too many login attempts (rate limited)
/// 
/// CREDENTIAL ERRORS:
/// - account-exists-with-different-credential: Email exists with different auth method
/// - invalid-credential: Provided credential is invalid
/// - credential-already-in-use: Credential is linked to another account
/// 
/// SESSION ERRORS:
/// - user-token-expired: Session has expired
/// - user-mismatch: Credential doesn't match current user
/// 
/// VERIFICATION ERRORS:
/// - invalid-verification-code: Verification code is incorrect
/// - invalid-verification-id: Verification ID is invalid

/// BEST PRACTICES FOR ERROR HANDLING:
/// 
/// 1. ALWAYS use try-catch blocks around Firebase Auth calls
/// 2. DISTINGUISH between FirebaseAuthException and generic exceptions
/// 3. PROVIDE user-friendly error messages (not technical error codes)
/// 4. SUGGEST actions to users (e.g., "Please sign up first" for user-not-found)
/// 5. HANDLE network errors specially (allow retry)
/// 6. HANDLE rate limiting gracefully (suggest trying later)
/// 7. VALIDATE input BEFORE calling Firebase (fail fast)
/// 8. LOG errors for debugging (but don't expose to users)
/// 9. USE specific error handlers for specific error types
/// 10. TEST error scenarios during development
