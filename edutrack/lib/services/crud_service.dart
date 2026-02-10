import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// CRUD Service for managing user-specific items in Firestore
/// 
/// Provides complete Create, Read, Update, Delete operations for user items
/// Each user's items are stored in: /users/{uid}/items/{itemId}
/// Security is enforced through:
/// - User authentication checks
/// - User ID validation
/// - Firestore security rules
class CrudService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's UID
  /// Throws exception if user is not authenticated
  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated. Please sign in first.');
    }
    return user.uid;
  }

  /// Get reference to current user's items collection
  CollectionReference<Map<String, dynamic>> get _userItems {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('items');
  }

  // ==================== CREATE OPERATION (C) ====================

  /// Create a new item for the current user
  /// 
  /// Parameters:
  ///   - title: Item title (required)
  ///   - description: Item description (optional)
  ///   - priority: Item priority level, 1-5 (default: 3)
  ///   - tags: List of tags for organization (optional)
  /// 
  /// Returns: Document ID of created item
  /// 
  /// Example:
  /// ```dart
  /// final itemId = await crudService.createItem(
  ///   title: 'My First Item',
  ///   description: 'This is a demo item',
  ///   priority: 4,
  ///   tags: ['important', 'work']
  /// );
  /// ```
  Future<String> createItem({
    required String title,
    String? description,
    int priority = 3,
    List<String>? tags,
  }) async {
    try {
      if (title.isEmpty) {
        throw Exception('Title cannot be empty');
      }

      if (priority < 1 || priority > 5) {
        throw Exception('Priority must be between 1 and 5');
      }

      final itemData = {
        'title': title,
        'description': description ?? '',
        'priority': priority,
        'tags': tags ?? [],
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _userItems.add(itemData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create item: $e');
    }
  }

  // ==================== READ OPERATION (R) ====================

  /// Get a single item by ID
  /// 
  /// Parameters:
  ///   - itemId: The document ID of the item
  /// 
  /// Returns: Item data as a map, or null if not found
  /// 
  /// Example:
  /// ```dart
  /// final item = await crudService.getItem('item123');
  /// if (item != null) {
  ///   print('Title: ${item['title']}');
  /// }
  /// ```
  Future<Map<String, dynamic>?> getItem(String itemId) async {
    try {
      final doc = await _userItems.doc(itemId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return {
            'id': doc.id,
            ...data,
          };
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get item: $e');
    }
  }

  /// Get all items for the current user
  /// Items are ordered by creation date (newest first)
  /// 
  /// Returns: List of items with their IDs
  /// 
  /// Example:
  /// ```dart
  /// final items = await crudService.getAllItems();
  /// for (var item in items) {
  ///   print('${item['id']}: ${item['title']}');
  /// }
  /// ```
  Future<List<Map<String, dynamic>>> getAllItems() async {
    try {
      final snapshot = await _userItems
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...?data,
            };
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get items: $e');
    }
  }

  /// Get items with filtering options
  /// 
  /// Parameters:
  ///   - isCompleted: Filter by completion status (optional)
  ///   - minPriority: Get items with priority >= minPriority (optional)
  ///   - tags: Get items with any of these tags (optional)
  ///   - limit: Maximum number of items to return (default: 100)
  /// 
  /// Returns: Filtered list of items
  /// 
  /// Example:
  /// ```dart
  /// final highPriority = await crudService.getItemsFiltered(
  ///   minPriority: 4,
  ///   isCompleted: false,
  ///   limit: 10
  /// );
  /// ```
  Future<List<Map<String, dynamic>>> getItemsFiltered({
    bool? isCompleted,
    int? minPriority,
    List<String>? tags,
    int limit = 100,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _userItems;

      // Apply filters
      if (isCompleted != null) {
        query = query.where('isCompleted', isEqualTo: isCompleted);
      }

      if (minPriority != null) {
        query = query.where('priority', isGreaterThanOrEqualTo: minPriority);
      }

      // For tags, we need to-array-contains any tag
      if (tags != null && tags.isNotEmpty) {
        for (String tag in tags) {
          query = query.where('tags', arrayContains: tag);
        }
      }

      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...?data,
            };
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get filtered items: $e');
    }
  }

  /// Stream items for real-time updates
  /// 
  /// Useful for StreamBuilder in UI for automatic updates
  /// when Firestore data changes
  /// 
  /// Returns: Stream of QuerySnapshot
  /// 
  /// Example:
  /// ```dart
  /// StreamBuilder(
  ///   stream: crudService.streamItems(),
  ///   builder: (context, snapshot) {
  ///     if (!snapshot.hasData) return CircularProgressIndicator();
  ///     final items = snapshot.data!.docs;
  ///     return ListView.builder(
  ///       itemCount: items.length,
  ///       itemBuilder: (_, i) {
  ///         final item = items[i].data();
  ///         return ListTile(title: Text(item['title']));
  ///       },
  ///     );
  ///   },
  /// )
  /// ```
  Stream<QuerySnapshot<Map<String, dynamic>>> streamItems() {
    return _userItems
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Stream filtered items for real-time updates
  /// 
  /// Same filtering options as getItemsFiltered()
  Stream<QuerySnapshot<Map<String, dynamic>>> streamItemsFiltered({
    bool? isCompleted,
    int? minPriority,
  }) {
    Query<Map<String, dynamic>> query = _userItems;

    if (isCompleted != null) {
      query = query.where('isCompleted', isEqualTo: isCompleted);
    }

    if (minPriority != null) {
      query = query.where('priority', isGreaterThanOrEqualTo: minPriority);
    }

    return query.orderBy('createdAt', descending: true).snapshots();
  }

  // ==================== UPDATE OPERATION (U) ====================

  /// Update an existing item
  /// 
  /// Parameters:
  ///   - itemId: The document ID to update
  ///   - updates: Map of fields to update
  /// 
  /// Note: The updatedAt timestamp is automatically set
  /// 
  /// Example:
  /// ```dart
  /// await crudService.updateItem(
  ///   'item123',
  ///   {
  ///     'title': 'Updated Title',
  ///     'priority': 5,
  ///     'isCompleted': true,
  ///   }
  /// );
  /// ```
  Future<void> updateItem(
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    try {
      if (itemId.isEmpty) {
        throw Exception('Item ID cannot be empty');
      }

      // Always update the updatedAt timestamp
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _userItems.doc(itemId).update(updates);
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  /// Update item completion status
  /// 
  /// Example:
  /// ```dart
  /// await crudService.toggleItemCompletion('item123');
  /// ```
  Future<void> toggleItemCompletion(String itemId) async {
    try {
      final item = await getItem(itemId);
      if (item == null) {
        throw Exception('Item not found');
      }

      final newStatus = !(item['isCompleted'] as bool);
      await updateItem(itemId, {'isCompleted': newStatus});
    } catch (e) {
      throw Exception('Failed to toggle completion: $e');
    }
  }

  /// Update item title
  /// 
  /// Example:
  /// ```dart
  /// await crudService.updateItemTitle('item123', 'New Title');
  /// ```
  Future<void> updateItemTitle(String itemId, String newTitle) async {
    try {
      if (newTitle.isEmpty) {
        throw Exception('Title cannot be empty');
      }
      await updateItem(itemId, {'title': newTitle});
    } catch (e) {
      throw Exception('Failed to update title: $e');
    }
  }

  /// Update item priority
  /// 
  /// Example:
  /// ```dart
  /// await crudService.updateItemPriority('item123', 5);
  /// ```
  Future<void> updateItemPriority(String itemId, int priority) async {
    try {
      if (priority < 1 || priority > 5) {
        throw Exception('Priority must be between 1 and 5');
      }
      await updateItem(itemId, {'priority': priority});
    } catch (e) {
      throw Exception('Failed to update priority: $e');
    }
  }

  /// Add tags to an item
  /// 
  /// Example:
  /// ```dart
  /// await crudService.addTags('item123', ['urgent', 'review']);
  /// ```
  Future<void> addTags(String itemId, List<String> tagsToAdd) async {
    try {
      if (tagsToAdd.isEmpty) {
        throw Exception('Tags list cannot be empty');
      }

      final item = await getItem(itemId);
      if (item == null) {
        throw Exception('Item not found');
      }

      final currentTags = List<String>.from(item['tags'] ?? []);
      
      // Add only new tags (avoid duplicates)
      for (String tag in tagsToAdd) {
        if (!currentTags.contains(tag)) {
          currentTags.add(tag);
        }
      }

      await updateItem(itemId, {'tags': currentTags});
    } catch (e) {
      throw Exception('Failed to add tags: $e');
    }
  }

  /// Remove tags from an item
  /// 
  /// Example:
  /// ```dart
  /// await crudService.removeTags('item123', ['urgent']);
  /// ```
  Future<void> removeTags(String itemId, List<String> tagsToRemove) async {
    try {
      final item = await getItem(itemId);
      if (item == null) {
        throw Exception('Item not found');
      }

      final currentTags = List<String>.from(item['tags'] ?? []);
      currentTags.removeWhere((tag) => tagsToRemove.contains(tag));

      await updateItem(itemId, {'tags': currentTags});
    } catch (e) {
      throw Exception('Failed to remove tags: $e');
    }
  }

  // ==================== DELETE OPERATION (D) ====================

  /// Delete an item by ID
  /// 
  /// Example:
  /// ```dart
  /// await crudService.deleteItem('item123');
  /// ```
  Future<void> deleteItem(String itemId) async {
    try {
      if (itemId.isEmpty) {
        throw Exception('Item ID cannot be empty');
      }

      await _userItems.doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  /// Delete multiple items
  /// 
  /// Example:
  /// ```dart
  /// await crudService.deleteItems(['item1', 'item2', 'item3']);
  /// ```
  Future<void> deleteItems(List<String> itemIds) async {
    try {
      if (itemIds.isEmpty) {
        throw Exception('No items provided for deletion');
      }

      final batch = _firestore.batch();

      for (String itemId in itemIds) {
        batch.delete(_userItems.doc(itemId));
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete items: $e');
    }
  }

  /// Delete all completed items for the current user
  /// 
  /// Example:
  /// ```dart
  /// final count = await crudService.deleteCompletedItems();
  /// print('Deleted $count items');
  /// ```
  Future<int> deleteCompletedItems() async {
    try {
      final snapshot = await _userItems
          .where('isCompleted', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      int count = snapshot.docs.length;

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return count;
    } catch (e) {
      throw Exception('Failed to delete completed items: $e');
    }
  }

  // ==================== UTILITY OPERATIONS ====================

  /// Get count of items for the current user
  /// 
  /// Example:
  /// ```dart
  /// final count = await crudService.getItemCount();
  /// ```
  Future<int> getItemCount() async {
    try {
      final snapshot = await _userItems.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get item count: $e');
    }
  }

  /// Get statistics about user's items
  /// 
  /// Returns: Map with stats like totalCount, completedCount, etc.
  Future<Map<String, int>> getItemStatistics() async {
    try {
      final allItems = await getAllItems();

      int totalCount = allItems.length;
      int completedCount = allItems.where((item) => item['isCompleted']).length;
      int activeCount = totalCount - completedCount;

      final priorityCounts = <int, int>{};
      for (var item in allItems) {
        final priority = item['priority'] as int;
        priorityCounts[priority] = (priorityCounts[priority] ?? 0) + 1;
      }

      return {
        'totalCount': totalCount,
        'completedCount': completedCount,
        'activeCount': activeCount,
        'highPriorityCount':
            allItems.where((item) => (item['priority'] as int) >= 4).length,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  /// Delete all items for the current user (Dangerous!)
  /// 
  /// WARNING: This operation cannot be undone
  /// 
  /// Example:
  /// ```dart
  /// final confirmed = await showDialog(...);
  /// if (confirmed) {
  ///   await crudService.deleteAllItems();
  /// }
  /// ```
  Future<int> deleteAllItems() async {
    try {
      final snapshot = await _userItems.get();

      final batch = _firestore.batch();
      int count = snapshot.docs.length;

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return count;
    } catch (e) {
      throw Exception('Failed to delete all items: $e');
    }
  }
}
