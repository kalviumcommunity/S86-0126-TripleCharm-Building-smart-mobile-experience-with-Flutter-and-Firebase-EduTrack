import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/stateless_stateful_demo.dart';
import 'screens/home_screen.dart';
import 'screens/second_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/responsive_layout.dart';
import 'screens/scrollable_views.dart';
import 'screens/user_input_form.dart';
import 'screens/state_management_demo.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with EduTrack project credentials
  try {
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
    print('✅ Firebase initialized successfully!');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
  
  runApp(const MyApp());
}

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
      // Use StreamBuilder to listen to authentication state changes
      // This enables real-time navigation without manual routing
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show loading while checking authentication state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // If user is logged in, show dashboard
          if (snapshot.hasData) {
            return const DashboardScreen();
          }

          // If user is not logged in, show authentication screen
          return const AuthScreen();
        },
      ),
      // Additional named routes for navigation demo (when not logged in)
      routes: {
        '/home': (context) => const HomeScreen(),
        '/second': (context) => const SecondScreen(),
        '/responsive': (context) => const ResponsiveLayout(),
        '/scrollable': (context) => const ScrollableViews(),
        '/profile': (context) => const ProfileScreen(),
        '/login': (context) => const LoginScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/demo': (context) => const StatelessStatefulDemoScreen(),
        '/user-input': (context) => const UserInputForm(),
        '/state-management': (context) => const StateManagementDemo(),
        '/auth': (context) => const AuthScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
