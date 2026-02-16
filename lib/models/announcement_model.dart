import 'package:cloud_firestore/cloud_firestore.dart';

/// Announcement model
class AnnouncementModel {
  final String id;
  final String classId;
  final String teacherId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AnnouncementModel({
    required this.id,
    required this.classId,
    required this.teacherId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert AnnouncementModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'teacherId': teacherId,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create AnnouncementModel from JSON
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String? ?? '',
      classId: json['classId'] as String? ?? '',
      teacherId: json['teacherId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : (json['createdAt'] is String
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now()),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : (json['updatedAt'] is String
              ? DateTime.parse(json['updatedAt'] as String)
              : null),
    );
  }

  /// Create a copy with modifications
  AnnouncementModel copyWith({
    String? id,
    String? classId,
    String? teacherId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      teacherId: teacherId ?? this.teacherId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'AnnouncementModel(id: $id, title: $title)';
}
