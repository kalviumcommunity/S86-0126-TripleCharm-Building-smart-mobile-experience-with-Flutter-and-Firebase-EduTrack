import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/study_item.dart';
import '../models/location_data.dart';

class FirestoreCrudService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // CREATE - Add a new study item
  Future<String> createItem({
    required String title,
    required String description,
    LocationData? location,
  }) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final itemRef = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('items')
          .add({
        'userId': _userId,
        'title': title,
        'description': description,
        'location': location?.toMap(),
        'createdAt': Timestamp.now(),
        'updatedAt': null,
        'isCompleted': false,
      });

      return itemRef.id;
    } catch (e) {
      throw Exception('Failed to create item: $e');
    }
  }

  // READ - Get all items for current user
  Stream<List<StudyItem>> getItemsStream() {
    if (_userId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => StudyItem.fromFirestore(doc)).toList();
    });
  }

  // READ - Get a single item
  Future<StudyItem?> getItem(String itemId) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('items')
          .doc(itemId)
          .get();

      if (!doc.exists) return null;
      return StudyItem.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch item: $e');
    }
  }

  // UPDATE - Update an existing item
  Future<void> updateItem({
    required String itemId,
    required String title,
    required String description,
    LocationData? location,
    bool? isCompleted,
  }) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('items')
          .doc(itemId)
          .update({
        'title': title,
        'description': description,
        'location': location?.toMap(),
        'isCompleted': isCompleted,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  // DELETE - Delete an item
  Future<void> deleteItem(String itemId) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('items')
          .doc(itemId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  // Get items with location (for map view)
  Stream<List<StudyItem>> getItemsWithLocationStream() {
    if (_userId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('items')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StudyItem.fromFirestore(doc))
          .where((item) => item.location != null)
          .toList();
    });
  }

  // Toggle completion status
  Future<void> toggleItemCompletion(String itemId, bool currentStatus) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('items')
          .doc(itemId)
          .update({
        'isCompleted': !currentStatus,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to toggle completion: $e');
    }
  }

  // Batch delete items
  Future<void> deleteMultipleItems(List<String> itemIds) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      final batch = _firestore.batch();

      for (final itemId in itemIds) {
        final ref = _firestore
            .collection('users')
            .doc(_userId)
            .collection('items')
            .doc(itemId);
        batch.delete(ref);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete items: $e');
    }
  }
}
