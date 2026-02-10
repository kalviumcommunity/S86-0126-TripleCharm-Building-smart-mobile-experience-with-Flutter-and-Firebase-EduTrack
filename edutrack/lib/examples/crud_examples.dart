import 'package:edutrack/services/crud_service.dart';

/// Practical CRUD Examples and Patterns
/// 
/// This file demonstrates real-world CRUD usage patterns
/// Copy and adapt these examples for your specific use cases
class CrudExamples {
  final CrudService crudService = CrudService();

  // ==================== CREATE EXAMPLES ====================

  /// Example 1: Create a simple task
  Future<void> example_createSimpleTask() async {
    try {
      final taskId = await crudService.createItem(
        title: 'Buy groceries',
      );
      print('Task created with ID: $taskId');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 2: Create a task with full details
  Future<void> example_createDetailedTask() async {
    try {
      final taskId = await crudService.createItem(
        title: 'Complete Flutter CRUD assignment',
        description: 'Implement Create, Read, Update, Delete operations '
            'with proper error handling and UI feedback',
        priority: 5,
        tags: ['flutter', 'firebase', 'assignment'],
      );
      print('Detailed task created: $taskId');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 3: Create multiple tasks in batch
  Future<void> example_createMultipleTasks() async {
    try {
      final tasks = [
        {'title': 'Review code', 'priority': 4, 'tags': ['review']},
        {
          'title': 'Write documentation',
          'priority': 3,
          'tags': ['docs']
        },
        {'title': 'Deploy to production', 'priority': 5, 'tags': ['deploy']},
      ];

      List<String> createdIds = [];
      for (var task in tasks) {
        final id = await crudService.createItem(
          title: task['title'] as String,
          priority: task['priority'] as int,
          tags: List<String>.from(task['tags'] as List),
        );
        createdIds.add(id);
      }

      print('Created ${createdIds.length} tasks: $createdIds');
    } catch (e) {
      print('Error: $e');
    }
  }

  // ==================== READ EXAMPLES ====================

  /// Example 4: Get a single item by ID
  Future<void> example_getSingleItem(String itemId) async {
    try {
      final item = await crudService.getItem(itemId);
      if (item != null) {
        print('Item: ${item['title']}');
        print('Priority: ${item['priority']}');
        print('Completed: ${item['isCompleted']}');
      } else {
        print('Item not found');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 5: Get all items
  Future<void> example_getAllItems() async {
    try {
      final items = await crudService.getAllItems();
      print('Total items: ${items.length}');
      for (var item in items) {
        print('- ${item['title']} (Priority: ${item['priority']})');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 6: Get only active (incomplete) items
  Future<void> example_getActiveItems() async {
    try {
      final items = await crudService.getItemsFiltered(
        isCompleted: false,
      );
      print('Active items: ${items.length}');
      for (var item in items) {
        print('- [ACTIVE] ${item['title']}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 7: Get high-priority items
  Future<void> example_getHighPriorityItems() async {
    try {
      final items = await crudService.getItemsFiltered(
        minPriority: 4, // Priority 4 or 5
        isCompleted: false,
      );
      print('High-priority active items: ${items.length}');
      for (var item in items) {
        print('- [P${item['priority']}] ${item['title']}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 8: Get items with specific tags
  Future<void> example_getItemsByTag(String tag) async {
    try {
      final items = await crudService.getItemsFiltered(
        tags: [tag],
      );
      print('Items tagged "$tag": ${items.length}');
      for (var item in items) {
        print('- ${item['title']}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 9: Get statistics about items
  Future<void> example_getStatistics() async {
    try {
      final stats = await crudService.getItemStatistics();
      print('=== Item Statistics ===');
      print('Total items: ${stats['totalCount']}');
      print('Completed: ${stats['completedCount']}');
      print('Active: ${stats['activeCount']}');
      print('High priority: ${stats['highPriorityCount']}');
    } catch (e) {
      print('Error: $e');
    }
  }

  // ==================== UPDATE EXAMPLES ====================

  /// Example 10: Update a complete item with all fields
  Future<void> example_updateItemFull(String itemId) async {
    try {
      await crudService.updateItem(itemId, {
        'title': 'Updated title',
        'description': 'New description',
        'priority': 4,
        'isCompleted': true,
      });
      print('Item updated successfully');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 11: Update only the title
  Future<void> example_updateItemTitle(String itemId, String newTitle) async {
    try {
      await crudService.updateItemTitle(itemId, newTitle);
      print('Title updated to: $newTitle');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 12: Update only the priority
  Future<void> example_updateItemPriority(String itemId, int newPriority) async {
    try {
      await crudService.updateItemPriority(itemId, newPriority);
      print('Priority updated to: $newPriority');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 13: Toggle item completion status
  Future<void> example_toggleCompletion(String itemId) async {
    try {
      await crudService.toggleItemCompletion(itemId);
      print('Completion status toggled');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 14: Add tags to an item
  Future<void> example_addTagsToItem(String itemId) async {
    try {
      await crudService.addTags(itemId, ['urgent', 'review-needed']);
      print('Tags added successfully');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 15: Remove tags from an item
  Future<void> example_removeTagsFromItem(String itemId) async {
    try {
      await crudService.removeTags(itemId, ['urgent']);
      print('Tag removed successfully');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 16: Mark item as completed
  Future<void> example_markAsCompleted(String itemId) async {
    try {
      final item = await crudService.getItem(itemId);
      if (item != null && !(item['isCompleted'] as bool)) {
        await crudService.updateItem(itemId, {'isCompleted': true});
        print('Item marked as completed');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // ==================== DELETE EXAMPLES ====================

  /// Example 17: Delete a single item
  Future<void> example_deleteSingleItem(String itemId) async {
    try {
      await crudService.deleteItem(itemId);
      print('Item deleted successfully');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 18: Delete multiple specific items
  Future<void> example_deleteMultipleItems(List<String> itemIds) async {
    try {
      await crudService.deleteItems(itemIds);
      print('Deleted ${itemIds.length} items');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 19: Delete all completed items (cleanup)
  Future<void> example_deleteCompletedItems() async {
    try {
      final count = await crudService.deleteCompletedItems();
      print('Deleted $count completed items');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 20: Delete all items for user (with confirmation)
  Future<void> example_deleteAllItems() async {
    try {
      final count = await crudService.deleteAllItems();
      print('DELETED ALL $count ITEMS - THIS CANNOT BE UNDONE');
    } catch (e) {
      print('Error: $e');
    }
  }

  // ==================== STREAM/REAL-TIME EXAMPLES ====================

  /// Example 21: Stream items for real-time updates
  /// Use this in a StreamBuilder widget
  void example_streamItems() {
    final stream = crudService.streamItems();
    stream.listen((snapshot) {
      print('Items updated: ${snapshot.docs.length} total');
      for (var doc in snapshot.docs) {
        print('- ${doc['title']}');
      }
    });
  }

  /// Example 22: Stream only active items
  void example_streamActiveItems() {
    final stream = crudService.streamItemsFiltered(isCompleted: false);
    stream.listen((snapshot) {
      print('Active items: ${snapshot.docs.length}');
    });
  }

  /// Example 23: Stream high-priority items
  void example_streamHighPriority() {
    final stream = crudService.streamItemsFiltered(minPriority: 4);
    stream.listen((snapshot) {
      print('High-priority items: ${snapshot.docs.length}');
    });
  }

  // ==================== COMPLEX WORKFLOW EXAMPLES ====================

  /// Example 24: Complete workflow - Create, then update, then delete
  Future<void> example_completeWorkflow() async {
    try {
      // CREATE
      final itemId = await crudService.createItem(
        title: 'Workflow demo task',
        description: 'Demonstrating CRUD workflow',
        priority: 3,
      );
      print('✓ Created item: $itemId');

      // READ
      final item = await crudService.getItem(itemId);
      print('✓ Retrieved item: ${item?['title']}');

      // UPDATE
      await crudService.updateItemPriority(itemId, 5);
      await crudService.addTags(itemId, ['demo', 'workflow']);
      print('✓ Updated item priority and tags');

      // DELETE
      await crudService.deleteItem(itemId);
      print('✓ Deleted item');

      print('\n=== WORKFLOW COMPLETE ===');
    } catch (e) {
      print('Error in workflow: $e');
    }
  }

  /// Example 25: Bulk operation - Mark multiple items complete and archive
  Future<void> example_bulkMarkComplete(List<String> itemIds) async {
    try {
      print('Marking ${itemIds.length} items as complete...');
      for (String id in itemIds) {
        await crudService.updateItem(id, {'isCompleted': true});
      }
      print('✓ All items marked complete');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 26: Search-like operation - Get items matching criteria
  Future<void> example_searchItems(String searchTerm) async {
    try {
      // Note: Firestore doesn't have built-in text search
      // This is a client-side filtering example
      final allItems = await crudService.getAllItems();

      final results = allItems
          .where((item) =>
              (item['title'] as String)
                  .toLowerCase()
                  .contains(searchTerm.toLowerCase()) ||
              (item['description'] as String)
                  .toLowerCase()
                  .contains(searchTerm.toLowerCase()))
          .toList();

      print('Found ${results.length} items matching "$searchTerm"');
      for (var item in results) {
        print('- ${item['title']}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
