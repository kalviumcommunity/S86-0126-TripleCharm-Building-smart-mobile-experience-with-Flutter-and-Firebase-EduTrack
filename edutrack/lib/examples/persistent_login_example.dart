import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Example: Persistent Login Implementation
/// This example demonstrates how to implement persistent login
/// where the app automatically navigates to the home screen if
/// the user is already logged in.

/// Main app widget with authentication state handling
class MyAppWithAuth extends StatelessWidget {
  const MyAppWithAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
      ),
      // Listen to authentication state changes
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // While checking authentication status
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // If error occurs
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          // If user is logged in (has data)
          if (snapshot.hasData) {
            // User is authenticated, navigate to home screen
            return const HomeScreenExample(user: snapshot.data);
          }

          // If no user data (not logged in)
          // Navigate to authentication screen
          return const AuthScreenExample();
        },
      ),
    );
  }
}

/// Example Authentication Screen
class AuthScreenExample extends StatefulWidget {
  const AuthScreenExample({super.key});

  @override
  State<AuthScreenExample> createState() => _AuthScreenExampleState();
}

class _AuthScreenExampleState extends State<AuthScreenExample> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // No need to navigate - StreamBuilder will handle it automatically
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Login failed';
        _isLoading = false;
      });
    }
  }

  /// Handle signup
  Future<void> _handleSignup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // No need to navigate - StreamBuilder will handle it automatically
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Signup failed';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Auth Example'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Title
              const Text(
                'Welcome to EduTrack',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Error Message
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),

              // Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text('Login'),
              ),
              const SizedBox(height: 12),

              // Signup Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example Home Screen (shown when user is logged in)
class HomeScreenExample extends StatelessWidget {
  final User? user;

  const HomeScreenExample({super.key, this.user});

  /// Handle logout
  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // No need to navigate - StreamBuilder will handle it automatically
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.email ?? 'User',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _handleLogout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

/// IMPORTANT NOTES:
///
/// 1. StreamBuilder Pattern:
///    - FirebaseAuth.instance.authStateChanges() automatically listens for 
///      authentication state changes
///    - When user logs in/out, the stream emits new data
///    - StreamBuilder rebuilds the widget tree based on the stream
///    - This ensures automatic navigation without manual route pushing
///
/// 2. No Manual Navigation Needed:
///    - After login/signup, the StreamBuilder automatically shows the home screen
///    - After logout, the StreamBuilder automatically shows the auth screen
///    - This is better than Navigator.pushReplacement()
///
/// 3. Persistent Login:
///    - User remains logged in across app sessions
///    - FirebaseAuth persists the login token locally
///    - On app restart, authStateChanges() emits the current user immediately
///
/// 4. Connection States:
///    - waiting: Still checking authentication status
///    - done: Authentication check completed
///    - error: Error occurred during authentication check
///
/// 5. Best Practices:
///    - Always handle the waiting state with a loading screen
///    - Always handle errors gracefully
///    - Use StreamBuilder only at the app root level
///    - Store user data in separate state management (Provider, Riverpod, etc.)
