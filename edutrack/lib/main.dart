import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';

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
      // Start with WelcomeScreen, which has navigation to Login
      home: const WelcomeScreen(),
      // Define routes for easy navigation
      routes: {
        '/login': (context) => const LoginScreen(),
        '/welcome': (context) => const WelcomeScreen(),
      },
    );
  }
}
