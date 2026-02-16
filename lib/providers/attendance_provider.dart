import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/attendance_model.dart';
import '../models/student_model.dart';
import '../services/database_service.dart';

/// Attendance Provider - Manages attendance state
class AttendanceProvider extends ChangeNotifier {
  List<AttendanceModel> _attendanceRecords = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<AttendanceModel>>? _attendanceSubscription;

  // Getters  
  List<AttendanceModel> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Record attendance
  Future<bool> recordAttendance({
    required String classId,
    required String studentId,
    required DateTime date,
    required bool isPresent,
    String? remarks,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DatabaseService.recordAttendance(
        classId: classId,
        studentId: studentId,
        date: date,
        isPresent: isPresent,
        remarks: remarks,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to record attendance: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get student's attendance records stream
  Stream<List<AttendanceModel>> getStudentAttendanceStream(String studentId) {
    return DatabaseService.getStudentAttendanceStream(studentId);
  }

  /// Load student's attendance records
  void loadStudentAttendance(String studentId) {
    DatabaseService.getStudentAttendanceStream(studentId).listen((records) {
      _attendanceRecords = records;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = 'Failed to load attendance records';
      notifyListeners();
    });
  }

  /// Get attendance by date
  Future<List<AttendanceModel>> getAttendanceByDate({
    required String classId,
    required DateTime date,
  }) async {
    try {
      return await DatabaseService.getAttendanceByDate(
        classId: classId,
        date: date,
      );
    } catch (e) {
      _error = 'Failed to load attendance: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  /// Update attendance record
  Future<bool> updateAttendance({
    required String attendanceId,
    required bool isPresent,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DatabaseService.updateAttendance(attendanceId, isPresent);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update attendance: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Calculate attendance percentage
  double getAttendancePercentage(List<AttendanceModel> records) {
    if (records.isEmpty) {
      if (kDebugMode) print('📊 [ATTENDANCE PROVIDER] No attendance records to calculate percentage');
      return 0.0;
    }
    
    int presentDays = records.where((r) => r.isPresent).length;
    int totalDays = records.length;
    double percentage = (presentDays / totalDays) * 100;
    
    if (kDebugMode) print('📊 [ATTENDANCE PROVIDER] Calculating: $presentDays present / $totalDays total = ${percentage.toStringAsFixed(2)}%');
    
    return percentage;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Alias for student attendance records
  List<AttendanceModel> get studentAttendance => _attendanceRecords;

  double? _classAveragePercent;
  int _totalPresent = 0;
  int _totalAbsent = 0;
  StreamSubscription<List<StudentModel>>? _classStudentsSubscription;

  /// Returns last computed class average attendance percent
  double? get classAveragePercent => _classAveragePercent;
  int get totalPresent => _totalPresent;
  int get totalAbsent => _totalAbsent;


  /// Compute and load class average attendance percent with real-time updates
  void getClassAttendanceSummary(String classId) {
    if (kDebugMode) print('📊 [ATTENDANCE] Setting up real-time attendance summary for: $classId');
    
    // Cancel previous subscription
    _classStudentsSubscription?.cancel();
    
    // Listen to students stream for real-time updates
    _classStudentsSubscription = DatabaseService.getClassStudentsStream(classId).listen((students) async {
      try {
        if (students.isEmpty) {
          if (kDebugMode) print('📊 [ATTENDANCE] No students found in class');
          _classAveragePercent = 0.0;
          _totalPresent = 0;
          _totalAbsent = 0;
          notifyListeners();
          return;
        }

        // Get actual attendance records for accurate calculation
        final records = await DatabaseService.getClassAttendanceRecords(classId);
        _totalPresent = records.where((r) => r.isPresent).length;
        _totalAbsent = records.where((r) => !r.isPresent).length;

        // Calculate real-time class average based on actual attendance records
        if (records.isEmpty) {
          _classAveragePercent = 100.0; // Default to 100% if no records yet
        } else {
          // Group records by student to calculate each student's percentage
          final Map<String, List<AttendanceModel>> studentRecords = {};
          for (var record in records) {
            if (!studentRecords.containsKey(record.studentId)) {
              studentRecords[record.studentId] = [];
            }
            studentRecords[record.studentId]!.add(record);
          }
          
          // Calculate average percentage across all students
          double totalPercent = 0.0;
          int studentsWithRecords = 0;
          
          for (var student in students) {
            final studentAttendance = studentRecords[student.id] ?? [];
            if (studentAttendance.isNotEmpty) {
              final presentDays = studentAttendance.where((r) => r.isPresent).length;
              final studentPercent = (presentDays / studentAttendance.length) * 100;
              totalPercent += studentPercent;
              studentsWithRecords++;
            } else {
              // Student with no records counts as 100% attendance
              totalPercent += 100.0;
              studentsWithRecords++;
            }
          }
          
          _classAveragePercent = studentsWithRecords > 0 ? totalPercent / studentsWithRecords : 0.0;
        }

        if (kDebugMode) {
          print('📊 [ATTENDANCE] Class average (real-time): ${_classAveragePercent?.toStringAsFixed(1)}%');
          print('📊 [ATTENDANCE] Total present: $_totalPresent, Total absent: $_totalAbsent');
          print('📊 [ATTENDANCE] Students with attendance: ${students.length}/${students.length}');
        }

        notifyListeners();
      } catch (e) {
        if (kDebugMode) print('❌ [ATTENDANCE] Error computing summary: $e');
        _error = 'Failed to compute class attendance summary: ${e.toString()}';
        _classAveragePercent = 0.0;
        notifyListeners();
      }
    }, onError: (e) {
      if (kDebugMode) print('❌ [ATTENDANCE] Stream error: $e');
      _error = e.toString();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _classStudentsSubscription?.cancel();
    _attendanceSubscription?.cancel();
    super.dispose();
  }

  /// Mark attendance for a student
  Future<void> markAttendance({
    required String teacherId,
    required String classId,
    required String studentId,
    required DateTime date,
    required bool isPresent,
    String? remarks,
  }) async {
    await recordAttendance(
      classId: classId,
      studentId: studentId,
      date: date,
      isPresent: isPresent,
      remarks: remarks,
    );
  }
}
