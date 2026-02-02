import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/stateless_stateful_demo.dart';
import 'screens/animated_container_demo.dart';
import 'screens/animated_opacity_demo.dart';
import 'screens/rotate_logo_demo.dart';
import 'screens/page_transition_demo.dart';
import 'screens/home_screen.dart';
import 'screens/second_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/responsive_layout.dart';
import 'screens/responsive_demo.dart';
import 'screens/asset_demo.dart';
import 'screens/scrollable_views.dart';
import 'screens/user_input_form.dart';
import 'screens/state_management_demo.dart';

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
        '/responsive': (context) => const ResponsiveLayout(),
        '/responsive-demo': (context) => const ResponsiveDemo(),
        '/assets-demo': (context) => const AssetDemo(),
        '/scrollable': (context) => const ScrollableViews(),
        '/profile': (context) => const ProfileScreen(),
        '/login': (context) => const LoginScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/demo': (context) => const StatelessStatefulDemoScreen(),
        '/user-input': (context) => const UserInputForm(),
        '/state-management': (context) => const StateManagementDemo(),
        // Animation demos
        '/animations/container': (context) => const AnimatedContainerDemo(),
        '/animations/opacity': (context) => const AnimatedOpacityDemo(),
        '/animations/rotate': (context) => const RotateLogoDemo(),
        '/animations/page': (context) => const PageTransitionDemo(),
      },
    );
  }
}
