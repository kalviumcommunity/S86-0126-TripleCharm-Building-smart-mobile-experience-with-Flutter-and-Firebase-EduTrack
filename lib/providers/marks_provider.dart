import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/marks_model.dart';
import '../models/student_model.dart';
import '../services/database_service.dart';

/// Marks Provider - Manages marks state
class MarksProvider extends ChangeNotifier {
  List<MarksModel> _marks = [];
  List<MarksModel> _classMarks = [];
  StreamSubscription<List<MarksModel>>? _classMarksSubscription;
  StreamSubscription<List<StudentModel>>? _studentsSubscription;
  double _classAverage = 0.0;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<MarksModel> get marks => _marks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Add marks for student
  Future<bool> addMarks({
    required String classId,
    required String testName,
    required String subject,
    required String studentId,
    required double obtainedMarks,
    required double totalMarks,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DatabaseService.addMarks(
        classId: classId,
        testName: testName,
        subject: subject,
        studentId: studentId,
        obtainedMarks: obtainedMarks,
        totalMarks: totalMarks,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add marks: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load student's marks
  void loadStudentMarks(String studentId) {
    DatabaseService.getStudentMarksStream(studentId).listen((marksList) {
      _marks = marksList;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = 'Failed to load marks';
      notifyListeners();
    });
  }

  /// Load class marks with real-time updates
  void loadClassMarks(String classId) {
    if (kDebugMode) print('📊 [MARKS] Setting up real-time marks stream for class: $classId');
    
    // Cancel previous subscriptions
    _classMarksSubscription?.cancel();
    _studentsSubscription?.cancel();
    
    // Listen to marks stream
    _classMarksSubscription = DatabaseService.getClassMarksStream(classId).listen((marksList) {
      if (kDebugMode) print('📊 [MARKS] Received ${marksList.length} marks records');
      _classMarks = marksList;
      _marks = marksList;
      _error = null;
      _recalculateClassAverage(classId);
      notifyListeners();
    }, onError: (e) {
      if (kDebugMode) print('❌ [MARKS] Error loading marks: $e');
      _error = 'Failed to load marks';
      notifyListeners();
    });
    
    // Also listen to students to calculate average from their averageMarks field
    _studentsSubscription = DatabaseService.getClassStudentsStream(classId).listen((students) {
      if (students.isEmpty) {
        _classAverage = 0.0;
      } else {
        double total = 0.0;
        int count = 0;
        for (var student in students) {
          if (student.averageMarks != null) {
            total += student.averageMarks!;
            count++;
          }
        }
        _classAverage = count > 0 ? total / count : 0.0;
      }
      if (kDebugMode) print('📊 [MARKS] Class average from students: ${_classAverage.toStringAsFixed(1)}%');
      notifyListeners();
    });
  }
  
  void _recalculateClassAverage(String classId) {
    // This is a backup calculation from marks records
    if (_classMarks.isEmpty) {
      return;
    }
    
    final Map<String, List<MarksModel>> grouped = {};
    for (var m in _classMarks) {
      grouped.putIfAbsent(m.studentId, () => []).add(m);
    }
    
    if (grouped.isEmpty) return;
    
    double totalAvg = 0.0;
    grouped.forEach((studentId, records) {
      double sum = 0.0;
      for (var r in records) {
        sum += r.percentage;
      }
      totalAvg += sum / records.length;
    });
    
    final calculatedAvg = totalAvg / grouped.length;
    if (kDebugMode) print('📊 [MARKS] Calculated average from marks: ${calculatedAvg.toStringAsFixed(1)}%');
  }

  /// Convenience getter for marks when used as student marks
  List<MarksModel> get studentMarks => _marks;

  /// Average percent for current marks list (class or student) with real-time calculation
  double get classAveragePercent {
    // Use the pre-calculated average from students
    if (_classAverage > 0.0) {
      return _classAverage;
    }
    // Fallback to marks-based calculation
    final avg = getAverageMarks(_marks);
    if (kDebugMode) print('📊 [MARKS] Class average fallback: ${avg.toStringAsFixed(1)}%');
    return avg;
  }

  /// Simple top students summary based on current marks list
  List<TopStudent> get topStudents {
    // Compute average percentage per studentId
    final Map<String, List<MarksModel>> grouped = {};
    for (var m in _marks) {
      grouped.putIfAbsent(m.studentId, () => []).add(m);
    }

    final List<TopStudent> list = [];
    grouped.forEach((studentId, records) {
      double total = 0;
      for (var r in records) {
        total += r.percentage;
      }
      final avg = records.isEmpty ? 0.0 : total / records.length;
      list.add(TopStudent(name: studentId, percentage: avg));
    });

    list.sort((a, b) => b.percentage.compareTo(a.percentage));
    return list.take(5).toList();
  }

  /// Grade distribution counts
  Map<String, int> get gradeDistribution {
    final Map<String, int> distribution = {
      'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0,
    };

    final Map<String, List<MarksModel>> grouped = {};
    for (var m in _marks) {
      grouped.putIfAbsent(m.studentId, () => []).add(m);
    }

    grouped.forEach((studentId, records) {
      double total = 0;
      for (var r in records) {
        total += r.percentage;
      }
      final avg = records.isEmpty ? 0.0 : total / records.length;
      
      if (avg >= 90) {
        distribution['A'] = distribution['A']! + 1;
      } else if (avg >= 80) {
        distribution['B'] = distribution['B']! + 1;
      } else if (avg >= 70) {
        distribution['C'] = distribution['C']! + 1;
      } else if (avg >= 60) {
        distribution['D'] = distribution['D']! + 1;
      } else {
        distribution['F'] = distribution['F']! + 1;
      }
    });

    return distribution;
  }


  /// Update marks
  Future<bool> updateMarks({
    required String marksId,
    required double obtainedMarks,
    required String studentId,
    required String classId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

  
    try {
      await DatabaseService.updateMarks(
        marksId,
        obtainedMarks,
        studentId,
        classId,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update marks: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete marks
  Future<bool> deleteMarks({
    required String marksId,
    required String studentId,
    required String classId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DatabaseService.deleteMarks(marksId, studentId, classId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete marks: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Calculate average marks
  double getAverageMarks(List<MarksModel> records) {
    if (records.isEmpty) return 0.0;
    double totalPercentage = 0.0;
    for (var mark in records) {
      totalPercentage += mark.percentage;
    }
    return totalPercentage / records.length;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class TopStudent {
  final String name;
  final double percentage;
  TopStudent({required this.name, required this.percentage});
}
