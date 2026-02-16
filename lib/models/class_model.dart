import 'package:cloud_firestore/cloud_firestore.dart';

/// Class model for teacher's classes
class ClassModel {
  final String id;
  final String name;
  final String teacherId;
  final String? description;
  final int? studentCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ClassModel({
    required this.id,
    required this.name,
    required this.teacherId,
    this.description,
    this.studentCount,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert ClassModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teacherId': teacherId,
      'description': description,
      'studentCount': studentCount ?? 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create ClassModel from JSON
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Class',
      teacherId: json['teacherId']?.toString() ?? '',
      description: json['description']?.toString(),
      studentCount: json['studentCount'] is int 
          ? json['studentCount'] as int 
          : (json['studentCount'] is String ? int.tryParse(json['studentCount']) : 0),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : (json['createdAt'] is String
              ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
              : DateTime.now()),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : (json['updatedAt'] is String
              ? DateTime.tryParse(json['updatedAt'] as String)
              : null),
    );
  }

  /// Create a copy with modifications
  ClassModel copyWith({
    String? id,
    String? name,
    String? teacherId,
    String? description,
    int? studentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      description: description ?? this.description,
      studentCount: studentCount ?? this.studentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convenience getters for compatibility
  String get classId => id;
  String get className => name;

  @override
  String toString() => 'ClassModel(id: $id, name: $name)';
}