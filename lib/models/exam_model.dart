import 'package:cloud_firestore/cloud_firestore.dart';

/// Exam model for EduTrack
class Exam {
  final String examId;
  final String teacherId;
  final String classId;
  final String examName;
  final DateTime date;
  final int totalMarks;

  Exam({
    required this.examId,
    required this.teacherId,
    required this.classId,
    required this.examName,
    required this.date,
    required this.totalMarks,
  });

  /// Convert Exam to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'examId': examId,
      'teacherId': teacherId,
      'classId': classId,
      'examName': examName,
      'date': date,
      'totalMarks': totalMarks,
    };
  }

  /// Create Exam from Firestore document
  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      examId: json['examId'] ?? '',
      teacherId: json['teacherId'] ?? '',
      classId: json['classId'] ?? '',
      examName: json['examName'] ?? '',
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalMarks: json['totalMarks'] ?? 0,
    );
  }

  /// Create a copy with modified fields
  Exam copyWith({
    String? examId,
    String? teacherId,
    String? classId,
    String? examName,
    DateTime? date,
    int? totalMarks,
  }) {
    return Exam(
      examId: examId ?? this.examId,
      teacherId: teacherId ?? this.teacherId,
      classId: classId ?? this.classId,
      examName: examName ?? this.examName,
      date: date ?? this.date,
      totalMarks: totalMarks ?? this.totalMarks,
    );
  }
}
