import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class to populate sample data into Firestore for testing
/// Run this once to populate your Firestore with realistic test data
class FirestoreSampleDataHelper {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Add sample students to Firestore
  static Future<void> addSampleStudents() async {
    try {
      final centerId = 'center_001';

      final students = [
        {
          'firstName': 'Asha',
          'lastName': 'Sharma',
          'rollNumber': 'STU-2024-001',
          'email': 'asha.sharma@email.com',
          'phoneNumber': '+91-9876543210',
          'gender': 'F',
          'centerId': centerId,
          'enrollmentStatus': 'active',
          'joiningDate': Timestamp.fromDate(DateTime(2024, 1, 10)),
          'averageScore': 87.5,
          'totalAttendancePercentage': 92.5,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'firstName': 'Rajesh',
          'lastName': 'Kumar',
          'rollNumber': 'STU-2024-002',
          'email': 'rajesh.kumar@email.com',
          'phoneNumber': '+91-9123456789',
          'gender': 'M',
          'centerId': centerId,
          'enrollmentStatus': 'active',
          'joiningDate': Timestamp.fromDate(DateTime(2024, 1, 15)),
          'averageScore': 78.3,
          'totalAttendancePercentage': 85.0,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'firstName': 'Priya',
          'lastName': 'Singh',
          'rollNumber': 'STU-2024-003',
          'email': 'priya.singh@email.com',
          'phoneNumber': '+91-8765432109',
          'gender': 'F',
          'centerId': centerId,
          'enrollmentStatus': 'active',
          'joiningDate': Timestamp.fromDate(DateTime(2024, 1, 12)),
          'averageScore': 91.2,
          'totalAttendancePercentage': 95.0,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'firstName': 'Arjun',
          'lastName': 'Patel',
          'rollNumber': 'STU-2024-004',
          'email': 'arjun.patel@email.com',
          'phoneNumber': '+91-7654321098',
          'gender': 'M',
          'centerId': centerId,
          'enrollmentStatus': 'active',
          'joiningDate': Timestamp.fromDate(DateTime(2024, 1, 8)),
          'averageScore': 82.7,
          'totalAttendancePercentage': 88.0,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'firstName': 'Ananya',
          'lastName': 'Verma',
          'rollNumber': 'STU-2024-005',
          'email': 'ananya.verma@email.com',
          'phoneNumber': '+91-6543210987',
          'gender': 'F',
          'centerId': centerId,
          'enrollmentStatus': 'active',
          'joiningDate': Timestamp.fromDate(DateTime(2024, 2, 1)),
          'averageScore': 75.8,
          'totalAttendancePercentage': 80.0,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      final batch = _db.batch();
      
      for (var studentData in students) {
        final docRef = _db.collection('students').doc();
        batch.set(docRef, studentData);
      }

      await batch.commit();
      print('✅ Sample students added successfully!');
    } catch (e) {
      print('❌ Error adding sample students: $e');
    }
  }

  /// Add sample courses
  static Future<void> addSampleCourses() async {
    try {
      final centerId = 'center_001';

      final courses = [
        {
          'name': 'Mathematics - Class 10',
          'subject': 'Mathematics',
          'centerId': centerId,
          'level': 'Class 10',
          'instructorName': 'Rajesh Kumar',
          'capacity': 30,
          'enrolledCount': 5,
          'isActive': true,
          'startDate': Timestamp.fromDate(DateTime(2024, 1, 15)),
          'endDate': Timestamp.fromDate(DateTime(2024, 6, 30)),
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'English - Class 10',
          'subject': 'English',
          'centerId': centerId,
          'level': 'Class 10',
          'instructorName': 'Priya Singh',
          'capacity': 25,
          'enrolledCount': 5,
          'isActive': true,
          'startDate': Timestamp.fromDate(DateTime(2024, 1, 15)),
          'endDate': Timestamp.fromDate(DateTime(2024, 6, 30)),
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Science - Class 10',
          'subject': 'Science',
          'centerId': centerId,
          'level': 'Class 10',
          'instructorName': 'Arjun Patel',
          'capacity': 28,
          'enrolledCount': 5,
          'isActive': true,
          'startDate': Timestamp.fromDate(DateTime(2024, 1, 15)),
          'endDate': Timestamp.fromDate(DateTime(2024, 6, 30)),
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      final batch = _db.batch();
      
      for (var courseData in courses) {
        final docRef = _db.collection('courses').doc();
        batch.set(docRef, courseData);
      }

      await batch.commit();
      print('✅ Sample courses added successfully!');
    } catch (e) {
      print('❌ Error adding sample courses: $e');
    }
  }

  /// Add sample attendance records
  static Future<void> addSampleAttendance() async {
    try {
      final now = DateTime.now();
      final batch = _db.batch();

      final students = [
        'Asha Sharma',
        'Rajesh Kumar',
        'Priya Singh',
        'Arjun Patel',
        'Ananya Verma',
      ];

      // Add attendance for the last 10 days
      for (int dayOffset = 0; dayOffset < 10; dayOffset++) {
        final attendanceDate = now.subtract(Duration(days: dayOffset));
        final dateStr =
            '${attendanceDate.year}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}';

        for (var studentName in students) {
          // Randomly assign attendance status
          final random = DateTime.now().microsecond % 100;
          late bool isPresent;
          late String status;

          if (random < 80) {
            isPresent = true;
            status = 'present';
          } else if (random < 90) {
            isPresent = false;
            status = 'absent';
          } else {
            isPresent = true;
            status = 'late';
          }

          final attendanceRef = _db.collection('attendance').doc();
          batch.set(attendanceRef, {
            'studentName': studentName,
            'studentId': 'stu_${students.indexOf(studentName) + 1}',
            'courseId': 'course_math_001',
            'courseName': 'Mathematics - Class 10',
            'centerId': 'center_001',
            'date': dateStr,
            'isPresent': isPresent,
            'status': status,
            'timestamp': Timestamp.fromDate(attendanceDate),
          });
        }
      }

      await batch.commit();
      print('✅ Sample attendance records added successfully!');
    } catch (e) {
      print('❌ Error adding sample attendance: $e');
    }
  }

  /// Add sample progress/grade records
  static Future<void> addSampleProgress() async {
    try {
      final batch = _db.batch();

      final assessments = [
        {
          'title': 'Unit Test 1 - Algebra',
          'maxScore': 100,
          'type': 'unit_test',
        },
        {
          'title': 'Unit Test 2 - Geometry',
          'maxScore': 100,
          'type': 'unit_test',
        },
        {
          'title': 'Monthly Exam - January',
          'maxScore': 100,
          'type': 'monthly_exam',
        },
      ];

      final students = [
        ('Asha Sharma', [92, 88, 91]),
        ('Rajesh Kumar', [78, 81, 75]),
        ('Priya Singh', [95, 93, 94]),
        ('Arjun Patel', [82, 85, 80]),
        ('Ananya Verma', [76, 72, 71]),
      ];

      for (var (studentName, scores) in students) {
        for (int i = 0; i < assessments.length; i++) {
          final assessment = assessments[i];
          final score = scores[i];
          final percentage = (score / assessment['maxScore']! * 100).toInt();

          final progressRef = _db.collection('progress').doc();
          batch.set(progressRef, {
            'studentName': studentName,
            'studentId': 'stu_${students.indexWhere((s) => s.$1 == studentName) + 1}',
            'courseId': 'course_math_001',
            'courseName': 'Mathematics - Class 10',
            'centerId': 'center_001',
            'assessmentType': assessment['type'],
            'title': assessment['title'],
            'totalMarks': assessment['maxScore'],
            'score': score,
            'scorePercentage': percentage,
            'grade': percentage >= 90
                ? 'A'
                : percentage >= 80
                    ? 'B'
                    : percentage >= 70
                        ? 'C'
                        : 'D',
            'isPublished': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
      print('✅ Sample progress records added successfully!');
    } catch (e) {
      print('❌ Error adding sample progress: $e');
    }
  }

  /// Add sample coaching center
  static Future<void> addSampleCoachingCenter() async {
    try {
      await _db.collection('coachingCenters').doc('center_001').set({
        'name': 'Sharma Coaching Center',
        'address': '123 Education Lane, Jaipur',
        'city': 'Jaipur',
        'state': 'Rajasthan',
        'phoneNumber': '+91-9876543210',
        'email': 'contact@sharmacenter.com',
        'adminUserId': 'user_admin_001',
        'totalStudents': 5,
        'activeCourses': 3,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Sample coaching center added successfully!');
    } catch (e) {
      print('❌ Error adding sample coaching center: $e');
    }
  }

  /// Add sample user (teacher/admin)
  static Future<void> addSampleUsers() async {
    try {
      final users = [
        {
          'email': 'rajesh.teacher@gmail.com',
          'displayName': 'Rajesh Kumar',
          'role': 'teacher',
          'centerId': 'center_001',
          'departmentAssigned': 'Mathematics',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'email': 'priya.teacher@gmail.com',
          'displayName': 'Priya Singh',
          'role': 'teacher',
          'centerId': 'center_001',
          'departmentAssigned': 'English',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'email': 'admin@sharmacenter.com',
          'displayName': 'Admin User',
          'role': 'admin',
          'centerId': 'center_001',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      final batch = _db.batch();
      
      for (var userData in users) {
        final docRef = _db.collection('users').doc();
        batch.set(docRef, userData);
      }

      await batch.commit();
      print('✅ Sample users added successfully!');
    } catch (e) {
      print('❌ Error adding sample users: $e');
    }
  }

  /// Main function to add all sample data at once
  static Future<void> initializeSampleData() async {
    print('🔄 Initializing Firestore with sample data...');
    
    try {
      await addSampleCoachingCenter();
      await addSampleUsers();
      await addSampleStudents();
      await addSampleCourses();
      await addSampleAttendance();
      await addSampleProgress();
      
      print('✅ All sample data initialized successfully!');
    } catch (e) {
      print('❌ Error during initialization: $e');
    }
  }

  /// Clear all collections (use with caution!)
  static Future<void> clearAllData() async {
    print('⚠️  Clearing all Firestore data...');
    
    try {
      final collections = [
        'students',
        'courses',
        'attendance',
        'progress',
        'users',
        'coachingCenters',
      ];

      for (var collection in collections) {
        final snapshot = await _db.collection(collection).get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        print('✅ Cleared $collection');
      }
      
      print('✅ All data cleared successfully!');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }
}

// Usage in main.dart or a test button:
// FirestoreSampleDataHelper.initializeSampleData();
