import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/student_model.dart';
import '../services/database_service.dart';

/// Student Provider - Manages students state
class StudentProvider extends ChangeNotifier {
  List<StudentModel> _students = [];
  List<StudentModel> _classStudents = [];
  StudentModel? _selectedStudent;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<StudentModel> get students => _students;
  List<StudentModel> get classStudents => _classStudents;
  StudentModel? get selectedStudent => _selectedStudent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get studentCount => _students.length;
  int get classStudentCount => _classStudents.length;
  
  // Subscription for teacher students stream
  StreamSubscription<List<StudentModel>>? _teacherStudentsSubscription;

  /// Add a new student to class
  Future<bool> addStudent({
    required String name,
    required String email,
    required String classId,
    String? phone,
    String? rollNumber,
    DateTime? admissionDate,
    String? feesStatus,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final studentId = await DatabaseService.addStudent(
        name: name,
        email: email,
        classId: classId,
        phone: phone,
        rollNumber: rollNumber,
        admissionDate: admissionDate,
        feesStatus: feesStatus,
      );

      if (studentId.isEmpty) {
        throw Exception('Failed to generate student ID');
      }

      // Sync the student count to ensure accuracy
      await DatabaseService.syncClassStudentCount(classId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add student: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) print('Error adding student: $e'); // Debug logging
      return false;
    }
  }

  StreamSubscription<List<StudentModel>>? _classStudentsSubscription;

  /// Load class students as stream
  void loadClassStudents(String classId) {
    if (kDebugMode) print('👥 [STUDENT] Loading students for class: $classId');
    _classStudentsSubscription?.cancel();
    _classStudents = []; // Clear previous list
    notifyListeners();

    _classStudentsSubscription = DatabaseService.getClassStudentsStream(classId).listen((studentList) {
      if (kDebugMode) {
        print('👥 [STUDENT] Received ${studentList.length} students');
        for (var student in studentList) {
          print('   - ${student.name}: attendance=${student.attendancePercentage}%, marks=${student.averageMarks}%');
        }
      }
      _classStudents = studentList;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      if (kDebugMode) print('❌ [STUDENT] Error loading students: $e');
      _error = 'Failed to load students';
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _classStudentsSubscription?.cancel();
    _teacherStudentsSubscription?.cancel();
    super.dispose();
  }

  /// Get student by Email
  Future<StudentModel?> loadStudentByEmail(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      final student = await DatabaseService.getStudentByEmail(email);
      _selectedStudent = student;
      _isLoading = false;
      notifyListeners();
      return student;
    } catch (e) {
      _error = 'Failed to load student data';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Get student by Firebase Auth userId
  Future<StudentModel?> loadStudentByUserId(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final student = await DatabaseService.getStudentByUserId(userId);
      _selectedStudent = student;
      _isLoading = false;
      notifyListeners();
      return student;
    } catch (e) {
      _error = 'Failed to load student data';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }


  /// Select a student
  void selectStudent(StudentModel student) {
    _selectedStudent = student;
    notifyListeners();
  }

  /// Update student
  Future<bool> updateStudent({
    required String studentId,
    required String name,
    required String email,
    String? phone,
  }) async {
    return updateStudentFields(
      studentId: studentId,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
      },
    );
  }

  /// Update arbitrary student fields
  Future<bool> updateStudentFields({
    required String studentId,
    required Map<String, dynamic> data,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DatabaseService.updateStudent(studentId, data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update student: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete student
  Future<bool> deleteStudent(String studentId, String classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DatabaseService.deleteStudent(studentId, classId);

      if (_selectedStudent?.id == studentId) {
        _selectedStudent = null;
      }

      // Sync the student count to ensure accuracy
      await DatabaseService.syncClassStudentCount(classId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete student: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Bulk add students
  Future<bool> bulkAddStudents({
    required String classId,
    required List<Map<String, String>> studentData,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DatabaseService.bulkAddStudents(
        classId: classId,
        studentData: studentData,
      );
      
      // Sync the student count to ensure accuracy
      await DatabaseService.syncClassStudentCount(classId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to bulk add students: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<StudentModel> _filteredStudents = [];
  List<StudentModel> get filteredStudents => _filteredStudents.isEmpty ? _students : _filteredStudents;

  /// Fetch students for a teacher
  void fetchTeacherStudents(String teacherId) {
    if (teacherId.isEmpty) {
      _students = [];
      notifyListeners();
      return;
    }

    if (kDebugMode) print('👥 [STUDENT] Setting up real-time teacher students stream for: $teacherId');
    _teacherStudentsSubscription?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _teacherStudentsSubscription = DatabaseService.getTeacherStudentsStream(teacherId).listen(
        (studentList) {
          if (kDebugMode) {
            print('👥 [STUDENT] Received ${studentList.length} students from all classes (real-time)');
            for (var student in studentList.take(3)) {
              print('   - ${student.name}: attendance=${student.attendancePercentage}%, marks=${student.averageMarks}%');
            }
            if (studentList.length > 3) {
              print('   ... and ${studentList.length - 3} more');
            }
          }
          _students = studentList;
          _filteredStudents = [];
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          if (kDebugMode) print('❌ [STUDENT] Error loading teacher students: $e');
          _error = e.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search students by name
  void searchStudents(String query) {
    if (query.isEmpty) {
      _filteredStudents = [];
      notifyListeners();
      return;
    }

    _filteredStudents = _students
        .where(
          (student) => student.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    notifyListeners();
  }
}
