import 'package:cloud_firestore/cloud_firestore.dart';
import 'location_data.dart';

class StudyItem {
  final String id;
  final String userId;
  final String title;
  final String description;
  final LocationData? location;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isCompleted;

  StudyItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.location,
    required this.createdAt,
    this.updatedAt,
    this.isCompleted = false,
  });

  // Convert to Firestore-compatible Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'location': location?.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isCompleted': isCompleted,
    };
  }

  // Create from Firestore document
  factory StudyItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudyItem(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      location: data['location'] != null 
          ? LocationData.fromMap(data['location'] as Map<String, dynamic>)
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isCompleted: data['isCompleted'] as bool? ?? false,
    );
  }

  // Copy with method for updates
  StudyItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    LocationData? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
  }) {
    return StudyItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
