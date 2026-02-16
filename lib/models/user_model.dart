import 'package:cloud_firestore/cloud_firestore.dart';

/// User model for both Teacher and Student
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role; // 'teacher' or 'student'
  final String? studentId; // Links to student record for students
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.studentId,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'studentId': studentId,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Normalize role to lowercase for consistency
    final rawRole = json['role'] as String? ?? 'student';
    final normalizedRole = rawRole.toLowerCase().trim();
    
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: normalizedRole,
      studentId: json['studentId'] as String?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : (json['createdAt'] is String
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now()),
      lastLogin: json['lastLogin'] is Timestamp
          ? (json['lastLogin'] as Timestamp).toDate()
          : (json['lastLogin'] is String
              ? DateTime.parse(json['lastLogin'] as String)
              : null),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Convenience getter for compatibility
  String get uid => id;

  /// Create a copy with modifications
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email, role: $role)';
}
