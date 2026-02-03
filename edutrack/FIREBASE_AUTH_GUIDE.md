# Firebase Authentication Implementation Guide

## Overview
This document provides a complete guide to the Firebase Authentication implementation in the EduTrack Flutter app, covering Email & Password authentication with secure user management.

## 1. Project Structure

```
lib/
├── main.dart                          # App entry point with Firebase initialization
├── screens/
│   ├── auth_screen.dart              # Demo authentication screen (new)
│   ├── login_screen.dart             # Production login screen
│   └── signup_screen.dart            # Production signup screen
└── services/
    ├── auth_service.dart             # Core Firebase authentication service
    └── auth_state_manager.dart       # Authentication state management helper
```

## 2. Dependencies

Your project already has the required Firebase dependencies in `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
```

To install or update packages:
```bash
flutter pub get
```

## 3. Firebase Initialization

Firebase is initialized in `main.dart` with your EduTrack project credentials:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "YOUR_API_KEY",
      authDomain: "edutrack-49094.firebaseapp.com",
      projectId: "edutrack-49094",
      storageBucket: "edutrack-49094.firebasestorage.app",
      messagingSenderId: "900631831881",
      appId: "1:900631831881:web:550307fdcf6a3c9562e698",
      measurementId: "G-E3ZNGK3ETD",
    ),
  );
  
  runApp(const MyApp());
}
```

## 4. AuthService Class

The `AuthService` class handles all Firebase authentication operations:

### Methods:

#### Sign Up
```dart
Future<User?> signUp(String email, String password) async {
  final UserCredential credential = await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
  return credential.user;
}
```

**Error Handling:**
- `weak-password` - Password less than 6 characters
- `email-already-in-use` - Email already registered
- `invalid-email` - Invalid email format

#### Login
```dart
Future<User?> login(String email, String password) async {
  final UserCredential credential = await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  return credential.user;
}
```

**Error Handling:**
- `user-not-found` - Email not registered
- `wrong-password` - Incorrect password
- `user-disabled` - Account disabled
- `invalid-email` - Invalid email format

#### Logout
```dart
Future<void> logout() async {
  await _auth.signOut();
}
```

#### Reset Password
```dart
Future<void> resetPassword(String email) async {
  await _auth.sendPasswordResetEmail(email: email);
}
```

#### Get Current User
```dart
User? get currentUser => _auth.currentUser;
Stream<User?> get authStateChanges => _auth.authStateChanges();
```

## 5. AuthScreen Implementation

The `AuthScreen` demonstrates login and signup functionality with:

- **Email Validation** - Validates email format
- **Password Requirements** - Enforces 6+ character passwords
- **Password Visibility Toggle** - Show/hide password option
- **Form Validation** - Validates all fields before submission
- **Error Handling** - User-friendly error messages
- **Loading States** - Shows progress indicator during authentication
- **Mode Switching** - Toggle between login and signup

### Key Features:

```dart
// Email validation
if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
  return 'Please enter a valid email';
}

// Password strength check
if (!isLogin && value.length < 6) {
  return 'Password should be at least 6 characters';
}

// Error message mapping
String _getErrorMessage(String errorCode) {
  switch (errorCode) {
    case 'weak-password':
      return 'Password should be at least 6 characters';
    case 'email-already-in-use':
      return 'An account already exists for that email';
    // ... more cases
  }
}
```

## 6. Authentication State Management

### Using AuthStateManager

The `AuthStateManager` provides helper methods for managing authentication state:

```dart
final authStateManager = AuthStateManager();

// Check if user is logged in
bool isLoggedIn = authStateManager.isUserLoggedIn();

// Get current user email
String? email = authStateManager.getCurrentUserEmail();

// Get current user UID
String? uid = authStateManager.getCurrentUserUID();

// Listen to auth state changes
authStateManager.getAuthStateStream().listen((User? user) {
  if (user == null) {
    print('User logged out');
  } else {
    print('User logged in: ${user.email}');
  }
});
```

### StreamBuilder Pattern

For reactive UI updates based on authentication state:

```dart
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const LoadingScreen();
    }

    if (snapshot.hasData) {
      // User is logged in
      return const HomeScreen();
    }

    // User is not logged in
    return const AuthScreen();
  },
)
```

## 7. Verify Authentication in Firebase Console

1. **Open Firebase Console**
   - Go to: https://console.firebase.google.com/
   - Select your "edutrack" project

2. **Navigate to Authentication**
   - Click "Build" → "Authentication"
   - View "Users" tab

3. **See Registered Users**
   - New users appear immediately after signup
   - Each user shows:
     - Email address
     - Creation date
     - Last sign-in time
     - User ID (UID)

4. **Manage Users**
   - Disable users to prevent login
   - Delete users to remove accounts
   - Reset passwords (if email configured)

## 8. Common Issues & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `PlatformException: ERROR_INVALID_EMAIL` | Invalid email format | Use email validation before submission |
| `PlatformException: ERROR_WEAK_PASSWORD` | Password < 6 chars | Enforce 6+ character minimum |
| `PlatformException: ERROR_EMAIL_ALREADY_IN_USE` | Email registered | Check if user exists before signup |
| `PlatformException: ERROR_USER_NOT_FOUND` | Email not registered | Ask user to sign up first |
| `PlatformException: ERROR_WRONG_PASSWORD` | Wrong password | Hint user to check password |
| `Firebase not initialized` | Missing initialization | Add `await Firebase.initializeApp()` in `main()` |
| `MissingPluginException` | Missing platform channel | Run `flutter pub get` and rebuild |

## 9. Security Best Practices

1. **Never Store Passwords** - Firebase handles password hashing
2. **Use HTTPS** - All Firebase connections are encrypted
3. **Enable 2FA** - Optional additional security in Firebase Console
4. **Validate Input** - Always validate email and password format
5. **Handle Errors Gracefully** - Don't expose sensitive error details
6. **Use FirebaseUser** - Access user info via `FirebaseAuth.instance.currentUser`
7. **Implement Logout** - Always provide logout functionality
8. **Secure State** - Use Stream listeners for auth state changes

## 10. Advanced Features

### Password Reset Email
```dart
try {
  await FirebaseAuth.instance.sendPasswordResetEmail(
    email: emailController.text,
  );
  // Show success message
} on FirebaseAuthException catch (e) {
  // Handle error
}
```

### Update User Email
```dart
try {
  await FirebaseAuth.instance.currentUser?.updateEmail(newEmail);
} catch (e) {
  // Handle error
}
```

### Update User Profile
```dart
try {
  await FirebaseAuth.instance.currentUser?.updateDisplayName('John Doe');
  await FirebaseAuth.instance.currentUser?.updatePhotoURL(urlString);
} catch (e) {
  // Handle error
}
```

### Check Email Verification
```dart
if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
  print('Email is verified');
} else {
  // Send verification email
  await FirebaseAuth.instance.currentUser?.sendEmailVerification();
}
```

## 11. Testing Checklist

- [ ] Create account with new email
- [ ] Verify user appears in Firebase Console
- [ ] Login with correct credentials
- [ ] Try login with wrong password
- [ ] Try signup with weak password
- [ ] Try signup with already registered email
- [ ] Logout and verify user is cleared
- [ ] Check auth state stream updates
- [ ] Test email validation
- [ ] Test form validation

## 12. Next Steps

After implementing authentication:

1. **Integrate with Firestore** - Store user profiles in Firestore
2. **Add Social Login** - Implement Google Sign-In
3. **Enable 2FA** - Add two-factor authentication
4. **Implement Password Reset** - Full password recovery flow
5. **Add User Profile Management** - Update name, photo, etc.
6. **Implement Session Management** - Handle token refresh
7. **Add Email Verification** - Verify user emails

## 13. Useful Resources

- **Firebase Auth Documentation**: https://firebase.google.com/docs/auth
- **Flutter Firebase Plugins**: https://pub.dev/packages/firebase_auth
- **Firebase Console**: https://console.firebase.google.com/
- **Email Validation Regex**: https://emailregex.com/

## Summary

You now have a complete Firebase Authentication system that:
- ✅ Registers new users securely
- ✅ Authenticates existing users
- ✅ Handles errors gracefully
- ✅ Manages authentication state
- ✅ Validates input properly
- ✅ Integrates with Firestore for user data
- ✅ Follows Flutter and Firebase best practices
