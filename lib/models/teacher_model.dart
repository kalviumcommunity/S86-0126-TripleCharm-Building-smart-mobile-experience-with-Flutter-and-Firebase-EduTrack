import 'package:cloud_firestore/cloud_firestore.dart';

/// Teacher model for EduTrack
class Teacher {
  final String teacherId;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;

  Teacher({
    required this.teacherId,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
  });

  /// Convert Teacher to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt,
    };
  }

  /// Create Teacher from Firestore document
  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      teacherId: json['teacherId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create a copy with modified fields
  Teacher copyWith({
    String? teacherId,
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
  }) {
    return Teacher(
      teacherId: teacherId ?? this.teacherId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
