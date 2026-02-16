import 'package:flutter/foundation.dart';
import '../models/attendance_model.dart';
import '../services/database_service.dart';

/// Attendance Provider - Manages attendance state
class AttendanceProvider extends ChangeNotifier {
  List<AttendanceModel> _attendanceRecords = [];
  bool _isLoading = false;
  String? _error;

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
    if (records.isEmpty) return 0.0;
    int presentDays = records.where((r) => r.isPresent).length;
    return (presentDays / records.length) * 100;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
