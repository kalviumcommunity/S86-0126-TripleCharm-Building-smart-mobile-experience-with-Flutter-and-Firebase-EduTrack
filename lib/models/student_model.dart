import 'package:cloud_firestore/cloud_firestore.dart';

/// Student model
class StudentModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? rollNumber;
  final String classId;
  final String? userId; // Firebase Auth UID when student creates account
  final double? attendancePercentage;
  final double? averageMarks;
  final DateTime enrolledAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String feesStatus;

  const StudentModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.rollNumber,
    required this.classId,
    this.userId,
    this.attendancePercentage,
    this.averageMarks,
    required this.enrolledAt,
    this.updatedAt,
    this.isActive = true,
    this.feesStatus = 'Pending',
  });

  /// Convert StudentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'rollNumber': rollNumber,
      'classId': classId,
      'userId': userId,
      'attendancePercentage': attendancePercentage ?? 0.0,
      'averageMarks': averageMarks ?? 0.0,
      'enrolledAt': enrolledAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'feesStatus': feesStatus,
    };
  }

  /// Create StudentModel from JSON
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      rollNumber: json['rollNumber'] as String?,
      classId: json['classId'] as String? ?? '',
      userId: json['userId'] as String?,
      attendancePercentage: (json['attendancePercentage'] as num?)?.toDouble(),
      averageMarks: (json['averageMarks'] as num?)?.toDouble(),
      enrolledAt: json['enrolledAt'] is Timestamp
          ? (json['enrolledAt'] as Timestamp).toDate()
          : (json['enrolledAt'] is String
              ? DateTime.parse(json['enrolledAt'] as String)
              : DateTime.now()),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : (json['updatedAt'] is String
              ? DateTime.parse(json['updatedAt'] as String)
              : null),
      isActive: json['isActive'] as bool? ?? true,
      feesStatus: json['feesStatus'] as String? ?? 'Pending',
    );
  }

  /// Create a copy with modifications
  StudentModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? rollNumber,
    String? classId,
    double? attendancePercentage,
    double? averageMarks,
    DateTime? enrolledAt,
    DateTime? updatedAt,
    bool? isActive,
    String? feesStatus,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      rollNumber: rollNumber ?? this.rollNumber,
      classId: classId ?? this.classId,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      averageMarks: averageMarks ?? this.averageMarks,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      feesStatus: feesStatus ?? this.feesStatus,
    );
  }

  /// Convenience getters for compatibility
  String get studentId => id;

  @override
  String toString() => 'StudentModel(id: $id, name: $name, email: $email)';
}
