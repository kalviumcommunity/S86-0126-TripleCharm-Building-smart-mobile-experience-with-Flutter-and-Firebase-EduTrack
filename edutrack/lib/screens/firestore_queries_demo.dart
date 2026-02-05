import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Comprehensive Firestore Queries, Filters, and Ordering Demo
/// 
/// This screen demonstrates:
/// - Basic queries with where filters
/// - Ordering data with orderBy
/// - Limiting results
/// - Real-time updates with StreamBuilder
/// - Various filter types (equality, comparison, array)
class FirestoreQueriesDemo extends StatefulWidget {
  const FirestoreQueriesDemo({Key? key}) : super(key: key);

  @override
  State<FirestoreQueriesDemo> createState() => _FirestoreQueriesDemoState();
}

class _FirestoreQueriesDemoState extends State<FirestoreQueriesDemo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Query configuration
  String _selectedQuery = 'all';
  bool _isDescending = false;
  int _limitCount = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Queries Demo'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildQueryControls(),
          Expanded(
            child: _buildQueryResults(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSampleData,
        icon: const Icon(Icons.add),
        label: const Text('Add Sample Data'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  /// Query control panel
  Widget _buildQueryControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Query Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          
          // Query type selector
          DropdownButtonFormField<String>(
            value: _selectedQuery,
            decoration: const InputDecoration(
              labelText: 'Select Query Type',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Tasks')),
              DropdownMenuItem(value: 'active', child: Text('Active Tasks (where)')),
              DropdownMenuItem(value: 'completed', child: Text('Completed Tasks')),
              DropdownMenuItem(value: 'high_priority', child: Text('High Priority (>= 7)')),
              DropdownMenuItem(value: 'tagged', child: Text('Tagged "urgent"')),
              DropdownMenuItem(value: 'recent', child: Text('Recent (ordered by date)')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedQuery = value!;
              });
            },
          ),
          const SizedBox(height: 12),
          
          // Sort order and limit controls
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: const Text('Descending Order'),
                  value: _isDescending,
                  onChanged: (value) {
                    setState(() {
                      _isDescending = value;
                    });
                  },
                  activeColor: Colors.deepPurple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _limitCount,
                  decoration: const InputDecoration(
                    labelText: 'Limit',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 items')),
                    DropdownMenuItem(value: 10, child: Text('10 items')),
                    DropdownMenuItem(value: 20, child: Text('20 items')),
                    DropdownMenuItem(value: 50, child: Text('50 items')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _limitCount = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Display query results using StreamBuilder
  Widget _buildQueryResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getQueryStream(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {}); // Rebuild to retry
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No tasks found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adding some sample data',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        // Display results
        final docs = snapshot.data!.docs;

        return Column(
          children: [
            // Result count header
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 20, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Found ${docs.length} result(s)',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _getQueryDescription(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Results list
            Expanded(
              child: ListView.builder(
                itemCount: docs.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  
                  return _buildTaskCard(doc.id, data, index);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build individual task card
  Widget _buildTaskCard(String id, Map<String, dynamic> data, int index) {
    final title = data['title'] ?? 'Untitled';
    final isCompleted = data['isCompleted'] ?? false;
    final priority = data['priority'] ?? 0;
    final tags = List<String>.from(data['tags'] ?? []);
    final timestamp = data['createdAt'] as Timestamp?;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor(priority),
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Priority: $priority'),
            if (tags.isNotEmpty)
              Wrap(
                spacing: 4,
                children: tags.map((tag) => Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 10)),
                  backgroundColor: Colors.deepPurple.shade100,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                )).toList(),
              ),
            if (timestamp != null)
              Text(
                'Created: ${_formatTimestamp(timestamp)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
          ],
        ),
        trailing: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Colors.green : Colors.grey,
        ),
        onTap: () => _showTaskDetails(id, data),
      ),
    );
  }

  /// Get appropriate query stream based on selected options
  Stream<QuerySnapshot> _getQueryStream() {
    Query query = _firestore.collection('tasks');

    // Apply filters based on selected query type
    switch (_selectedQuery) {
      case 'active':
        // WHERE filter: equality
        query = query.where('isCompleted', isEqualTo: false);
        query = query.orderBy('priority', descending: _isDescending);
        break;
        
      case 'completed':
        // WHERE filter: equality
        query = query.where('isCompleted', isEqualTo: true);
        query = query.orderBy('createdAt', descending: _isDescending);
        break;
        
      case 'high_priority':
        // WHERE filter: comparison (>=)
        query = query.where('priority', isGreaterThanOrEqualTo: 7);
        query = query.orderBy('priority', descending: true);
        break;
        
      case 'tagged':
        // WHERE filter: array contains
        query = query.where('tags', arrayContains: 'urgent');
        query = query.orderBy('createdAt', descending: _isDescending);
        break;
        
      case 'recent':
        // ORDER BY only
        query = query.orderBy('createdAt', descending: true);
        break;
        
      default: // 'all'
        // Basic query with ordering
        query = query.orderBy('createdAt', descending: _isDescending);
    }

    // Apply limit
    query = query.limit(_limitCount);

    return query.snapshots();
  }

  /// Get description of current query for display
  String _getQueryDescription() {
    switch (_selectedQuery) {
      case 'active':
        return 'where(isCompleted = false)';
      case 'completed':
        return 'where(isCompleted = true)';
      case 'high_priority':
        return 'where(priority >= 7)';
      case 'tagged':
        return 'where(tags contains "urgent")';
      case 'recent':
        return 'orderBy(createdAt)';
      default:
        return 'all documents';
    }
  }

  /// Get priority color
  Color _getPriorityColor(int priority) {
    if (priority >= 8) return Colors.red;
    if (priority >= 5) return Colors.orange;
    return Colors.blue;
  }

  /// Format timestamp for display
  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Show task details dialog
  void _showTaskDetails(String id, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['title'] ?? 'Task Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ID: $id'),
            const Divider(),
            Text('Priority: ${data['priority']}'),
            Text('Completed: ${data['isCompleted']}'),
            Text('Tags: ${(data['tags'] as List?)?.join(', ') ?? 'None'}'),
            if (data['description'] != null)
              Text('Description: ${data['description']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              _deleteTask(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Add sample data to Firestore
  Future<void> _addSampleData() async {
    try {
      final batch = _firestore.batch();
      final tasksRef = _firestore.collection('tasks');

      // Sample tasks with different properties
      final sampleTasks = [
        {
          'title': 'Complete project proposal',
          'description': 'Write and submit the project proposal',
          'priority': 9,
          'isCompleted': false,
          'tags': ['urgent', 'work'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Review code submissions',
          'description': 'Review pull requests from team',
          'priority': 7,
          'isCompleted': false,
          'tags': ['work', 'code-review'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Buy groceries',
          'description': 'Weekly grocery shopping',
          'priority': 5,
          'isCompleted': false,
          'tags': ['personal'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Prepare presentation',
          'description': 'Create slides for meeting',
          'priority': 8,
          'isCompleted': false,
          'tags': ['urgent', 'work'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Read documentation',
          'description': 'Study Firestore docs',
          'priority': 4,
          'isCompleted': true,
          'tags': ['learning'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Fix bug #1234',
          'description': 'Fix critical production bug',
          'priority': 10,
          'isCompleted': false,
          'tags': ['urgent', 'bug'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Update dependencies',
          'description': 'Update Flutter packages',
          'priority': 3,
          'isCompleted': true,
          'tags': ['maintenance'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Team meeting',
          'description': 'Weekly sync meeting',
          'priority': 6,
          'isCompleted': false,
          'tags': ['work', 'meeting'],
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var task in sampleTasks) {
        batch.set(tasksRef.doc(), task);
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sample data added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding sample data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Delete a task
  Future<void> _deleteTask(String id) async {
    try {
      await _firestore.collection('tasks').doc(id).delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
