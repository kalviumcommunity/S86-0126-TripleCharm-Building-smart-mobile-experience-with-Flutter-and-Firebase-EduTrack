import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Collection of Firestore Query Examples
/// 
/// This file contains various examples of Firestore queries
/// demonstrating different filter types, ordering, and patterns.

class FirestoreQueryExamples {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== BASIC QUERIES ====================

  /// Example 1: Simple where query with equality filter
  /// Use case: Get all completed tasks
  Stream<QuerySnapshot> getCompletedTasks() {
    return _firestore
        .collection('tasks')
        .where('isCompleted', isEqualTo: true)
        .snapshots();
  }

  /// Example 2: Where query with ordering
  /// Use case: Get active tasks sorted by priority
  Stream<QuerySnapshot> getActiveTasksByPriority() {
    return _firestore
        .collection('tasks')
        .where('isCompleted', isEqualTo: false)
        .orderBy('priority', descending: true)
        .snapshots();
  }

  /// Example 3: Simple ordering without filter
  /// Use case: Get all tasks ordered by creation date (newest first)
  Stream<QuerySnapshot> getRecentTasks() {
    return _firestore
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ==================== COMPARISON FILTERS ====================

  /// Example 4: Greater than filter
  /// Use case: Get high-priority tasks (priority > 7)
  Stream<QuerySnapshot> getHighPriorityTasks() {
    return _firestore
        .collection('tasks')
        .where('priority', isGreaterThan: 7)
        .orderBy('priority', descending: true)
        .snapshots();
  }

  /// Example 5: Greater than or equal to filter
  /// Use case: Get tasks with priority >= 5
  Stream<QuerySnapshot> getMediumToHighPriorityTasks() {
    return _firestore
        .collection('tasks')
        .where('priority', isGreaterThanOrEqualTo: 5)
        .orderBy('priority')
        .snapshots();
  }

  /// Example 6: Less than filter with date
  /// Use case: Get tasks created before a specific date
  Stream<QuerySnapshot> getTasksBeforeDate(DateTime date) {
    return _firestore
        .collection('tasks')
        .where('createdAt', isLessThan: Timestamp.fromDate(date))
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Example 7: Between two values (range query)
  /// Use case: Get tasks with priority between 5 and 8
  Stream<QuerySnapshot> getTasksInPriorityRange(int min, int max) {
    return _firestore
        .collection('tasks')
        .where('priority', isGreaterThanOrEqualTo: min)
        .where('priority', isLessThanOrEqualTo: max)
        .orderBy('priority')
        .snapshots();
  }

  // ==================== ARRAY QUERIES ====================

  /// Example 8: Array contains
  /// Use case: Get tasks tagged with "urgent"
  Stream<QuerySnapshot> getUrgentTasks() {
    return _firestore
        .collection('tasks')
        .where('tags', arrayContains: 'urgent')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Example 9: Array contains any
  /// Use case: Get tasks with any of the specified tags
  Stream<QuerySnapshot> getTasksWithAnyTag(List<String> tags) {
    return _firestore
        .collection('tasks')
        .where('tags', arrayContainsAny: tags)
        .snapshots();
  }

  // ==================== LIMIT QUERIES ====================

  /// Example 10: Limit results
  /// Use case: Get top 10 priority tasks
  Stream<QuerySnapshot> getTopPriorityTasks({int limit = 10}) {
    return _firestore
        .collection('tasks')
        .orderBy('priority', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Example 11: Limit with filter
  /// Use case: Get first 5 incomplete tasks
  Stream<QuerySnapshot> getFirstIncompleteTasks({int limit = 5}) {
    return _firestore
        .collection('tasks')
        .where('isCompleted', isEqualTo: false)
        .orderBy('createdAt')
        .limit(limit)
        .snapshots();
  }

  // ==================== MULTIPLE ORDERING ====================

  /// Example 12: Order by multiple fields
  /// Use case: Sort by completion status, then by priority
  Stream<QuerySnapshot> getTasksOrderedByStatusAndPriority() {
    return _firestore
        .collection('tasks')
        .orderBy('isCompleted')
        .orderBy('priority', descending: true)
        .snapshots();
  }

  // ==================== PAGINATION ====================

  /// Example 13: Pagination with startAfter
  /// Use case: Load next page of tasks
  Stream<QuerySnapshot> getTasksPage({
    DocumentSnapshot? lastDocument,
    int pageSize = 10,
  }) {
    Query query = _firestore
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.snapshots();
  }

  /// Example 14: Pagination with startAt (using field value)
  /// Use case: Start pagination from specific timestamp
  Stream<QuerySnapshot> getTasksFromTimestamp({
    required Timestamp startTime,
    int pageSize = 10,
  }) {
    return _firestore
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .startAt([startTime])
        .limit(pageSize)
        .snapshots();
  }

  // ==================== COMBINED QUERIES ====================

  /// Example 15: Multiple filters with ordering
  /// Use case: Get incomplete high-priority tasks sorted by date
  Stream<QuerySnapshot> getIncompleteHighPriorityTasks() {
    return _firestore
        .collection('tasks')
        .where('isCompleted', isEqualTo: false)
        .where('priority', isGreaterThanOrEqualTo: 7)
        .orderBy('priority', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ==================== FUTURE-BASED QUERIES ====================

  /// Example 16: One-time fetch with FutureBuilder
  /// Use case: Load data once (not real-time)
  Future<QuerySnapshot> getTasksOnce() {
    return _firestore
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .get();
  }

  /// Example 17: Count documents (Firestore count aggregation)
  /// Use case: Get total number of completed tasks
  Future<int> getCompletedTasksCount() async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('isCompleted', isEqualTo: true)
        .count()
        .get();
    
    return snapshot.count ?? 0;
  }

  // ==================== NOT EQUAL QUERIES ====================

  /// Example 18: Not equal filter
  /// Use case: Get tasks where status is not "archived"
  Stream<QuerySnapshot> getNonArchivedTasks() {
    return _firestore
        .collection('tasks')
        .where('status', isNotEqualTo: 'archived')
        .snapshots();
  }

  // ==================== IN QUERIES ====================

  /// Example 19: In filter
  /// Use case: Get tasks with specific statuses
  Stream<QuerySnapshot> getTasksByStatuses(List<String> statuses) {
    return _firestore
        .collection('tasks')
        .where('status', whereIn: statuses)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Example 20: Not in filter
  /// Use case: Exclude specific categories
  Stream<QuerySnapshot> getTasksExcludingCategories(List<String> categories) {
    return _firestore
        .collection('tasks')
        .where('category', whereNotIn: categories)
        .snapshots();
  }

  // ==================== COMPOUND QUERIES (Require Composite Index) ====================

  /// Example 21: Filter on one field, order by another
  /// ⚠️ Requires composite index
  /// Use case: Get incomplete tasks ordered by due date
  Stream<QuerySnapshot> getIncompleteTasksByDueDate() {
    return _firestore
        .collection('tasks')
        .where('isCompleted', isEqualTo: false)
        .orderBy('dueDate')
        .snapshots();
  }

  /// Example 22: Multiple inequality filters
  /// ⚠️ Requires composite index
  /// Use case: Get tasks within priority and date range
  Stream<QuerySnapshot> getTasksInRanges({
    required int minPriority,
    required int maxPriority,
    required DateTime afterDate,
  }) {
    return _firestore
        .collection('tasks')
        .where('priority', isGreaterThanOrEqualTo: minPriority)
        .where('priority', isLessThanOrEqualTo: maxPriority)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(afterDate))
        .orderBy('priority')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ==================== NESTED FIELD QUERIES ====================

  /// Example 23: Query on nested field
  /// Use case: Get tasks by assignee name (nested in 'assignee.name')
  Stream<QuerySnapshot> getTasksByAssigneeName(String name) {
    return _firestore
        .collection('tasks')
        .where('assignee.name', isEqualTo: name)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ==================== BATCH OPERATIONS ====================

  /// Example 24: Batch write with queries
  /// Use case: Mark all incomplete high-priority tasks as completed
  Future<void> completeHighPriorityTasks() async {
    final batch = _firestore.batch();
    
    final querySnapshot = await _firestore
        .collection('tasks')
        .where('isCompleted', isEqualTo: false)
        .where('priority', isGreaterThanOrEqualTo: 8)
        .get();

    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isCompleted': true});
    }

    await batch.commit();
  }

  // ==================== TRANSACTION WITH QUERY ====================

  /// Example 25: Transaction with query
  /// Use case: Atomically update task count
  Future<void> incrementTaskCount(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    
    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      final currentCount = userDoc.data()?['taskCount'] ?? 0;
      transaction.update(userRef, {'taskCount': currentCount + 1});
    });
  }
}

// ==================== UI WIDGET EXAMPLES ====================

/// Widget showing StreamBuilder with query
class StreamBuilderQueryExample extends StatelessWidget {
  const StreamBuilderQueryExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('isCompleted', isEqualTo: false)
          .orderBy('priority', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle error state
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        // Handle empty state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No tasks found'),
          );
        }

        // Display data
        final tasks = snapshot.data!.docs;

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(task['title'] ?? 'Untitled'),
              subtitle: Text('Priority: ${task['priority']}'),
              trailing: Text(task['isCompleted'] ? '✓' : '○'),
            );
          },
        );
      },
    );
  }
}

/// Widget showing FutureBuilder with query
class FutureBuilderQueryExample extends StatelessWidget {
  const FutureBuilderQueryExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get(),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle error state
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        // Handle empty state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No tasks found'),
          );
        }

        // Display data (one-time load, no real-time updates)
        final tasks = snapshot.data!.docs;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Loaded ${tasks.length} tasks (one-time fetch)',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index].data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      title: Text(task['title'] ?? 'Untitled'),
                      subtitle: Text('Priority: ${task['priority']}'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget showing pagination example
class PaginationExample extends StatefulWidget {
  const PaginationExample({Key? key}) : super(key: key);

  @override
  State<PaginationExample> createState() => _PaginationExampleState();
}

class _PaginationExampleState extends State<PaginationExample> {
  final List<DocumentSnapshot> _tasks = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasMore = false;
        });
      } else {
        setState(() {
          _tasks.addAll(snapshot.docs);
          _lastDocument = snapshot.docs.last;
        });
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading tasks: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _tasks.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _tasks.length) {
          // Load more button
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _loadMore,
                      child: const Text('Load More'),
                    ),
            ),
          );
        }

        final task = _tasks[index].data() as Map<String, dynamic>;
        return ListTile(
          title: Text(task['title'] ?? 'Untitled'),
          subtitle: Text('Priority: ${task['priority']}'),
        );
      },
    );
  }
}
