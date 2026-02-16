import 'package:cloud_firestore/cloud_firestore.dart';

/// Attendance record model
class AttendanceModel {
  final String id;
  final String classId;
  final String studentId;
  final DateTime date;
  final String dateString; // YYYY-MM-DD format for easy querying
  final bool isPresent;
  final String? remarks;
  final DateTime recordedAt;

  const AttendanceModel({
    required this.id,
    required this.classId,
    required this.studentId,
    required this.date,
    String? dateString,
    required this.isPresent,
    this.remarks,
    required this.recordedAt,
  }) : dateString = dateString ?? '';

  /// Convert AttendanceModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'studentId': studentId,
      'date': date.toIso8601String(),
      'dateString': dateString.isEmpty ? date.toIso8601String().split('T')[0] : dateString,
      'isPresent': isPresent,
      'remarks': remarks,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  /// Create AttendanceModel from JSON
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String? ?? '',
      classId: json['classId'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : (json['date'] is String
              ? DateTime.parse(json['date'] as String)
              : DateTime.now()),
      dateString: json['dateString'] as String?,
      isPresent: json['isPresent'] as bool? ?? false,
      remarks: json['remarks'] as String?,
      recordedAt: json['recordedAt'] is Timestamp
          ? (json['recordedAt'] as Timestamp).toDate()
          : (json['recordedAt'] is String
              ? DateTime.parse(json['recordedAt'] as String)
              : DateTime.now()),
    );
  }

  /// Create a copy with modifications
  AttendanceModel copyWith({
    String? id,
    String? classId,
    String? studentId,
    DateTime? date,
    String? dateString,
    bool? isPresent,
    String? remarks,
    DateTime? recordedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      dateString: dateString ?? this.dateString,
      isPresent: isPresent ?? this.isPresent,
      remarks: remarks ?? this.remarks,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  String toString() => 'AttendanceModel(studentId: $studentId, date: $date, isPresent: $isPresent)';
}

