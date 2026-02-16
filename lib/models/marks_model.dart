
import 'package:cloud_firestore/cloud_firestore.dart';

/// Marks model for student test/exam results
class MarksModel {
  final String id;
  final String classId;
  final String testName;
  final String subject; // Subject: Hindi, English, Maths, Biology, Science, Social
  final String studentId;
  final double obtainedMarks;
  final double totalMarks;
  final DateTime recordedAt;
  final DateTime? updatedAt;

  const MarksModel({
    required this.id,
    required this.classId,
    required this.testName,
    required this.subject,
    required this.studentId,
    required this.obtainedMarks,
    required this.totalMarks,
    required this.recordedAt,
    this.updatedAt,
  });

  /// Get percentage
  double get percentage => (obtainedMarks / totalMarks) * 100;

  /// Get grade
  String get grade {
    final pct = percentage;
    if (pct >= 90) return 'A+';
    if (pct >= 80) return 'A';
    if (pct >= 70) return 'B';
    if (pct >= 60) return 'C';
    if (pct >= 50) return 'D';
    return 'F';
  }

  /// Alias for compatibility
  double? get marksObtained => obtainedMarks;

  /// Convert MarksModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'testName': testName,
      'subject': subject,
      'studentId': studentId,
      'obtainedMarks': obtainedMarks,
      'totalMarks': totalMarks,
      'recordedAt': recordedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create MarksModel from JSON
  factory MarksModel.fromJson(Map<String, dynamic> json) {
    return MarksModel(
      id: json['id'] as String? ?? '',
      classId: json['classId'] as String? ?? '',
      testName: json['testName'] as String? ?? '',
      subject: json['subject'] as String? ?? 'General',
      studentId: json['studentId'] as String? ?? '',
      obtainedMarks: (json['obtainedMarks'] as num?)?.toDouble() ?? 0.0,
      totalMarks: (json['totalMarks'] as num?)?.toDouble() ?? 100.0,
      recordedAt: json['recordedAt'] is Timestamp
          ? (json['recordedAt'] as Timestamp).toDate()
          : (json['recordedAt'] is String
              ? DateTime.parse(json['recordedAt'] as String)
              : DateTime.now()),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : (json['updatedAt'] is String
              ? DateTime.parse(json['updatedAt'] as String)
              : null),
    );
  }

  /// Create a copy with modifications
  MarksModel copyWith({
    String? id,
    String? classId,
    String? testName,
    String? subject,
    String? studentId,
    double? obtainedMarks,
    double? totalMarks,
    DateTime? recordedAt,
    DateTime? updatedAt,
  }) {
    return MarksModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      testName: testName ?? this.testName,
      subject: subject ?? this.subject,
      studentId: studentId ?? this.studentId,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      totalMarks: totalMarks ?? this.totalMarks,
      recordedAt: recordedAt ?? this.recordedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'MarksModel(studentId: $studentId, testName: $testName, percentage: ${percentage.toStringAsFixed(2)}%)';
}
