import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/class_provider.dart';
import 'providers/student_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/marks_provider.dart';
import 'providers/announcement_provider.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/teacher/teacher_main_screen.dart';
import 'screens/student/student_main_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kDebugMode) print('🔥 [FIREBASE] Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) print('✅ [FIREBASE] Firebase initialized successfully');
  
  // Configure Firestore for web - DISABLE persistence to avoid corruption
  if (kIsWeb) {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false, // Disable to prevent corruption
      );
      if (kDebugMode) print('⚙️ [FIREBASE] Firestore configured for web (persistence disabled)');
    } catch (e) {
      if (kDebugMode) print('⚠️ [FIREBASE] Could not configure Firestore: $e');
    }
  }
  
  // Test Firestore connection
  final firestoreConnected = await DatabaseService.testFirestoreConnection();
  if (!firestoreConnected && kDebugMode) {
    print('⚠️ [FIREBASE] WARNING: Firestore connection test failed!');
    print('⚠️ [FIREBASE] Please check:');
    print('   1. Internet connection');
    print('   2. Firestore is enabled in Firebase Console');
    print('   3. Firebase project configuration is correct');
  }

  // Initialize notifications
  await NotificationService.initialize();


  runApp(const EduTrackApp());
}

class EduTrackApp extends StatelessWidget {
  const EduTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication Provider
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Data Providers
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => MarksProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),

      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.getLightTheme(),
        debugShowCheckedModeBanner: false,
        home: const _RootNavigator(),
      ),
    );
  }
}

/// Root Navigator - Handles auth state and routes
class _RootNavigator extends StatelessWidget {
  const _RootNavigator();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (kDebugMode) print('\ud83e\udded [NAV] Building root navigator...');
        if (kDebugMode) print('\ud83e\udded [NAV] isLoading: ${authProvider.isLoading}');
        if (kDebugMode) print('\ud83e\udded [NAV] isAuthenticated: ${authProvider.isAuthenticated}');
        if (kDebugMode) print('\ud83e\udded [NAV] onboardingCompleted: ${authProvider.onboardingCompleted}');
        if (kDebugMode) print('\ud83e\udded [NAV] user: ${authProvider.user?.email}, role: ${authProvider.user?.role}');
        
        // 1. Show splash screen while loading (either initial load or authenticating)
        if (authProvider.isLoading) {
          if (kDebugMode) print('\ud83e\udded [NAV] \u27a1\ufe0f Showing SplashScreen (loading)');
          return const SplashScreen();
        }

        // 2. Show onboarding if not completed
        if (!authProvider.onboardingCompleted) {
          if (kDebugMode) print('\ud83e\udded [NAV] \u27a1\ufe0f Showing OnboardingScreen');
          return const OnboardingScreen();
        }

        // 3. Authenticated -> Show appropriate dashboard based on role
        if (authProvider.isAuthenticated && authProvider.user != null) {
          final user = authProvider.user!;
          
          // Ensure role is not empty
          if (user.role.isEmpty) {
            if (kDebugMode) print('\ud83e\udded [NAV] \u27a1\ufe0f Showing SplashScreen (empty role)');
            return const SplashScreen();
          }
          
          // Route based on role (case-insensitive check)
          final role = user.role.toLowerCase().trim();
          
          if (role == AppConstants.roleTeacher.toLowerCase()) {
            if (kDebugMode) print('\ud83e\udded [NAV] \u27a1\ufe0f Navigating to TeacherMainScreen for ${user.email}');
            return const TeacherMainScreen();
          } else if (role == AppConstants.roleStudent.toLowerCase()) {
            if (kDebugMode) print('\ud83e\udded [NAV] \u27a1\ufe0f Navigating to StudentMainScreen for ${user.email}');
            return const StudentMainScreen();
          }
          
          // If role is not recognized, show splash/error
          if (kDebugMode) print('\ud83e\udded [NAV] \u27a1\ufe0f Showing SplashScreen (unrecognized role: $role)');
          return const SplashScreen();
        }

        // 4. Not authenticated -> Show Role Selection (which leads to Login/Sign up)
        if (kDebugMode) print('\ud83e\udded [NAV] \u27a1\ufe0f Showing RoleSelectionScreen (not authenticated)');
        return const RoleSelectionScreen();
      },
    );
  }
}
