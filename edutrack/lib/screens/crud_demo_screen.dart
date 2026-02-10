import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edutrack/services/crud_service.dart';

/// Complete CRUD Demo Screen
/// 
/// Demonstrates:
/// - Creating items (Create)
/// - Reading and displaying items in real-time (Read)
/// - Updating item properties (Update)
/// - Deleting items (Delete)
/// - Filtering and sorting items
/// - Error handling
class CrudDemoScreen extends StatefulWidget {
  const CrudDemoScreen({Key? key}) : super(key: key);

  @override
  State<CrudDemoScreen> createState() => _CrudDemoScreenState();
}

class _CrudDemoScreenState extends State<CrudDemoScreen> {
  final CrudService _crudService = CrudService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int _selectedPriority = 3;
  bool _filterCompleted = false;
  String _filterMode = 'all'; // all, active, completed, highPriority

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('CRUD Demo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Please sign in to use this feature'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete CRUD Flow'),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                user.email ?? 'User',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Create Section
            _buildCreateSection(),

            // Filter & Stats Section
            _buildFilterSection(),

            // Items List
            _buildItemsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSampleData,
        icon: const Icon(Icons.add),
        label: const Text('Add Sample'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  /// BUILD: Create Section
  Widget _buildCreateSection() {
    return Container(
      color: Colors.teal.shade50,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📝 CREATE - Add New Item',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Item Title *',
              hintText: 'Enter item title',
              prefixIcon: const Icon(Icons.text_fields),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Optional description',
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Priority (1-5)',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Slider(
                      value: _selectedPriority.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _selectedPriority.toString(),
                      onChanged: (value) {
                        setState(() => _selectedPriority = value.toInt());
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Chip(
                label: Text('Priority: $_selectedPriority'),
                backgroundColor: _getPriorityColor(_selectedPriority),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _createItem,
              icon: const Icon(Icons.add_circle),
              label: const Text('Create Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// BUILD: Filter Section
  Widget _buildFilterSection() {
    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔍 Filter & Sort',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterMode == 'all',
                  onSelected: (selected) {
                    setState(() => _filterMode = 'all');
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Active'),
                  selected: _filterMode == 'active',
                  onSelected: (selected) {
                    setState(() => _filterMode = 'active');
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Completed'),
                  selected: _filterMode == 'completed',
                  onSelected: (selected) {
                    setState(() => _filterMode = 'completed');
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('High Priority'),
                  selected: _filterMode == 'highPriority',
                  onSelected: (selected) {
                    setState(() => _filterMode = 'highPriority');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// BUILD: Items List
  Widget _buildItemsList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 READ - Your Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _getFilteredStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No items yet.\nCreate one to get started!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final item = doc.data();
                  final itemId = doc.id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Checkbox(
                        value: item['isCompleted'] ?? false,
                        onChanged: (_) => _toggleCompletion(itemId),
                      ),
                      title: Text(
                        item['title'] ?? 'Untitled',
                        style: TextStyle(
                          decoration:
                              (item['isCompleted'] ?? false)
                                  ? TextDecoration.lineThrough
                                  : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((item['description'] ?? '').isNotEmpty)
                            Text(item['description'] ?? ''),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Chip(
                                label: Text(
                                  'Priority: ${item['priority'] ?? 3}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor:
                                    _getPriorityColor(item['priority'] ?? 3),
                              ),
                              const SizedBox(width: 8),
                              if ((item['tags'] as List?)?.isNotEmpty ?? false)
                                Expanded(
                                  child: Wrap(
                                    spacing: 4,
                                    children: [
                                      for (String tag in item['tags'])
                                        Chip(
                                          label: Text(
                                            tag,
                                            style: const TextStyle(fontSize: 11),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editItem(itemId, item),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteItem(itemId),
                              tooltip: 'Delete',
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== ACTIONS ====================

  /// CREATE: Add new item
  Future<void> _createItem() async {
    if (_titleController.text.isEmpty) {
      _showSnackbar('Please enter a title', Colors.red);
      return;
    }

    try {
      final itemId = await _crudService.createItem(
        title: _titleController.text,
        description: _descriptionController.text,
        priority: _selectedPriority,
      );

      _titleController.clear();
      _descriptionController.clear();
      _selectedPriority = 3;

      _showSnackbar('✅ Item created successfully!', Colors.teal);
    } catch (e) {
      _showSnackbar('❌ Error: $e', Colors.red);
    }
  }

  /// READ: Get filtered stream
  Stream<QuerySnapshot<Map<String, dynamic>>> _getFilteredStream() {
    switch (_filterMode) {
      case 'active':
        return _crudService.streamItemsFiltered(isCompleted: false);
      case 'completed':
        return _crudService.streamItemsFiltered(isCompleted: true);
      case 'highPriority':
        return _crudService.streamItemsFiltered(minPriority: 4);
      default:
        return _crudService.streamItems();
    }
  }

  /// UPDATE: Toggle item completion
  Future<void> _toggleCompletion(String itemId) async {
    try {
      await _crudService.toggleItemCompletion(itemId);
      _showSnackbar('✅ Item updated!', Colors.teal);
    } catch (e) {
      _showSnackbar('❌ Error: $e', Colors.red);
    }
  }

  /// UPDATE: Open edit dialog
  Future<void> _editItem(String itemId, Map<String, dynamic> item) async {
    final titleController = TextEditingController(text: item['title']);
    final descriptionController =
        TextEditingController(text: item['description']);
    int priority = item['priority'] ?? 3;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('✏️ Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Priority:'),
                    Slider(
                      value: priority.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: priority.toString(),
                      onChanged: (value) {
                        setState(() => priority = value.toInt());
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _crudService.updateItem(itemId, {
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'priority': priority,
                  });
                  Navigator.pop(context);
                  _showSnackbar('✅ Item updated!', Colors.teal);
                } catch (e) {
                  _showSnackbar('❌ Error: $e', Colors.red);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  /// DELETE: Delete item
  Future<void> _deleteItem(String itemId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🗑️ Delete Item?'),
        content: const Text(
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _crudService.deleteItem(itemId);
                Navigator.pop(context);
                _showSnackbar('✅ Item deleted!', Colors.teal);
              } catch (e) {
                Navigator.pop(context);
                _showSnackbar('❌ Error: $e', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Add sample data for testing
  Future<void> _addSampleData() async {
    try {
      final sampleItems = [
        {
          'title': 'Learn Flutter CRUD',
          'description': 'Master Create, Read, Update, Delete operations',
          'priority': 5,
        },
        {
          'title': 'Review Firestore Rules',
          'description': 'Understand security rules for user data',
          'priority': 4,
        },
        {
          'title': 'Build Real-time UI',
          'description': 'Use StreamBuilder for live updates',
          'priority': 4,
        },
        {
          'title': 'Test Error Handling',
          'description': 'Handle network errors gracefully',
          'priority': 3,
        },
      ];

      int count = 0;
      for (var item in sampleItems) {
        await _crudService.createItem(
          title: item['title'] as String,
          description: item['description'] as String,
          priority: item['priority'] as int,
        );
        count++;
      }

      _showSnackbar('✅ Added $count sample items!', Colors.teal);
    } catch (e) {
      _showSnackbar('❌ Error: $e', Colors.red);
    }
  }

  // ==================== HELPERS ====================

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 5:
        return Colors.red.shade200;
      case 4:
        return Colors.orange.shade200;
      case 3:
        return Colors.yellow.shade200;
      case 2:
        return Colors.lightBlue.shade200;
      default:
        return Colors.green.shade200;
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
