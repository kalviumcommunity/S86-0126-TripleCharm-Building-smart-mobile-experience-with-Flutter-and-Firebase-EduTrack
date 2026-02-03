# Lesson 2: Building Sign Up, Login, and Logout Flows Using Firebase Auth

## 📚 Overview

This lesson builds on the Firebase Authentication foundation from Lesson 1. We'll implement seamless navigation flows that automatically route users to the correct screen based on their authentication state. By the end of this lesson, you'll understand:

1. **StreamBuilder Pattern**: Using `authStateChanges()` for real-time authentication monitoring
2. **Multi-Screen Navigation**: Automatic routing without manual Navigator calls
3. **Persistent Login**: App remembers logged-in users across restarts
4. **Logout Flow**: Secure logout that properly clears session and navigates to login screen

---

## 🎯 Learning Objectives

By the end of this lesson, you will be able to:

- Implement `authStateChanges()` Stream to monitor user authentication status
- Use `StreamBuilder` for real-time UI updates based on auth state
- Create seamless navigation flows without manual routing
- Handle loading states while auth state is being determined
- Implement proper logout that triggers navigation automatically
- Test complete signup → login → logout → login cycles

---

## 🏗️ Architecture Overview

### The StreamBuilder Authentication Pattern

At the heart of this lesson is a simple but powerful pattern: **listen to Firebase auth state changes and rebuild the UI accordingly**.

```
┌─────────────────────────────────────────────────────────┐
│         Firebase Authentication Service                  │
│                                                           │
│    ┌────────────────────────────────────────────────┐   │
│    │ authStateChanges(): Stream<User?>              │   │
│    │ Emits:                                         │   │
│    │ • null (no user logged in)                     │   │
│    │ • User object (user logged in)                 │   │
│    │ • Rebuilds on every state change               │   │
│    └────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│    StreamBuilder<User?> in main.dart                    │
│                                                           │
│    builder(context, snapshot) {                         │
│      if (snapshot.connectionState == waiting)           │
│        → Show Loading Screen                            │
│      if (snapshot.hasData)                              │
│        → Show DashboardScreen (authenticated)           │
│      else                                               │
│        → Show AuthScreen (login/signup)                 │
│    }                                                     │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│              UI Layer (Automatic Navigation)             │
│                                                           │
│    Logged In State     │     Logged Out State            │
│    ├─ DashboardScreen  │     ├─ AuthScreen             │
│    ├─ User Info        │     ├─ Signup Form             │
│    ├─ Student List     │     ├─ Login Form              │
│    └─ Logout Button    │     └─ Password Reset          │
└─────────────────────────────────────────────────────────┘
```

### Key Advantages

✅ **Automatic Navigation**: No manual route management needed
✅ **Real-Time Updates**: UI stays in sync with auth state
✅ **Session Persistence**: Users stay logged in across app restarts
✅ **No Race Conditions**: StreamBuilder handles all edge cases
✅ **Clean Code**: Separation of concerns (auth vs. UI)

---

## 📱 The Three Authentication Flows

### Flow 1: Sign Up

```
User launches app
       ↓
StreamBuilder checks auth state
       ↓
User is null → AuthScreen displayed
       ↓
User taps "Sign Up" tab
       ↓
Enters email, password, name, school
       ↓
Taps "Create Account" button
       ↓
AuthService.signUp() called:
  • Creates user in Firebase Auth
  • Stores profile in Firestore
  • AuthService.signUp() completes
       ↓
Firebase emits new User object
       ↓
authStateChanges() stream receives User
       ↓
StreamBuilder rebuilds with snapshot.hasData = true
       ↓
DashboardScreen appears (no manual navigation needed!)
       ↓
User sees their profile and student list
```

**Code Implementation:**

```dart
// In auth_screen.dart - Sign Up flow
Future<void> _handleSignUp() async {
  if (_formKey.currentState!.validate()) {
    try {
      setState(() => _isLoading = true);
      
      // Call AuthService to create account
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        school: _schoolController.text.trim(),
      );
      
      // AuthService internally calls FirebaseAuth.createUserWithEmailAndPassword()
      // This triggers authStateChanges() to emit new User
      // StreamBuilder in main.dart detects this and navigates to DashboardScreen
      // No manual navigation needed!
      
    } catch (e) {
      _showErrorDialog('Sign Up Failed', e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

### Flow 2: Login

```
User launches app (not logged in from before)
       ↓
AuthScreen displayed (Sign Up tab is default)
       ↓
User taps "Login" tab
       ↓
Enters email and password
       ↓
Taps "Login" button
       ↓
AuthService.login() called:
  • Calls FirebaseAuth.signInWithEmailAndPassword()
  • Returns User object
       ↓
Firebase emits logged-in User object
       ↓
authStateChanges() stream receives User
       ↓
StreamBuilder rebuilds
       ↓
DashboardScreen appears automatically
       ↓
User sees their profile and students
```

**Code Implementation:**

```dart
// In auth_screen.dart - Login flow
Future<void> _handleLogin() async {
  if (_formKey.currentState!.validate()) {
    try {
      setState(() => _isLoading = true);
      
      // Call AuthService to sign in
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // AuthService internally calls FirebaseAuth.signInWithEmailAndPassword()
      // This triggers authStateChanges() to emit User
      // StreamBuilder detects and navigates to DashboardScreen
      // No manual navigation needed!
      
    } catch (e) {
      _showErrorDialog('Login Failed', e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

### Flow 3: Logout

```
User is on DashboardScreen (logged in)
       ↓
User taps Logout button (in AppBar)
       ↓
_handleLogout() called:
  • Shows loading indicator
  • Calls AuthService.logout()
       ↓
AuthService.logout() calls:
  • FirebaseAuth.instance.signOut()
       ↓
Firebase emits null (user logged out)
       ↓
authStateChanges() stream receives null
       ↓
StreamBuilder rebuilds with snapshot.hasData = false
       ↓
AuthScreen appears automatically
       ↓
User sees login/signup form
       ↓
User can log in again with different account
```

**Code Implementation:**

```dart
// In dashboard_screen.dart - Logout flow
Future<void> _handleLogout() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  try {
    setState(() => _isLoggingOut = true);
    
    debugPrint('Logout initiated for ${currentUser?.email}');
    
    // Call AuthService to sign out
    await _authService.logout();
    
    // AuthService internally calls FirebaseAuth.instance.signOut()
    // This triggers authStateChanges() to emit null
    // StreamBuilder in main.dart detects this and shows AuthScreen
    // No manual navigation needed!
    
    debugPrint('Logout successful, StreamBuilder will handle navigation');
    
  } catch (e) {
    debugPrint('Logout error: $e');
    _showSnackBar('Logout failed: $e', isError: true);
  } finally {
    if (mounted) {
      setState(() => _isLoggingOut = false);
    }
  }
}
```

---

## 🔧 Implementation Details

### 1. Main App Structure (main.dart)

The heart of the authentication system is in `main.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
      ),
      // The StreamBuilder pattern for auth state listening
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Case 1: Firebase is still checking auth state (app startup)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Case 2: User is logged in (snapshot has User object)
          if (snapshot.hasData) {
            return const DashboardScreen();
          }

          // Case 3: User is logged out (snapshot has null)
          return const AuthScreen();
        },
      ),
      // Other named routes...
      routes: {
        '/home': (context) => const HomeScreen(),
        // ... other routes
      },
    );
  }
}
```

**Key Points:**

- `authStateChanges()` is a **Stream** that emits whenever authentication state changes
- `StreamBuilder` listens to this stream and rebuilds UI automatically
- No manual `Navigator` calls needed - UI responds to auth state changes
- The pattern is **reactive** and **declarative**

### 2. Authentication Service (auth_service.dart)

The `AuthService` provides clean methods that trigger the streams:

```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  // Sign up: creates user in Firebase Auth and Firestore
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String school,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    final user = userCredential.user;
    
    if (user != null) {
      // Store additional user data in Firestore
      await _firestore.addUserData({
        'uid': user.uid,
        'email': user.email,
        'name': name,
        'school': school,
        'createdAt': DateTime.now(),
      });
    }
    
    return user;
  }

  // Login: authenticates user
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // Logout: signs out user
  Future<void> logout() async {
    await _auth.signOut();
  }
}
```

**Why this matters:**

- `createUserWithEmailAndPassword()` and `signInWithEmailAndPassword()` both trigger `authStateChanges()`
- `signOut()` also triggers `authStateChanges()`
- This means the UI **automatically** responds to auth changes without explicit navigation

### 3. Dashboard Screen (dashboard_screen.dart)

The dashboard is where users see their data after login:

```dart
class DashboardScreen extends StatefulWidget {
  final User? user; // Optional - we get current user from Firebase

  const DashboardScreen({this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final AuthService _authService;
  late final FirestoreService _firestoreService;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _firestoreService = FirestoreService();
    
    // Get current user from Firebase (not from widget parameter)
    final currentUser = FirebaseAuth.instance.currentUser;
    
    _loadUserData();
    _loadStudents();
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final data = await _firestoreService.getUserData(currentUser!.uid);
    setState(() {
      _userData = data;
      _isLoading = false;
    });
  }

  // Key: Logout triggers StreamBuilder to navigate automatically
  Future<void> _handleLogout() async {
    try {
      setState(() => _isLoggingOut = true);
      await _authService.logout();
      
      // StreamBuilder in main.dart sees null user and shows AuthScreen
      // No manual navigation needed!
      
    } catch (e) {
      _showSnackBar('Logout failed: $e', isError: true);
    } finally {
      setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the dashboard UI...
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: _isLoggingOut
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(),
                  )
                : const Icon(Icons.logout),
            onPressed: _isLoggingOut ? null : _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadUserData();
                await _loadStudents();
              },
              child: SingleChildScrollView(
                // User info and students...
              ),
            ),
    );
  }
}
```

**Critical Details:**

- Parameter `final User? user;` is optional (allows flexibility)
- Uses `FirebaseAuth.instance.currentUser` to get current user
- `_handleLogout()` doesn't navigate manually - StreamBuilder handles it
- Loading state manages the UI feedback during logout

### 4. Auth Screen (auth_screen.dart)

The auth screen provides signup and login UI:

```dart
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _authService = AuthService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduTrack Auth'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sign Up'),
            Tab(text: 'Login'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Sign Up tab - calls AuthService.signUp()
          SignupTab(authService: _authService),
          
          // Login tab - calls AuthService.login()
          LoginTab(authService: _authService),
        ],
      ),
    );
  }
}
```

**Key Points:**

- Auth screen provides tabs for signup and login
- Both tabs call `AuthService` methods
- Auth service methods trigger Firebase auth changes
- StreamBuilder in main.dart detects these changes and navigates to DashboardScreen
- **Users never manually navigate** - it happens automatically!

---

## 🧪 Testing Checklist

Use this checklist to verify the complete authentication flow works:

### Test 1: Fresh Install Sign Up
- [ ] Install app on emulator/device (or clear app data to simulate fresh install)
- [ ] App starts and shows `AuthScreen`
- [ ] Click "Sign Up" tab
- [ ] Fill in email, password, name, school
- [ ] Click "Create Account"
- [ ] App navigates to `DashboardScreen` automatically
- [ ] User info shows correct name and email
- [ ] Student list is empty (first login)

**Expected Result:** ✅ Smooth transition from AuthScreen to DashboardScreen

### Test 2: Fresh Install Login (After Sign Up)
- [ ] Close app completely
- [ ] Reopen app
- [ ] App shows `AuthScreen` (should show Login tab as default or show both)
- [ ] Fill email and password (from previous sign up)
- [ ] Click "Login"
- [ ] App navigates to `DashboardScreen` automatically
- [ ] Previous user data appears (profile, any students added)

**Expected Result:** ✅ Login successful, old data preserved

### Test 3: Logout
- [ ] While on `DashboardScreen`, click logout button (top right)
- [ ] Logout button shows loading indicator
- [ ] App navigates to `AuthScreen` automatically
- [ ] Can log in again with same account

**Expected Result:** ✅ Clean logout, automatic navigation, session cleared

### Test 4: Persistent Login (App Restart)
- [ ] Log in to an account
- [ ] You're on `DashboardScreen` with user data
- [ ] Close app completely (kill the process)
- [ ] Reopen app
- [ ] App should show `DashboardScreen` automatically (not AuthScreen)
- [ ] User data should appear immediately

**Expected Result:** ✅ Session persists across app restarts

### Test 5: Wrong Password
- [ ] On LoginTab, enter correct email but wrong password
- [ ] Click "Login"
- [ ] Error message appears: "The password is invalid"
- [ ] Stay on AuthScreen (no navigation)

**Expected Result:** ✅ Error handled gracefully

### Test 6: Weak Password Sign Up
- [ ] On SignupTab, enter email and password < 6 characters
- [ ] Click "Create Account"
- [ ] Error message appears: "Password should be at least 6 characters"
- [ ] Stay on AuthScreen (no account created)

**Expected Result:** ✅ Validation works before Firebase call

### Test 7: Existing Email Sign Up
- [ ] Sign up with an email, then log out
- [ ] Try to sign up again with the same email
- [ ] Error message appears: "The email address is already in use"
- [ ] Stay on AuthScreen (no new account)

**Expected Result:** ✅ Duplicate email prevented

### Test 8: Multiple User Accounts
- [ ] Log in with Account A (see their data)
- [ ] Log out
- [ ] Log in with Account B (see different data)
- [ ] Log out
- [ ] Log in with Account A again (see Account A data restored)

**Expected Result:** ✅ Multiple accounts work correctly, data persists

### Test 9: Firebase Console Verification
- [ ] Open [Firebase Console](https://console.firebase.google.com)
- [ ] Go to `edutrack-49094` project
- [ ] Navigate to **Authentication > Users**
- [ ] Verify new users appear in the console
- [ ] Check **Firestore** under Collections > `users` to see stored profile data
- [ ] Verify deleted users no longer appear in console after logout

**Expected Result:** ✅ Data in Firebase matches app behavior

---

## 📊 State Diagram

Here's a visual representation of how state transitions work:

```
┌──────────────────┐
│   App Start      │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────┐
│ StreamBuilder checks:        │
│ authStateChanges().listen() │
└────────┬─────────────────────┘
         │
         ├─ Waiting...? ──► Show Loading Spinner
         │
         ├─ User != null ──► Show DashboardScreen
         │                   ├─ Display user profile
         │                   ├─ Display students
         │                   └─ Show Logout button
         │
         └─ User == null ──► Show AuthScreen
                             ├─ Sign Up Tab
                             │  └─ _handleSignUp()
                             │     └─ AuthService.signUp()
                             │        └─ Creates Firebase Auth User
                             │           └─ authStateChanges() emits User
                             │              └─ Back to DashboardScreen
                             │
                             └─ Login Tab
                                └─ _handleLogin()
                                   └─ AuthService.login()
                                      └─ Signs in Firebase User
                                         └─ authStateChanges() emits User
                                            └─ Back to DashboardScreen
```

---

## 🎓 Key Learnings

### 1. **StreamBuilder is Your Friend**
```dart
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) { ... }
)
```
This single pattern handles ALL navigation. Users never explicitly navigate - they just do auth actions, and the UI responds.

### 2. **No Manual Navigator Calls for Auth**
```dart
// ❌ OLD WAY (Don't do this for logout)
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => LoginScreen()),
);

// ✅ NEW WAY (Let StreamBuilder handle it)
await _authService.logout();
// StreamBuilder detects null and shows AuthScreen automatically
```

### 3. **Use FirebaseAuth.instance.currentUser Anywhere**
```dart
// You don't need to pass User as a parameter
// Access it from Firebase anywhere:
final currentUser = FirebaseAuth.instance.currentUser;
if (currentUser != null) {
  final uid = currentUser.uid;
  final email = currentUser.email;
}
```

### 4. **Session Persistence is Automatic**
```dart
// Firebase Auth persists login locally by default
// When app restarts:
// 1. Flutter loads (main.dart)
// 2. StreamBuilder asks: is user still logged in?
// 3. Firebase checks local storage
// 4. If yes: emits User → show DashboardScreen
// 5. If no: emits null → show AuthScreen
// NO EXTRA CODE NEEDED!
```

### 5. **Connection State Matters**
```dart
if (snapshot.connectionState == ConnectionState.waiting) {
  // Still checking with Firebase - show loading
}
```
This prevents flickering when the app first loads and Firebase checks the persisted session.

---

## 📚 File Reference

Key files involved in authentication:

| File | Purpose |
|------|---------|
| `lib/main.dart` | StreamBuilder auth pattern, app entry point |
| `lib/screens/auth_screen.dart` | Sign up and login UI |
| `lib/screens/dashboard_screen.dart` | Logged-in home screen |
| `lib/services/auth_service.dart` | Firebase Auth methods (signUp, login, logout) |
| `lib/services/firestore_service.dart` | User profile management |

---

## 🚀 Next Steps

After completing this lesson:

1. **Security**: Learn about secure password storage and two-factor authentication
2. **Advanced Flows**: Implement password reset, email verification, account deletion
3. **Advanced Auth**: Google Sign-In, social login providers
4. **State Management**: Use Provider or GetX for more complex app state
5. **Offline Support**: Use local caching with Hive or Shared Preferences

---

## ✅ Reflection Questions

1. **Why is StreamBuilder better than checking `currentUser` periodically?**
   - Answer: StreamBuilder is reactive and responds to real-time changes. Periodic checks are inefficient and can miss state changes.

2. **What happens if you restart the app while logged in?**
   - Answer: Firebase automatically restores the session from local storage. StreamBuilder detects the user and shows DashboardScreen without manual action.

3. **Why is the User parameter in DashboardScreen now optional?**
   - Answer: We can always get the current user from `FirebaseAuth.instance.currentUser`, so we don't need to pass it as a parameter. This decouples the widget from navigation logic.

4. **What triggers the logout navigation back to AuthScreen?**
   - Answer: When we call `logout()`, Firebase emits `null` from `authStateChanges()`. StreamBuilder detects this and rebuilds with the `AuthScreen`. No manual navigation needed!

5. **How does the app remember the user after a restart?**
   - Answer: Firebase Auth maintains a local cache of the current user. When the app restarts, `authStateChanges()` checks this cache and emits the logged-in user (if one exists).

---

## 📞 Troubleshooting

### App Shows AuthScreen Even When Logged In
**Problem:** After login, the app goes back to AuthScreen instead of showing DashboardScreen.
**Solution:**
- Check if `AuthService.signUp()` and `AuthService.login()` are actually calling Firebase methods
- Verify Firebase is initialized in `main()`
- Check logcat/console for Firebase errors

### Logout Doesn't Navigate Away
**Problem:** After clicking logout, you stay on DashboardScreen.
**Solution:**
- Verify `_authService.logout()` is being called
- Check if Firebase is actually signing out (check logcat)
- Ensure `authStateChanges()` is being listened to (check StreamBuilder)

### Session Not Persisting Across Restarts
**Problem:** After closing and reopening the app, you're back at AuthScreen even though you were logged in.
**Solution:**
- This is usually okay for development
- In production, Firebase should persist sessions automatically
- Check Firebase documentation for session persistence settings

### StreamBuilder Flicker on Startup
**Problem:** You see AuthScreen flash before DashboardScreen on startup (or vice versa).
**Solution:**
- This is expected while Firebase checks the session (loading state)
- The `ConnectionState.waiting` case shows a loading spinner
- You can improve UX by showing a splash screen during this time

---

## 📖 Code Examples Reference

All code examples in this lesson use the actual implementations from your `edutrack` project. You can find complete working code in:

- `lib/main.dart` - StreamBuilder pattern
- `lib/screens/auth_screen.dart` - Sign up and login UI
- `lib/screens/dashboard_screen.dart` - Dashboard with logout
- `lib/services/auth_service.dart` - Auth business logic

---

## 🎉 Summary

In this lesson, you learned:

✅ **StreamBuilder Pattern** - Listen to Firebase auth changes in real-time
✅ **Multi-Screen Navigation** - Automatic routing based on auth state
✅ **Sign Up Flow** - Create accounts and sync to Firestore
✅ **Login Flow** - Authenticate users and restore their data
✅ **Logout Flow** - Sign out and return to login screen
✅ **Session Persistence** - Users stay logged in across app restarts
✅ **Testing Strategies** - Verify all flows work correctly

The beautiful thing about this architecture is its **simplicity**: users do auth actions (sign up, login, logout), and the UI responds automatically. No manual navigation, no race conditions, no complex state management. Just reactive, declarative code that stays in sync with Firebase.

---

## 📝 Checklist for Mastery

- [ ] I understand how `authStateChanges()` works
- [ ] I can explain why StreamBuilder is used in main.dart
- [ ] I know the three authentication flows (Sign Up, Login, Logout)
- [ ] I can trace code from button click to Firebase to UI update
- [ ] I've tested all 9 test cases successfully
- [ ] I understand why session persistence is automatic
- [ ] I can modify auth screens without breaking the system
- [ ] I'm comfortable using `FirebaseAuth.instance.currentUser`

---

**Congratulations! You've mastered Firebase Authentication Flows in Flutter.** 🎊

