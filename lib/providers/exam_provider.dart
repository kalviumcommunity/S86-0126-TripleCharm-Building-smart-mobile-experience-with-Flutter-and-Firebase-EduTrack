import 'package:flutter/foundation.dart';
import '../models/exam_model.dart';
import '../models/marks_model.dart';
import '../services/firebase_service.dart';

/// Exam Provider - Manages exam and marks data
class ExamProvider extends ChangeNotifier {
  List<Exam> _exams = [];
  List<MarksModel> _marks = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Exam> get exams => _exams;
  List<MarksModel> get marks => _marks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch exams for a class
  void fetchClassExams(String classId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      FirebaseService.getClassExamsStream(classId).listen(
        (examList) {
          _exams = examList;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
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

  /// Fetch exams for teacher
  void fetchTeacherExams(String teacherId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      FirebaseService.getTeacherExamsStream(teacherId).listen(
        (examList) {
          _exams = examList;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
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

  /// Create exam
  Future<bool> createExam({
    required String teacherId,
    required String classId,
    required String examName,
    required DateTime date,
    required int totalMarks,
  }) async {
    try {
      await FirebaseService.createExam(
        teacherId: teacherId,
        classId: classId,
        examName: examName,
        date: date,
        totalMarks: totalMarks,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete exam
  Future<bool> deleteExam(String examId) async {
    try {
      await FirebaseService.deleteExam(examId);
      _exams.removeWhere((e) => e.examId == examId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Fetch marks for an exam
  void fetchExamMarks(String examId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      FirebaseService.getExamMarksStream(examId).listen(
        (marksList) {
          _marks = marksList;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
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

  /// Add marks for student
  Future<bool> addMarks({
    required String examId,
    required String studentId,
    required int marksObtained,
  }) async {
    try {
      await FirebaseService.addMarks(
        examId: examId,
        studentId: studentId,
        marksObtained: marksObtained,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update marks
  Future<bool> updateMarks(
    String markId,
    int marksObtained,
  ) async {
    try {
      await FirebaseService.updateMarks(markId, marksObtained);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Calculate exam statistics
  Map<String, dynamic> getExamStats(Exam exam) {
    if (_marks.isEmpty) {
      return {
        'average': 0,
        'highest': 0,
        'lowest': 0,
        'percentage': 0,
      };
    }

    final obtainedMarks = _marks.map((m) => m.obtainedMarks).toList();
    final average = obtainedMarks.reduce((a, b) => a + b) / obtainedMarks.length;
    final highest = obtainedMarks.reduce((a, b) => a > b ? a : b);
    final lowest = obtainedMarks.reduce((a, b) => a < b ? a : b);
    final percentage = ((average / exam.totalMarks) * 100).toInt();

    return {
      'average': average,
      'highest': highest,
      'lowest': lowest,
      'percentage': percentage,
    };
  }
}
