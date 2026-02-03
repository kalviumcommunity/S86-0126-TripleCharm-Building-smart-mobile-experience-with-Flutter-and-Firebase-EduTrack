# Firebase Authentication - Practical Workflow

## Step-by-Step Implementation Guide

### Step 1: Verify Firebase is Configured

Check [main.dart](lib/main.dart):
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBl3NM09aQJPORl49l4blRJOn8QzAu-H8E",
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

✅ **Status:** Already configured!

### Step 2: Verify Dependencies

Check [pubspec.yaml](pubspec.yaml):
```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
```

✅ **Status:** Already added!

Run installation:
```bash
cd edutrack
flutter pub get
```

### Step 3: Test the Demo Auth Screen

Create a temporary main entry for testing:

**Option A: Use as temporary home screen**

Edit [main.dart](lib/main.dart) temporarily:
```dart
import 'screens/auth_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AuthScreen(),  // Temporary for testing
      // ...
    );
  }
}
```

Run the app:
```bash
flutter run
```

### Step 4: Test Signup Flow

1. **Click "Create Account" button** (should already show since it starts in login mode)
   - Actually click on "Don't have an account? Sign Up" link

2. **Fill in the form:**
   - Email: `testuser@example.com`
   - Password: `password123`
   - Confirm Password: `password123`

3. **Click "Create Account"**
   - Expected: Success dialog appears
   - Expected: Navigate to next screen

4. **Check Firebase Console:**
   - Go to: https://console.firebase.google.com/
   - Select: edutrack project
   - Navigate: Build → Authentication → Users
   - Expected: See `testuser@example.com` listed

### Step 5: Test Login Flow

1. **Click "Already have an account? Login"**

2. **Fill in the form:**
   - Email: `testuser@example.com`
   - Password: `password123`

3. **Click "Login"**
   - Expected: Success dialog appears

### Step 6: Test Error Handling

#### Test 1: Weak Password
1. Go to signup
2. Enter email: `newuser@example.com`
3. Enter password: `123` (less than 6 chars)
4. Click "Create Account"
5. Expected: "Password should be at least 6 characters"

#### Test 2: Email Already In Use
1. Try to sign up with `testuser@example.com` again
2. Expected: "An account already exists for that email"

#### Test 3: Invalid Email
1. Try email: `invalidemail`
2. Click "Create Account"
3. Expected: "Please enter a valid email"

#### Test 4: Wrong Password
1. Go to login
2. Enter email: `testuser@example.com`
3. Enter password: `wrongpassword`
4. Click "Login"
5. Expected: "Wrong password provided"

### Step 7: Integrate with Your App

Now integrate real screens into your app flow.

**Option 1: Use production screens (recommended)**

Edit [main.dart](lib/main.dart):
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduTrack',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (snapshot.hasData) {
            // User is logged in
            return DashboardScreen(user: snapshot.data!);
          }
          
          // User is not logged in
          return const LoginScreen();
        },
      ),
    );
  }
}
```

**Option 2: Use custom navigation**

Create a wrapper widget:
```dart
class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }
        
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        
        return const AuthScreen();
      },
    );
  }
}
```

Then in main:
```dart
home: const AuthenticationWrapper(),
```

### Step 8: Implement Additional Features

#### Password Reset
```dart
Future<void> resetPassword(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent')),
    );
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Error sending reset email')),
    );
  }
}
```

#### Logout
```dart
Future<void> logout() async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error logging out: $e')),
    );
  }
}
```

#### Get Current User Info
```dart
User? user = FirebaseAuth.instance.currentUser;
String? email = user?.email;
String? uid = user?.uid;
print('User: $email (UID: $uid)');
```

### Step 9: Add to User Profile

Combine auth with Firestore:

```dart
import 'services/firestore_service.dart';

Future<void> createUserProfile(User user, String name) async {
  final firestoreService = FirestoreService();
  await firestoreService.addUserData(user.uid, {
    'name': name,
    'email': user.email,
    'createdAt': DateTime.now(),
  });
}
```

### Step 10: Test Complete Flow

#### Signup Flow Test
1. Signup with new email
2. Verify user appears in Firebase Console
3. Verify user data saved in Firestore
4. Close app and reopen
5. Verify logged in automatically
6. Verify can access user profile

#### Logout Flow Test
1. Click logout button
2. Verify redirected to login screen
3. Close app and reopen
4. Verify login screen appears

#### Session Persistence Test
1. Login successfully
2. Kill and restart app
3. Verify still logged in
4. Verify user email is shown
5. Close app completely
6. Clear app data (Settings app)
7. Reopen app
8. Verify login screen appears

## Common Implementation Patterns

### Pattern 1: Simple Login/Signup
```dart
// Simple pattern for basic apps
class SimpleAuthScreen extends StatefulWidget {
  @override
  State<SimpleAuthScreen> createState() => _SimpleAuthScreenState();
}

class _SimpleAuthScreenState extends State<SimpleAuthScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignup = false;

  void _submit() async {
    try {
      if (_isSignup) {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Auth error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isSignup ? 'Sign Up' : 'Login')),
      body: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          ElevatedButton(
            onPressed: _submit,
            child: Text(_isSignup ? 'Sign Up' : 'Login'),
          ),
          TextButton(
            onPressed: () => setState(() => _isSignup = !_isSignup),
            child: Text(_isSignup 
              ? 'Already have account?' 
              : 'Need account?'),
          ),
        ],
      ),
    );
  }
}
```

### Pattern 2: With State Management
```dart
// Using AuthStateManager for cleaner code
class SmartAuthScreen extends StatefulWidget {
  @override
  State<SmartAuthScreen> createState() => _SmartAuthScreenState();
}

class _SmartAuthScreenState extends State<SmartAuthScreen> {
  final _authManager = AuthStateManager();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignup = false;

  void _submit() async {
    try {
      if (_isSignup) {
        await _authManager.signUp(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        await _authManager.login(
          _emailController.text,
          _passwordController.text,
        );
      }
      // No need to navigate - StreamBuilder handles it
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Same UI as Pattern 1
    return Container();
  }
}
```

### Pattern 3: With Error Handler
```dart
// Using Firebase error handler
void _submit() async {
  try {
    await _authManager.login(email, password);
  } on FirebaseAuthException catch (e) {
    final message = FirebaseAuthErrorHandler.getErrorMessage(e);
    
    if (FirebaseAuthErrorHandler.isWeakPasswordError(e)) {
      showPasswordRequirementsDialog();
    } else if (FirebaseAuthErrorHandler.isEmailAlreadyInUseError(e)) {
      showLoginInstead();
    } else {
      showErrorDialog(message);
    }
  }
}
```

## Debugging Checklist

- [ ] Firebase initialized successfully (check log: "✅ Firebase initialized")
- [ ] Dependencies installed (`flutter pub get` ran)
- [ ] App runs without crashes
- [ ] Can signup with valid credentials
- [ ] User appears in Firebase Console
- [ ] Can login with correct credentials
- [ ] Shows error on invalid credentials
- [ ] Can logout
- [ ] Remains logged in after app restart
- [ ] StreamBuilder updates UI on auth state change

## Deployment Checklist

Before deploying to production:

- [ ] Remove test auth screen from main.dart
- [ ] Verify error messages are user-friendly
- [ ] Test on real devices (not just emulator)
- [ ] Test on slow network
- [ ] Test offline mode
- [ ] Enable 2FA in Firebase Console
- [ ] Set password policy in Firebase Console
- [ ] Enable Email Verification if needed
- [ ] Set up password reset email
- [ ] Test all error scenarios
- [ ] Add analytics tracking
- [ ] Set up crash reporting
- [ ] Implement rate limiting (optional)

## Performance Optimization

### Tip 1: Don't Recreate AuthService
```dart
// ❌ DON'T: Create new instance in build()
@override
Widget build(BuildContext context) {
  final auth = AuthService();  // Creates new instance
  return ...;
}

// ✅ DO: Create once at class level
class MyScreen extends StatefulWidget {
  final auth = AuthService();  // Created once
  @override
  Widget build(BuildContext context) { ... }
}
```

### Tip 2: Use StreamBuilder at Top Level
```dart
// ✅ DO: Use at app root
MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(...),  // Top level
    );
  }
}

// ❌ DON'T: Use in every screen
myScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(...);  // Rebuilds entire screen
  }
}
```

### Tip 3: Cache User Data
```dart
// Cache user info after login
class UserCache {
  static User? _cachedUser;
  
  static Future<User?> getUser() async {
    return _cachedUser ?? FirebaseAuth.instance.currentUser;
  }
  
  static void updateCache(User? user) {
    _cachedUser = user;
  }
}
```

## Success Metrics

✅ Implementation is successful when:
- Users can signup and appear in Firebase Console
- Users can login with correct credentials
- Invalid credentials show appropriate errors
- App persists login across sessions
- No crashes or unhandled exceptions
- Response time < 2 seconds for auth operations
- Error messages are helpful
- All 12 test categories pass

---

**You're all set to use Firebase Authentication in your EduTrack app!**

For more details, see:
- [FIREBASE_AUTH_GUIDE.md](FIREBASE_AUTH_GUIDE.md) - Comprehensive guide
- [FIREBASE_AUTH_QUICK_REFERENCE.md](FIREBASE_AUTH_QUICK_REFERENCE.md) - Quick lookup
- [FIREBASE_AUTH_TESTING_GUIDE.md](FIREBASE_AUTH_TESTING_GUIDE.md) - Testing procedures
