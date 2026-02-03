import 'package:flutter/material.dart';
import 'services/firebase_config.dart';
import 'screens/landing_page.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard.dart';
import 'screens/students_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/assignments_screen.dart';
import 'screens/grades_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/user_input_form.dart';
import 'screens/state_management_demo.dart';
import 'screens/scrollable_views.dart';
import 'screens/firebase_status_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/stateless_stateful_demo.dart';
import 'screens/animated_container_demo.dart';
import 'screens/animated_opacity_demo.dart';
import 'screens/rotate_logo_demo.dart';
import 'screens/page_transition_demo.dart';
import 'screens/home_screen.dart';
import 'screens/second_screen.dart';
import 'screens/responsive_layout.dart';
import 'screens/responsive_demo.dart';
import 'screens/asset_demo.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase using centralized configuration
  await FirebaseConfig.initializeFirebase();
  
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
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 2,
        ),
      ),
      // Start with Landing Page - Proper User Flow
      initialRoute: '/',
      // Define all named routes in sequential order
      routes: {
        // Main App Flow (Sequential)
        '/': (context) => const LandingPage(),
        '/auth': (context) => const AuthScreen(),
        '/login': (context) => const AuthScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        
        // Core Features
        '/students': (context) => const StudentsScreen(),
        '/attendance': (context) => const AttendanceScreen(),
        '/assignments': (context) => const AssignmentsScreen(),
        '/grades': (context) => const GradesScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/user-input': (context) => const UserInputForm(),
        '/state-management': (context) => const StateManagementDemo(),
        '/scrollable': (context) => const ScrollableViews(),
        '/firebase-status': (context) => const FirebaseStatusScreen(),
        
        // Demo/Learning Screens (accessible from dashboard quick actions)
        '/home': (context) => const HomeScreen(),
        '/second': (context) => const SecondScreen(),
        '/responsive': (context) => const ResponsiveLayout(),
        '/responsive-demo': (context) => const ResponsiveDemo(),
        '/assets-demo': (context) => const AssetDemo(),
        '/welcome': (context) => const WelcomeScreen(),
        '/demo': (context) => const StatelessStatefulDemoScreen(),
        '/old-login': (context) => const LoginScreen(),
        
        // Animation demos
        '/animations/container': (context) => const AnimatedContainerDemo(),
        '/animations/opacity': (context) => const AnimatedOpacityDemo(),
        '/animations/rotate': (context) => const RotateLogoDemo(),
        '/animations/page': (context) => const PageTransitionDemo(),
      },
    );
  }
}
