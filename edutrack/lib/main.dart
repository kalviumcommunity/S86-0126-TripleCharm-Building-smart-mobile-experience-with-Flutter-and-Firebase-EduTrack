import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/stateless_stateful_demo.dart';
import 'screens/home_screen.dart';
import 'screens/second_screen.dart';
import 'screens/profile_screen.dart';

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
      // Define initial route - start with navigation demo
      initialRoute: '/home',
      // Define all named routes for easy navigation
      routes: {
        '/home': (context) => const HomeScreen(),
        '/second': (context) => const SecondScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/login': (context) => const LoginScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/demo': (context) => const StatelessStatefulDemoScreen(),
      },
    );
  }
}
