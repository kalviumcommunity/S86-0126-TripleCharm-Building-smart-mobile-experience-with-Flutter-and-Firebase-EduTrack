import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration for EduTrack application
/// This contains the Firebase project credentials for web platform
class FirebaseConfig {
  static const FirebaseOptions webOptions = FirebaseOptions(
    apiKey: "AIzaSyBl3NM09aQJPORl49l4blRJOn8QzAu-H8E",
    authDomain: "edutrack-49094.firebaseapp.com",
    projectId: "edutrack-49094",
    storageBucket: "edutrack-49094.firebasestorage.app",
    messagingSenderId: "900631831881",
    appId: "1:900631831881:web:550307fdcf6a3c9562e698",
    measurementId: "G-E3ZNGK3ETD",
  );

  /// Project Information
  static const String projectId = 'edutrack-49094';
  static const String projectName = 'EduTrack - Smart Attendance Tracker';
  
  /// Initialize Firebase with proper error handling
  static Future<bool> initializeFirebase() async {
    try {
      await Firebase.initializeApp(options: webOptions);
      print('✅ Firebase initialized successfully!');
      print('📱 Project: $projectName');
      print('🆔 Project ID: $projectId');
      return true;
    } catch (e) {
      print('❌ Firebase initialization error: $e');
      return false;
    }
  }

  /// Check if Firebase is already initialized
  static bool isFirebaseInitialized() {
    try {
      Firebase.app();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get Firebase app instance
  static FirebaseApp? getFirebaseApp() {
    try {
      return Firebase.app();
    } catch (e) {
      return null;
    }
  }
}
