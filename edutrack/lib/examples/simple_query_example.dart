import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple standalone example showing how to use Firestore queries
/// in your own Flutter apps.
/// 
/// Copy and adapt this pattern to your needs.

class SimpleFirestoreQueryExample extends StatelessWidget {
  const SimpleFirestoreQueryExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Query Example'),
      ),
      body: Column(
        children: [
          // Example 1: StreamBuilder for real-time data
          const Expanded(
            child: _RealtimeTaskList(),
          ),
          
          const Divider(),
          
          // Example 2: FutureBuilder for one-time load
          const Expanded(
            child: _OneTimeTaskList(),
          ),
        ],
      ),
    );
  }
}

// ==================== REAL-TIME WITH STREAMBUILDER ====================

/// Use StreamBuilder when you want automatic UI updates
/// whenever data changes in Firestore
class _RealtimeTaskList extends StatelessWidget {
  const _RealtimeTaskList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.blue.shade100,
          child: const Text(
            'Real-time Tasks (StreamBuilder)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            // THE QUERY: This is where you filter and order your data
            stream: FirebaseFirestore.instance
                .collection('tasks')                          // Which collection
                .where('isCompleted', isEqualTo: false)      // Filter: only incomplete
                .orderBy('priority', descending: true)        // Sort: highest priority first
                .limit(10)                                    // Limit: only 10 items
                .snapshots(),                                 // Real-time updates
            
            // THE UI: How to display the data
            builder: (context, snapshot) {
              // Step 1: Handle loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Step 2: Handle errors
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              // Step 3: Handle empty data
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No tasks found'),
                );
              }

              // Step 4: Display the data
              final tasks = snapshot.data!.docs;

              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  // Extract data from each document
                  final doc = tasks[index];
                  final data = doc.data() as Map<String, dynamic>;
                  
                  // Access fields
                  final title = data['title'] ?? 'Untitled';
                  final priority = data['priority'] ?? 0;
                  
                  // Build list item
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('$priority'),
                    ),
                    title: Text(title),
                    subtitle: Text('Document ID: ${doc.id}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==================== ONE-TIME WITH FUTUREBUILDER ====================

/// Use FutureBuilder when you only need to load data once
/// (no automatic updates)
class _OneTimeTaskList extends StatelessWidget {
  const _OneTimeTaskList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.green.shade100,
          child: const Text(
            'One-time Load (FutureBuilder)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: FutureBuilder<QuerySnapshot>(
            // THE QUERY: Same as StreamBuilder but with .get() instead
            future: FirebaseFirestore.instance
                .collection('tasks')
                .where('isCompleted', isEqualTo: true)
                .orderBy('createdAt', descending: true)
                .limit(5)
                .get(),  // One-time fetch (not .snapshots())
            
            // THE UI: Same pattern as StreamBuilder
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No completed tasks'),
                );
              }

              final tasks = snapshot.data!.docs;

              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final data = tasks[index].data() as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(data['title'] ?? 'Untitled'),
                    trailing: const Text('✓'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==================== QUERY PATTERNS LIBRARY ====================

/// Common query patterns you can copy and use
class FirestoreQueryPatterns {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Pattern 1: Get all documents (use sparingly!)
  Stream<QuerySnapshot> getAllDocuments() {
    return _db.collection('tasks').snapshots();
  }

  // Pattern 2: Filter by equality
  Stream<QuerySnapshot> getByStatus(String status) {
    return _db
        .collection('tasks')
        .where('status', isEqualTo: status)
        .snapshots();
  }

  // Pattern 3: Filter by comparison
  Stream<QuerySnapshot> getHighPriority() {
    return _db
        .collection('tasks')
        .where('priority', isGreaterThan: 5)
        .orderBy('priority', descending: true)
        .snapshots();
  }

  // Pattern 4: Filter by array contains
  Stream<QuerySnapshot> getByTag(String tag) {
    return _db
        .collection('tasks')
        .where('tags', arrayContains: tag)
        .snapshots();
  }

  // Pattern 5: Order by field
  Stream<QuerySnapshot> getOrderedByDate() {
    return _db
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Pattern 6: Limit results
  Stream<QuerySnapshot> getTopTen() {
    return _db
        .collection('tasks')
        .orderBy('priority', descending: true)
        .limit(10)
        .snapshots();
  }

  // Pattern 7: Combined query
  Stream<QuerySnapshot> getActiveHighPriority() {
    return _db
        .collection('tasks')
        .where('isCompleted', isEqualTo: false)
        .where('priority', isGreaterThanOrEqualTo: 7)
        .orderBy('priority', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Pattern 8: One-time fetch
  Future<QuerySnapshot> getOnce() {
    return _db
        .collection('tasks')
        .where('isCompleted', isEqualTo: false)
        .get();  // Returns Future, not Stream
  }

  // Pattern 9: Get single document
  Stream<DocumentSnapshot> getSingleDocument(String docId) {
    return _db
        .collection('tasks')
        .doc(docId)
        .snapshots();
  }

  // Pattern 10: Pagination
  Future<QuerySnapshot> getPage({
    required int pageSize,
    DocumentSnapshot? lastDocument,
  }) {
    Query query = _db
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.get();
  }
}

// ==================== QUICK REFERENCE WIDGET ====================

/// A widget that displays query syntax reference
class QueryReferenceCard extends StatelessWidget {
  const QueryReferenceCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firestore Query Syntax',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSyntaxRow('Collection', '.collection("name")'),
            _buildSyntaxRow('Filter (equal)', '.where("field", isEqualTo: value)'),
            _buildSyntaxRow('Filter (>)', '.where("field", isGreaterThan: value)'),
            _buildSyntaxRow('Filter (>=)', '.where("field", isGreaterThanOrEqualTo: value)'),
            _buildSyntaxRow('Filter (<)', '.where("field", isLessThan: value)'),
            _buildSyntaxRow('Filter (<=)', '.where("field", isLessThanOrEqualTo: value)'),
            _buildSyntaxRow('Filter (!=)', '.where("field", isNotEqualTo: value)'),
            _buildSyntaxRow('Array contains', '.where("field", arrayContains: value)'),
            _buildSyntaxRow('In list', '.where("field", whereIn: [values])'),
            _buildSyntaxRow('Order ascending', '.orderBy("field")'),
            _buildSyntaxRow('Order descending', '.orderBy("field", descending: true)'),
            _buildSyntaxRow('Limit', '.limit(10)'),
            _buildSyntaxRow('Real-time', '.snapshots()'),
            _buildSyntaxRow('One-time', '.get()'),
          ],
        ),
      ),
    );
  }

  Widget _buildSyntaxRow(String label, String code) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
