# Firebase Authentication Quick Reference

## Quick Setup

### 1. Ensure Firebase is initialized in `main.dart`
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(...),
  );
  runApp(const MyApp());
}
```

### 2. Verify dependencies in `pubspec.yaml`
```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
```

### 3. Run `flutter pub get`
```bash
flutter pub get
```

## Common Code Snippets

### Import Firebase Auth
```dart
import 'package:firebase_auth/firebase_auth.dart';
```

### Sign Up
```dart
try {
  final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: 'user@example.com',
    password: 'password123',
  );
  print('User: ${credential.user?.email}');
} on FirebaseAuthException catch (e) {
  print('Error: ${e.message}');
}
```

### Sign In
```dart
try {
  final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: 'user@example.com',
    password: 'password123',
  );
  print('User: ${credential.user?.email}');
} on FirebaseAuthException catch (e) {
  print('Error: ${e.message}');
}
```

### Sign Out
```dart
await FirebaseAuth.instance.signOut();
```

### Get Current User
```dart
User? user = FirebaseAuth.instance.currentUser;
String? email = user?.email;
String? uid = user?.uid;
```

### Listen to Auth State Changes
```dart
FirebaseAuth.instance.authStateChanges().listen((User? user) {
  if (user == null) {
    print('User is signed out');
  } else {
    print('User is signed in: ${user.email}');
  }
});
```

### StreamBuilder for UI Updates
```dart
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasData) {
      return const HomeScreen();
    }
    return const AuthScreen();
  },
)
```

### Reset Password
```dart
try {
  await FirebaseAuth.instance.sendPasswordResetEmail(email: 'user@example.com');
  print('Password reset email sent');
} on FirebaseAuthException catch (e) {
  print('Error: ${e.message}');
}
```

### Update Email
```dart
try {
  await FirebaseAuth.instance.currentUser?.updateEmail('newemail@example.com');
  print('Email updated');
} catch (e) {
  print('Error: $e');
}
```

### Update Password
```dart
try {
  await FirebaseAuth.instance.currentUser?.updatePassword('newpassword123');
  print('Password updated');
} catch (e) {
  print('Error: $e');
}
```

### Delete User Account
```dart
try {
  await FirebaseAuth.instance.currentUser?.delete();
  print('User account deleted');
} catch (e) {
  print('Error: $e');
}
```

## Error Codes Quick Reference

| Code | Meaning | Solution |
|------|---------|----------|
| `invalid-email` | Bad email format | Validate email format |
| `weak-password` | Password < 6 chars | Enforce minimum length |
| `email-already-in-use` | Email registered | Suggest login |
| `user-not-found` | Email not registered | Suggest signup |
| `wrong-password` | Incorrect password | Ask to retry |
| `user-disabled` | Account disabled | Show message |
| `network-request-failed` | No internet | Check connection |
| `too-many-requests` | Rate limited | Retry later |

## File Structure Reference

```
lib/
├── main.dart                                    ← Firebase initialization
├── screens/
│   ├── auth_screen.dart                        ← Demo auth screen
│   ├── login_screen.dart                       ← Production login
│   └── signup_screen.dart                      ← Production signup
├── services/
│   ├── auth_service.dart                       ← Core auth logic
│   ├── auth_state_manager.dart                 ← State management
│   └── firebase_auth_error_handler.dart        ← Error handling
└── examples/
    └── persistent_login_example.dart           ← Implementation example

Documentation/
├── FIREBASE_AUTH_GUIDE.md                      ← Full guide
├── FIREBASE_AUTH_TESTING_GUIDE.md              ← Testing procedures
└── FIREBASE_AUTH_QUICK_REFERENCE.md            ← This file
```

## Working with AuthService

```dart
import 'services/auth_service.dart';

final authService = AuthService();

// Sign up
final user = await authService.signUp('email@example.com', 'password123');

// Sign in
final user = await authService.login('email@example.com', 'password123');

// Sign out
await authService.logout();

// Reset password
await authService.resetPassword('email@example.com');

// Get current user
User? user = authService.currentUser;

// Listen to auth changes
authService.authStateChanges.listen((user) {
  if (user != null) {
    print('Logged in: ${user.email}');
  } else {
    print('Logged out');
  }
});
```

## Working with Error Handler

```dart
import 'services/firebase_auth_error_handler.dart';

try {
  await Firebase.signUp(email, password);
} on FirebaseAuthException catch (e) {
  final message = FirebaseAuthErrorHandler.getErrorMessage(e);
  showErrorDialog(message);
  
  // Check specific error type
  if (FirebaseAuthErrorHandler.isWeakPasswordError(e)) {
    showPasswordRequirements();
  } else if (FirebaseAuthErrorHandler.isEmailAlreadyInUseError(e)) {
    navigateToLogin();
  }
}
```

## Using AuthStateManager

```dart
import 'services/auth_state_manager.dart';

final authManager = AuthStateManager();

// Check if logged in
if (authManager.isUserLoggedIn()) {
  print('User is logged in');
}

// Get user info
String? email = authManager.getCurrentUserEmail();
String? uid = authManager.getCurrentUserUID();

// Listen to auth state
authManager.getAuthStateStream().listen((user) {
  if (user != null) {
    print('User: ${user.email}');
  }
});
```

## Firebase Console Steps

1. Go to https://console.firebase.google.com/
2. Select "edutrack" project
3. Click "Build" → "Authentication"
4. Click "Sign-in method" tab
5. Enable "Email/Password"
6. Users created in app appear in "Users" tab

## Testing Checklist

- [ ] Can sign up with valid email/password
- [ ] Can sign in with correct credentials
- [ ] Cannot sign in with wrong password
- [ ] Cannot sign up with weak password
- [ ] Cannot sign up with existing email
- [ ] User appears in Firebase Console
- [ ] Can sign out
- [ ] Remains logged in after app restart
- [ ] Error messages are user-friendly
- [ ] Loading states show during operations

## Debugging Tips

### Check if Firebase is initialized
```dart
print(Firebase.apps.length); // Should be > 0
```

### Check current user
```dart
User? user = FirebaseAuth.instance.currentUser;
print('Current user: ${user?.email}');
```

### Enable Firebase debug logging
```dart
FirebaseAuth.instance.idTokenChanges().listen((User? user) {
  if (user == null) {
    print('User is currently signed out!');
  } else {
    print('User is signed in!');
  }
});
```

### Check auth state changes
```dart
FirebaseAuth.instance.authStateChanges().listen((User? user) {
  print('Auth state changed: $user');
});
```

## Useful Links

- **Firebase Console**: https://console.firebase.google.com/
- **Firebase Auth Docs**: https://firebase.google.com/docs/auth/flutter/start
- **Pub.dev firebase_auth**: https://pub.dev/packages/firebase_auth
- **Dart Async Patterns**: https://dart.dev/guides/libraries/async-await
- **Flutter StreamBuilder**: https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html

## Common Mistakes to Avoid

❌ **DON'T:** Store passwords in SharedPreferences
✅ **DO:** Let Firebase handle secure token storage

❌ **DON'T:** Ignore FirebaseAuthException catch blocks
✅ **DO:** Always handle auth exceptions gracefully

❌ **DON'T:** Poll auth state in a loop
✅ **DO:** Use `authStateChanges()` stream

❌ **DON'T:** Show technical error messages to users
✅ **DO:** Convert error codes to user-friendly messages

❌ **DON'T:** Make network requests without checking internet
✅ **DO:** Handle network errors explicitly

❌ **DON'T:** Keep sensitive data in logs
✅ **DO:** Use debug logging carefully in production

## Performance Tips

1. **Use StreamBuilder at app root** - Avoid rebuilding entire app
2. **Cache user data** - Don't fetch on every widget build
3. **Lazy load auth data** - Load user profile after auth
4. **Use `.currentUser` for quick checks** - Use stream only for UI updates
5. **Debounce auth state changes** - Avoid rapid rebuilds
6. **Clean up listeners** - Always dispose streams/subscriptions

## Next Steps

1. ✅ Set up Firebase Authentication
2. ✅ Implement Auth Service
3. ✅ Create Auth Screens
4. ✅ Add error handling
5. ➡️ **Next:** Implement Firestore for user profiles
6. ➡️ **Next:** Add Google Sign-In
7. ➡️ **Next:** Implement 2FA
8. ➡️ **Next:** Add email verification

## Getting Help

- **Firebase Docs**: https://firebase.google.com/docs/auth
- **Flutter Docs**: https://flutter.dev/docs
- **Stack Overflow**: Tag `firebase-auth` and `flutter`
- **Firebase Community**: https://firebase.community
