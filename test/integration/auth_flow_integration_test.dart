// 🧪 AUTOMATED AUTHENTICATION FLOW INTEGRATION TEST
// 
// This test uses Flutter's integration testing framework
// to automatically test authentication flows.
//
// RUN COMMAND:
// flutter test test/integration/auth_flow_integration_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edutrack_demo/services/auth_service.dart';
import 'package:edutrack_demo/services/database_service.dart';
import 'package:edutrack_demo/config/constants.dart';
import 'package:edutrack_demo/firebase_options.dart';

void main() {
  // Test configuration
  const testTeacherEmail = 'integration_teacher@edutrack.test';
  const testStudentEmail = 'integration_student@edutrack.test';
  const testPassword = 'IntegrationTest@123';
  const testName = 'Integration Test User';

  setUpAll(() async {
    // Initialize Firebase for testing
    TestWidgetsFlutterBinding.ensureInitialized();
    
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully for testing');
    } catch (e) {
      if (e.toString().contains('duplicate-app')) {
        print('ℹ️  Firebase already initialized');
      } else {
        print('❌ Firebase initialization error: $e');
        rethrow;
      }
    }
  });

  group('Authentication Flow Tests', () {
    
    // ==================== SIGNUP TESTS ====================
    
    group('Signup Tests', () {
      
      test('1. Teacher Signup - Success', () async {
        // Clean up any existing test user
        try {
          final existingUser = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                email: testTeacherEmail, 
                password: testPassword
              );
          await existingUser.user?.delete();
          await FirebaseAuth.instance.signOut();
        } catch (e) {
          // User doesn't exist, that's fine
        }

        // Perform signup
        final userId = await AuthService.signUp(
          name: testName,
          email: testTeacherEmail,
          password: testPassword,
          role: AppConstants.roleTeacher,
          phone: '+91 9876543210',
        );

        // Verify Firebase Auth user created
        expect(userId, isNotEmpty);
        expect(AuthService.currentUser, isNotNull);
        expect(AuthService.currentUser!.email, testTeacherEmail);

        // Verify Firestore document created
        final userDoc = await DatabaseService.getUserById(userId);
        expect(userDoc, isNotNull);
        expect(userDoc!.email, testTeacherEmail);
        expect(userDoc.role, AppConstants.roleTeacher);
        expect(userDoc.name, testName);
        expect(userDoc.isActive, true);

        // Clean up
        await AuthService.logout();
      });

      test('2. Student Signup - Success', () async {
        // Clean up existing
        try {
          final existingUser = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                email: testStudentEmail, 
                password: testPassword
              );
          await existingUser.user?.delete();
          await FirebaseAuth.instance.signOut();
        } catch (e) {
          // Doesn't exist
        }

        // Signup
        final userId = await AuthService.signUp(
          name: 'Test Student',
          email: testStudentEmail,
          password: testPassword,
          role: AppConstants.roleStudent,
        );

        // Verify
        expect(userId, isNotEmpty);
        final userDoc = await DatabaseService.getUserById(userId);
        expect(userDoc!.role, AppConstants.roleStudent);

        // Clean up
        await AuthService.logout();
      });

      test('3. Signup with Duplicate Email - Should Fail', () async {
        // First signup (should succeed)
        try {
          await AuthService.signUp(
            name: testName,
            email: testTeacherEmail,
            password: testPassword,
            role: AppConstants.roleTeacher,
          );
          await AuthService.logout();
        } catch (e) {
          // Already exists, that's fine
        }

        // Second signup with same email (should fail)
        expect(
          () => AuthService.signUp(
            name: 'Another User',
            email: testTeacherEmail,
            password: testPassword,
            role: AppConstants.roleTeacher,
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('4. Signup with Weak Password - Should Fail', () async {
        expect(
          () => AuthService.signUp(
            name: testName,
            email: 'weakpass@test.com',
            password: '123', // Too short
            role: AppConstants.roleTeacher,
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('5. Signup with Invalid Email - Should Fail', () async {
        expect(
          () => AuthService.signUp(
            name: testName,
            email: 'notanemail', // Invalid format
            password: testPassword,
            role: AppConstants.roleTeacher,
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('6. Signup with Empty Name - Should Fail', () async {
        expect(
          () => AuthService.signUp(
            name: '', // Empty name
            email: 'test@example.com',
            password: testPassword,
            role: AppConstants.roleTeacher,
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    // ==================== LOGIN TESTS ====================
    
    group('Login Tests', () {
      
      setUp(() async {
        // Ensure test users exist
        try {
          await AuthService.signUp(
            name: testName,
            email: testTeacherEmail,
            password: testPassword,
            role: AppConstants.roleTeacher,
          );
          await AuthService.logout();
        } catch (e) {
          // Already exists
        }

        try {
          await AuthService.signUp(
            name: 'Test Student',
            email: testStudentEmail,
            password: testPassword,
            role: AppConstants.roleStudent,
          );
          await AuthService.logout();
        } catch (e) {
          // Already exists
        }
      });

      test('7. Teacher Login - Success', () async {
        final userId = await AuthService.login(
          email: testTeacherEmail,
          password: testPassword,
        );

        expect(userId, isNotEmpty);
        expect(AuthService.isAuthenticated, true);
        expect(AuthService.currentUser!.email, testTeacherEmail);

        // Verify user data
        final userDoc = await DatabaseService.getUserById(userId);
        expect(userDoc!.role, AppConstants.roleTeacher);

        await AuthService.logout();
      });

      test('8. Student Login - Success', () async {
        final userId = await AuthService.login(
          email: testStudentEmail,
          password: testPassword,
        );

        expect(AuthService.isAuthenticated, true);
        final userDoc = await DatabaseService.getUserById(userId);
        expect(userDoc!.role, AppConstants.roleStudent);

        await AuthService.logout();
      });

      test('9. Login with Wrong Password - Should Fail', () async {
        expect(
          () => AuthService.login(
            email: testTeacherEmail,
            password: 'WrongPassword123',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('10. Login with Non-existent Email - Should Fail', () async {
        expect(
          () => AuthService.login(
            email: 'nonexistent@test.com',
            password: testPassword,
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('11. Login with Empty Email - Should Fail', () async {
        expect(
          () => AuthService.login(
            email: '',
            password: testPassword,
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('12. Login Updates Last Login Time', () async {
        final userId = await AuthService.login(
          email: testTeacherEmail,
          password: testPassword,
        );

        // Wait a moment for async update
        await Future.delayed(Duration(milliseconds: 500));

        final userDoc = await DatabaseService.getUserById(userId);
        expect(userDoc!.lastLogin, isNotNull);
        
        // Check that lastLogin is recent (within last minute)
        final now = DateTime.now();
        final diff = now.difference(userDoc.lastLogin!);
        expect(diff.inMinutes, lessThan(1));

        await AuthService.logout();
      });
    });

    // ==================== ROLE-BASED ACCESS TESTS ====================
    
    group('Role-Based Access Control Tests', () {
      
      test('13. Verify Teacher Role from Firestore', () async {
        await AuthService.login(
          email: testTeacherEmail,
          password: testPassword,
        );

        final user = await DatabaseService.getUserById(
          AuthService.currentUser!.uid
        );
        
        expect(user!.role.toLowerCase(), AppConstants.roleTeacher.toLowerCase());
        expect(user.role, isNot(AppConstants.roleStudent));

        await AuthService.logout();
      });

      test('14. Verify Student Role from Firestore', () async {
        await AuthService.login(
          email: testStudentEmail,
          password: testPassword,
        );

        final user = await DatabaseService.getUserById(
          AuthService.currentUser!.uid
        );
        
        expect(user!.role.toLowerCase(), AppConstants.roleStudent.toLowerCase());
        expect(user.role, isNot(AppConstants.roleTeacher));

        await AuthService.logout();
      });

      test('15. Role Case Insensitivity', () async {
        // Test that roles work regardless of case
        await AuthService.login(
          email: testTeacherEmail,
          password: testPassword,
        );

        final user = await DatabaseService.getUserById(
          AuthService.currentUser!.uid
        );
        
        // All these should be true regardless of how role is stored
        expect(user!.role.toLowerCase(), 'teacher');
        
        await AuthService.logout();
      });
    });

    // ==================== LOGOUT TESTS ====================
    
    group('Logout Tests', () {
      
      test('16. Logout Clears Authentication', () async {
        await AuthService.login(
          email: testTeacherEmail,
          password: testPassword,
        );

        expect(AuthService.isAuthenticated, true);

        await AuthService.logout();

        expect(AuthService.isAuthenticated, false);
        expect(AuthService.currentUser, isNull);
      });

      test('17. Multiple Logout Calls - No Error', () async {
        await AuthService.login(
          email: testTeacherEmail,
          password: testPassword,
        );
        
        await AuthService.logout();
        
        // Second logout should not throw error
        expect(
          () => AuthService.logout(),
          returnsNormally,
        );
      });
    });

    // ==================== DATA INTEGRITY TESTS ====================
    
    group('Data Integrity Tests', () {
      
      test('18. User Document Matches Auth User', () async {
        final userId = await AuthService.login(
          email: testTeacherEmail,
          password: testPassword,
        );

        final authUser = AuthService.currentUser!;
        final firestoreUser = await DatabaseService.getUserById(userId);

        expect(firestoreUser!.id, authUser.uid);
        expect(firestoreUser.email, authUser.email);

        await AuthService.logout();
      });

      test('19. User Data Persists After Login/Logout Cycle', () async {
        // Login
        final userId = await AuthService.login(
          email: testTeacherEmail,
          password: testPassword,
        );
        final user1 = await DatabaseService.getUserById(userId);
        
        // Logout
        await AuthService.logout();
        
        // Login again
        await AuthService.login(
          email: testTeacherEmail,
          password: testPassword,
        );
        final user2 = await DatabaseService.getUserById(userId);

        // Data should be identical
        expect(user2!.email, user1!.email);
        expect(user2.name, user1.name);
        expect(user2.role, user1.role);
        expect(user2.createdAt, user1.createdAt);

        await AuthService.logout();
      });

      test('20. Phone Number is Optional', () async {
        const emailWithoutPhone = 'nophone@test.com';
        
        // Clean up if exists
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailWithoutPhone,
            password: testPassword,
          );
          await FirebaseAuth.instance.currentUser?.delete();
        } catch (e) {
          // Ignore cleanup errors - user may not exist
        }

        // Signup without phone
        final userId = await AuthService.signUp(
          name: 'No Phone User',
          email: emailWithoutPhone,
          password: testPassword,
          role: AppConstants.roleTeacher,
          // phone: null (not provided)
        );

        final user = await DatabaseService.getUserById(userId);
        expect(user!.phone, isNull);

        await AuthService.logout();
      });
    });

    // ==================== ERROR HANDLING TESTS ====================
    
    group('Error Handling Tests', () {
      
      test('21. Graceful Handling of Network Errors', () async {
        // This would need network simulation or mocking
        // Placeholder for now
      });

      test('22. Firestore Write Failure Handling', () async {
        // This would need to mock Firestore
        // Placeholder for now
      });

      test('23. Auth State Changes Properly', () async {
        final authStateChanges = <User?>[];
        final subscription = AuthService.authStateChanges.listen(
          (user) => authStateChanges.add(user)
        );

        // Initial state
        expect(authStateChanges.length, greaterThanOrEqualTo(1));
        expect(authStateChanges.last, isNull);

        // Login
        await AuthService.login(
          email: testTeacherEmail,
          password: testPassword,
        );
        await Future.delayed(Duration(milliseconds: 100));
        
        expect(authStateChanges.last, isNotNull);

        // Logout
        await AuthService.logout();
        await Future.delayed(Duration(milliseconds: 100));
        
        expect(authStateChanges.last, isNull);

        subscription.cancel();
      });
    });
  });

  // ==================== CLEANUP ====================
  
  tearDownAll(() async {
    // Clean up test users
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: testTeacherEmail,
        password: testPassword,
      );
      await FirebaseAuth.instance.currentUser?.delete();
    } catch (e) {
      // Ignore cleanup errors - user may not exist
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: testStudentEmail,
        password: testPassword,
      );
      await FirebaseAuth.instance.currentUser?.delete();
    } catch (e) {
      // Ignore cleanup errors - user may not exist
    }
  });
}
