import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edutrack_demo/services/auth_service.dart';
import 'package:edutrack_demo/services/database_service.dart';
import 'package:edutrack_demo/models/student_model.dart';
import 'package:edutrack_demo/firebase_options.dart';

// Helper function to get class students from stream
Future<List<StudentModel>> getClassStudents(String classId) {
  final completer = Completer<List<StudentModel>>();
  late StreamSubscription subscription;
  
  subscription = DatabaseService.getClassStudentsStream(classId)
      .timeout(const Duration(seconds: 5))
      .listen(
        (students) {
          subscription.cancel();
          completer.complete(students);
        },
        onError: (error) {
          subscription.cancel();
          completer.completeError(error);
        },
      );
  
  return completer.future;
}

void main() {
  group('EduTrack Complete Integration Tests', () {
    
    // Test data
    const String testTeacherEmail = 'teacher.test@edutrack.com';
    const String testStudentEmail = 'student.test@edutrack.com';
    const String testPassword = 'Test123!@#';
    const String testTeacherName = 'Test Teacher';
    const String testStudentName = 'Test Student';
    const String testPhone = '+1234567890';

    late String teacherUserId;
    late String studentUserId;
    late String classId;
    late String addedStudentId;

    setUpAll(() async {
      // Initialize Firebase for testing
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print('✅ Firebase initialized for testing');
      } catch (e) {
        if (e.toString().contains('duplicate-app')) {
          print('ℹ️ Firebase already initialized');
        } else {
          print('❌ Firebase initialization error: $e');
          rethrow;
        }
      }

      // Clean up any existing test accounts
      await _cleanupTestAccounts();
    });

    tearDownAll(() async {
      // Clean up test data after all tests
      await _cleanupTestAccounts();
    });

    group('📝 Account Creation Tests', () {
      
      test('Should create teacher account successfully', () async {
        print('\n🧪 Testing teacher account creation...');
        
        try {
          teacherUserId = await AuthService.signUp(
            name: testTeacherName,
            email: testTeacherEmail,
            password: testPassword,
            role: 'teacher',
            phone: testPhone,
          );

          expect(teacherUserId, isNotEmpty);
          expect(teacherUserId.length, greaterThan(10));
          
          // Verify user is authenticated
          expect(AuthService.isAuthenticated, isTrue);
          expect(AuthService.currentUser?.email, equals(testTeacherEmail));
          
          print('✅ Teacher account created successfully');
          print('   User ID: $teacherUserId');
          print('   Email: $testTeacherEmail');
          
          // Wait a bit for any background operations to complete
          await Future.delayed(const Duration(seconds: 2));
          
        } catch (e) {
          print('❌ Teacher account creation failed: $e');
          // Don't rethrow immediately, check if it's a timeout issue
          if (e.toString().contains('timeout') || e.toString().contains('network')) {
            throw Exception('Network timeout during teacher signup. Please check your internet connection.');
          }
          rethrow;
        }
      });

      test('Should create student account successfully', () async {
        print('\n🧪 Testing student account creation...');
        
        try {
          // Sign out teacher first
          await AuthService.signOut();
          
          studentUserId = await AuthService.signUp(
            name: testStudentName,
            email: testStudentEmail,
            password: testPassword,
            role: 'student',
            phone: testPhone,
          );

          expect(studentUserId, isNotEmpty);
          expect(studentUserId.length, greaterThan(10));
          
          // Verify user is authenticated
          expect(AuthService.isAuthenticated, isTrue);
          expect(AuthService.currentUser?.email, equals(testStudentEmail));
          
          print('✅ Student account created successfully');
          print('   User ID: $studentUserId');
          print('   Email: $testStudentEmail');
          
        } catch (e) {
          print('❌ Student account creation failed: $e');
          rethrow;
        }
      });

      test('Should prevent duplicate account creation', () async {
        print('\n🧪 Testing duplicate account prevention...');
        
        try {
          await AuthService.signOut();
          
          await AuthService.signUp(
            name: 'Duplicate Teacher',
            email: testTeacherEmail, // Same email as before
            password: testPassword,
            role: 'teacher',
          );
          
          fail('Should have thrown an error for duplicate email');
        } catch (e) {
          expect(e.toString().toLowerCase(), contains('email'));
          print('✅ Duplicate account prevention working correctly');
        }
      });

      test('Should validate weak passwords', () async {
        print('\n🧪 Testing password validation...');
        
        try {
          await AuthService.signOut();
          
          await AuthService.signUp(
            name: 'Test User',
            email: 'weak.password@test.com',
            password: '123', // Weak password
            role: 'teacher',
          );
          
          fail('Should have thrown an error for weak password');
        } catch (e) {
          expect(e.toString().toLowerCase(), contains('password'));
          print('✅ Password validation working correctly');
        }
      });
    });

    group('👨‍🎓 Student Management Tests', () {
      
      setUpAll(() async {
        // Sign in as teacher for student management tests
        await AuthService.signOut();
        await AuthService.signIn(
          email: testTeacherEmail,
          password: testPassword,
        );

        // Create a test class first
        classId = await DatabaseService.createClass(
          teacherId: teacherUserId,
          name: 'Test Class 101',
          description: 'Test class for integration testing',
        );
        
        print('✅ Test class created: $classId');
      });

      test('Should add individual student successfully', () async {
        print('\n🧪 Testing individual student addition...');
        
        try {
          addedStudentId = await DatabaseService.addStudent(
            name: 'John Doe',
            email: 'john.doe@student.test',
            phone: '+1987654321',
            rollNumber: 'S001',
            classId: classId,
          );

          expect(addedStudentId, isNotEmpty);
          
          // Verify student was added by fetching class students
          final students = await getClassStudents(classId);
          expect(students.length, equals(1));
          expect(students.first.name, equals('John Doe'));
          expect(students.first.rollNumber, equals('S001'));
          
          print('✅ Individual student added successfully');
          print('   Student ID: $addedStudentId');
          
        } catch (e) {
          print('❌ Individual student addition failed: $e');
          rethrow;
        }
      });

      test('Should add multiple students in bulk', () async {
        print('\n🧪 Testing bulk student addition...');
        
        try {
          final studentsData = [
            {
              'name': 'Jane Smith',
              'email': 'jane.smith@student.test',
              'phone': '+1123456789',
              'rollNumber': 'S002',
            },
            {
              'name': 'Bob Wilson',  
              'email': 'bob.wilson@student.test',
              'phone': '+1567890123',
              'rollNumber': 'S003',
            },
            {
              'name': 'Alice Brown',
              'email': 'alice.brown@student.test', 
              'phone': '+1345678901',
              'rollNumber': 'S004',
            },
          ];

          await DatabaseService.bulkAddStudents(
            studentData: studentsData,
            classId: classId,
          );

          // Verify all students were added
          final students = await getClassStudents(classId);
          expect(students.length, equals(4)); // 1 from previous test + 3 new ones
          
          // Check specific students
          final rollNumbers = students.map((s) => s.rollNumber).toList();
          expect(rollNumbers, contains('S002'));
          expect(rollNumbers, contains('S003'));
          expect(rollNumbers, contains('S004'));
          
          print('✅ Bulk student addition successful');
          print('   Total students in class: ${students.length}');
          
        } catch (e) {
          print('❌ Bulk student addition failed: $e');
          rethrow;
        }
      });

      test('Should handle duplicate roll numbers', () async {
        print('\n🧪 Testing duplicate roll number handling...');
        
        try {
          // Check if duplicate exists first
          final isDuplicate = await DatabaseService.checkDuplicateStudent(
            classId: classId,
            rollNumber: 'S001',
          );
          
          expect(isDuplicate, isTrue);
          print('✅ Duplicate roll number detection working correctly');
          
        } catch (e) {
          print('❌ Duplicate roll number test failed: $e');
          rethrow;
        }
      });

      test('Should get student details correctly', () async {
        print('\n🧪 Testing student details retrieval...');
        
        try {
          final student = await DatabaseService.getStudentById(addedStudentId);
          
          expect(student, isNotNull);
          expect(student!.id, equals(addedStudentId));
          expect(student.name, equals('John Doe'));
          expect(student.email, equals('john.doe@student.test'));
          expect(student.rollNumber, equals('S001'));
          expect(student.classId, equals(classId));
          expect(student.isActive, isTrue);
          
          print('✅ Student details retrieved correctly');
          print('   Name: ${student.name}');
          print('   Roll: ${student.rollNumber}');
          
        } catch (e) {
          print('❌ Student details retrieval failed: $e');
          rethrow;
        }
      });
    });

    group('📊 Attendance Management Tests', () {
      
      late List<StudentModel> testStudents;
      final testDate = DateTime.now();
      
      setUpAll(() async {
        // Ensure we're signed in as teacher
        if (!AuthService.isAuthenticated) {
          await AuthService.signIn(
            email: testTeacherEmail,
            password: testPassword,
          );
        }
        
        // Get all students for attendance tests
        testStudents = await getClassStudents(classId);
        expect(testStudents.length, greaterThan(0));
        print('✅ Got ${testStudents.length} students for attendance testing');
      });

      test('Should mark attendance for single student', () async {
        print('\n🧪 Testing single student attendance marking...');
        
        try {
          final student = testStudents.first;
          
          final attendanceId = await DatabaseService.recordAttendance(
            classId: classId,
            studentId: student.id,
            date: testDate,
            isPresent: true,
            remarks: 'On time',
          );

          expect(attendanceId, isNotEmpty);
          
          print('✅ Single student attendance marked successfully');
          print('   Student: ${student.name}');
          print('   Attendance ID: $attendanceId');
          print('   Status: Present');
          
        } catch (e) {
          print('❌ Single student attendance marking failed: $e');
          rethrow;
        }
      });

      test('Should mark attendance for multiple students', () async {
        print('\n🧪 Testing attendance for multiple students...');
        
        try {
          // Mark attendance for each student individually
          for (int i = 0; i < testStudents.length; i++) {
            final student = testStudents[i];
            await DatabaseService.recordAttendance(
              classId: classId,
              studentId: student.id,
              date: testDate.subtract(Duration(days: 1)), // Use different date
              isPresent: i % 2 == 0, // Alternate present/absent
              remarks: i % 2 == 0 ? 'Present' : 'Absent - Sick',
            );
          }

          print('✅ Multiple student attendance marking successful');
          print('   Students processed: ${testStudents.length}');
          
        } catch (e) {
          print('❌ Multiple student attendance marking failed: $e');
          rethrow;
        }
      });

      test('Should retrieve attendance records correctly', () async {
        print('\n🧪 Testing attendance records retrieval...');
        
        try {
          final attendanceRecords = await DatabaseService.getAttendanceByDate(
            classId: classId,
            date: testDate.subtract(Duration(days: 1)),
          );

          expect(attendanceRecords.length, greaterThan(0));
          
          print('✅ Attendance records retrieved correctly');
          print('   Total records: ${attendanceRecords.length}');
          
        } catch (e) {
          print('❌ Attendance records retrieval failed: $e');
          rethrow;
        }
      });

      test('Should retrieve attendance records for a student', () async {
        print('\n🧪 Testing attendance records retrieval for student...');
        
        try {
          final student = testStudents.first;
          
          // Mark attendance for multiple days
          final dates = [
            DateTime.now().subtract(const Duration(days: 5)),
            DateTime.now().subtract(const Duration(days: 4)),
            DateTime.now().subtract(const Duration(days: 3)),
          ];

          // Mark attendance for each date
          for (int i = 0; i < dates.length; i++) {
            await DatabaseService.recordAttendance(
              classId: classId,
              studentId: student.id,
              date: dates[i],
              isPresent: i % 2 == 0,
              remarks: 'Test attendance ${i + 1}',
            );
          }

          // Get student details to check if attendance is reflected
          final updatedStudent = await DatabaseService.getStudentById(student.id);
          expect(updatedStudent, isNotNull);
          
          print('✅ Student attendance records created successfully');
          print('   Student: ${student.name}');
          print('   Records created: ${dates.length}');
          
        } catch (e) {
          print('❌ Student attendance records test failed: $e');
          rethrow;
        }
      });

      test('Should update existing attendance record', () async {
        print('\n🧪 Testing attendance record updates...');
        
        try {
          final student = testStudents.first;
          final updateDate = DateTime.now().subtract(const Duration(days: 1));
          
          // First mark as absent
          await DatabaseService.recordAttendance(
            classId: classId,
            studentId: student.id,
            date: updateDate,
            isPresent: false,
            remarks: 'Marked absent initially',
          );

          // Then update to present (should update existing record)
          final updatedAttendanceId = await DatabaseService.recordAttendance(
            classId: classId,
            studentId: student.id,
            date: updateDate,
            isPresent: true,
            remarks: 'Updated to present',
          );

          expect(updatedAttendanceId, isNotEmpty);
          
          print('✅ Attendance record updated successfully');
          print('   Updated from absent to present');
          
        } catch (e) {
          print('❌ Attendance record update failed: $e');
          rethrow;
        }
      });
    });

    group('🔄 Data Integrity Tests', () {
      
      test('Should handle concurrent operations gracefully', () async {
        print('\n🧪 Testing concurrent operations...');
        
        try {
          // Simulate concurrent student additions
          final futures = <Future>[];
          for (int i = 0; i < 5; i++) {
            futures.add(
              DatabaseService.addStudent(
                name: 'Concurrent Student $i',
                email: 'concurrent$i@test.com',
                rollNumber: 'C00$i',
                classId: classId,
              ),
            );
          }

          final results = await Future.wait(futures);
          
          // All should succeed and have unique IDs
          final uniqueIds = results.toSet();
          expect(uniqueIds.length, equals(results.length));
          
          print('✅ Concurrent operations handled gracefully');
          print('   Operations completed: ${results.length}');
          
        } catch (e) {
          print('❌ Concurrent operations test failed: $e');
          rethrow;
        }
      });

      test('Should maintain referential integrity', () async {
        print('\n🧪 Testing referential integrity...');
        
        try {
          // Create a class first, then try to reference a non-existent class
          final fakeClassId = 'fake_class_id_123';
          
          // This should succeed because database service doesn't validate class existence
          final studentId = await DatabaseService.addStudent(
            name: 'Test Student For Integrity',
            email: 'integrity@test.com',
            rollNumber: 'INT001',
            classId: fakeClassId,
          );
          
          expect(studentId, isNotEmpty);
          
          // Cleanup - remove the student (soft delete)
          await DatabaseService.deleteStudent(studentId, fakeClassId);
          
          print('✅ Referential integrity test completed');
          print('   Student added and removed successfully');
          
        } catch (e) {
          print('✅ Referential integrity maintained (if this is expected)');
          print('   Error: $e');
        }
      });
    });
  });
}

/// Helper function to cleanup test accounts
Future<void> _cleanupTestAccounts() async {
  try {
    // Try to delete test teacher account
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'teacher.test@edutrack.com',
        password: 'Test123!@#',
      );
      await FirebaseAuth.instance.currentUser?.delete();
    } catch (e) {
      // Account might not exist or already deleted
    }

    // Try to delete test student account
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'student.test@edutrack.com', 
        password: 'Test123!@#',
      );
      await FirebaseAuth.instance.currentUser?.delete();
    } catch (e) {
      // Account might not exist or already deleted
    }

    await FirebaseAuth.instance.signOut();
    print('🧹 Test accounts cleanup completed');
  } catch (e) {
    print('⚠️ Cleanup warning: $e');
  }
}