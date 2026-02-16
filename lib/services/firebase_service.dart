import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/teacher_model.dart';
import '../models/class_model.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../models/exam_model.dart';
import '../models/marks_model.dart';
import '../config/constants.dart';

/// Firebase Service - Handles all Firebase operations
class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const uuid = Uuid();

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  // ===== AUTHENTICATION =====

  /// Sign up with email and password
  static Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Create Firebase Auth user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create teacher document in Firestore
      Teacher teacher = Teacher(
        teacherId: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.teachersCollection)
          .doc(teacher.teacherId)
          .set(teacher.toJson());
    } catch (e) {
      rethrow;
    }
  }

  /// Login with email and password
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  static Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // ===== TEACHER OPERATIONS =====

  /// Get teacher data
  static Future<Teacher?> getTeacher(String teacherId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.teachersCollection)
          .doc(teacherId)
          .get();
      if (doc.exists) {
        return Teacher.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Update teacher data
  static Future<void> updateTeacher(String teacherId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.teachersCollection)
          .doc(teacherId)
          .update(data);
    } catch (e) {
      rethrow;
    }
  }

  // ===== CLASS OPERATIONS =====

  /// Create class
  static Future<String> createClass({
    required String teacherId,
    required String className,
    required String description,
  }) async {
    try {
      String classId = uuid.v4();
      ClassModel classModel = ClassModel(
        id: classId,
        name: className,
        teacherId: teacherId,
        description: description,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.classesCollection)
          .doc(classId)
          .set(classModel.toJson());
      return classId;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all classes for teacher
  static Stream<List<ClassModel>> getClassesStream(String teacherId) {
    return _firestore
        .collection(AppConstants.classesCollection)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ClassModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Update class
  static Future<void> updateClass(
    String classId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.classesCollection)
          .doc(classId)
          .update(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete class
  static Future<void> deleteClass(String classId) async {
    try {
      await _firestore
          .collection(AppConstants.classesCollection)
          .doc(classId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // ===== STUDENT OPERATIONS =====

  /// Add student
  static Future<String> addStudent({
    required String teacherId,
    required String classId,
    required String name,
    required String parentPhone,
    required DateTime admissionDate,
    required String feesStatus,
  }) async {
    try {
      String studentId = uuid.v4();
      StudentModel student = StudentModel(
        id: studentId,
        name: name,
        email: '', // Email can be added later
        phone: parentPhone,
        classId: classId,
        enrolledAt: admissionDate,
      );

      await _firestore
          .collection(AppConstants.studentsCollection)
          .doc(studentId)
          .set(student.toJson());
      return studentId;
    } catch (e) {
      rethrow;
    }
  }

  /// Get students for class
  static Stream<List<StudentModel>> getStudentsStream(String classId) {
    return _firestore
        .collection(AppConstants.studentsCollection)
        .where('classId', isEqualTo: classId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StudentModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get all students for teacher
  static Stream<List<StudentModel>> getTeacherStudentsStream(String teacherId) {
    return _firestore
        .collection(AppConstants.studentsCollection)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StudentModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Update student
  static Future<void> updateStudent(
    String studentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.studentsCollection)
          .doc(studentId)
          .update(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete student
  static Future<void> deleteStudent(String studentId) async {
    try {
      await _firestore
          .collection(AppConstants.studentsCollection)
          .doc(studentId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // ===== ATTENDANCE OPERATIONS =====

  /// Mark attendance for a student
  static Future<String> markAttendance({
    required String teacherId,
    required String classId,
    required String studentId,
    required DateTime date,
    required String status,
  }) async {
    try {
      String attendanceId = uuid.v4();
      AttendanceModel attendance = AttendanceModel(
        id: attendanceId,
        classId: classId,
        studentId: studentId,
        date: date,
        isPresent: status == 'present',
        recordedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.attendanceCollection)
          .doc(attendanceId)
          .set(attendance.toJson());
      return attendanceId;
    } catch (e) {
      rethrow;
    }
  }

  /// Get attendance for class on a date
  static Stream<List<AttendanceModel>> getClassAttendanceStream(
    String classId,
    DateTime date,
  ) {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection(AppConstants.attendanceCollection)
        .where('classId', isEqualTo: classId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AttendanceModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get student's attendance records
  static Future<List<AttendanceModel>> getStudentAttendance(String studentId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.attendanceCollection)
          .where('studentId', isEqualTo: studentId)
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => AttendanceModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ===== EXAM OPERATIONS =====

  /// Create exam
  static Future<String> createExam({
    required String teacherId,
    required String classId,
    required String examName,
    required DateTime date,
    required int totalMarks,
  }) async {
    try {
      String examId = uuid.v4();
      Exam exam = Exam(
        examId: examId,
        teacherId: teacherId,
        classId: classId,
        examName: examName,
        date: date,
        totalMarks: totalMarks,
      );

      await _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .set(exam.toJson());
      return examId;
    } catch (e) {
      rethrow;
    }
  }

  /// Get exams for class
  static Stream<List<Exam>> getClassExamsStream(String classId) {
    return _firestore
        .collection(AppConstants.examsCollection)
        .where('classId', isEqualTo: classId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Exam.fromJson(doc.data())).toList();
    });
  }

  /// Get exams for teacher
  static Stream<List<Exam>> getTeacherExamsStream(String teacherId) {
    return _firestore
        .collection(AppConstants.examsCollection)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Exam.fromJson(doc.data())).toList();
    });
  }

  /// Delete exam
  static Future<void> deleteExam(String examId) async {
    try {
      await _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // ===== MARKS OPERATIONS =====

  /// Add marks for student in exam
  static Future<String> addMarks({
    required String examId,
    required String studentId,
    required int marksObtained,
  }) async {
    try {
      String markId = uuid.v4();
      MarksModel marks = MarksModel(
        id: markId,
        classId: '', // Will need to be passed or fetched
        testName: '', // Will need to be passed or fetched
        subject: 'General', // Default subject
        studentId: studentId,
        obtainedMarks: marksObtained.toDouble(),
        totalMarks: 100.0, // Default, should be passed
        recordedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.marksCollection)
          .doc(markId)
          .set(marks.toJson());
      return markId;
    } catch (e) {
      rethrow;
    }
  }

  /// Get marks for exam
  static Stream<List<MarksModel>> getExamMarksStream(String examId) {
    return _firestore
        .collection(AppConstants.marksCollection)
        .where('examId', isEqualTo: examId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MarksModel.fromJson(doc.data())).toList();
    });
  }

  /// Get marks for student in exam
  static Future<MarksModel?> getStudentExamMarks(
    String studentId,
    String examId,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.marksCollection)
          .where('studentId', isEqualTo: studentId)
          .where('examId', isEqualTo: examId)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return MarksModel.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Update marks
  static Future<void> updateMarks(
    String markId,
    int marksObtained,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.marksCollection)
          .doc(markId)
          .update({'marksObtained': marksObtained});
    } catch (e) {
      rethrow;
    }
  }
}
