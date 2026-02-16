import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/student_provider.dart';
import 'add_student_screen.dart';
import 'student_details_screen.dart';

/// Students Management Screen
class StudentsScreen extends StatefulWidget {
  final String classId;
  final String className;

  const StudentsScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<StudentProvider>().loadClassStudents(widget.classId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.className} - Students'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: _showBulkUploadDialog,
            tooltip: 'Bulk Upload',
          ),
        ],
        bottom: PreferredSize(

          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),

      body: Consumer<StudentProvider>(
        builder: (context, studentProvider, _) {
          final students = studentProvider.classStudents.where((s) => 
            s.name.toLowerCase().contains(_searchQuery) || 
            s.email.toLowerCase().contains(_searchQuery)
          ).toList();

          if (studentProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    studentProvider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<StudentProvider>().loadClassStudents(widget.classId);
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (students.isEmpty && _searchQuery.isNotEmpty) {
            return const Center(child: Text('No students match your search'));
          }

          if (studentProvider.classStudents.isEmpty) {

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No students enrolled',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddStudentScreen(
                            classId: widget.classId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Student'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(student.name),
                  subtitle: Text(student.email),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentDetailsScreen(student: student),
                      ),
                    );
                  },
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddStudentScreen(
                                classId: widget.classId,
                                student: student,
                              ),
                            ),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Remove Student'),
                              content: Text(
                                'Are you sure you want to remove ${student.name}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirmed == true && context.mounted) {
                            final success = await context
                                .read<StudentProvider>()
                                .deleteStudent(student.id, widget.classId);
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Student removed successfully'
                                        : 'Failed to remove student',
                                  ),
                                  backgroundColor: success
                                      ? AppTheme.successColor
                                      : Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'teacher_students_screen_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddStudentScreen(
                classId: widget.classId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBulkUploadDialog() {
    final TextEditingController bulkController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Student Upload'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter students in "Name, Email" format (one per line):', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: bulkController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'John Doe, john@example.com\nJane Smith, jane@example.com',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final lines = bulkController.text.split('\n');
              final List<Map<String, String>> studentData = [];
              for (var line in lines) {
                if (line.trim().isEmpty) continue;
                final parts = line.split(',');
                if (parts.length >= 2) {
                  studentData.add({
                    'name': parts[0].trim(),
                    'email': parts[1].trim(),
                  });
                }
              }

              if (studentData.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No valid entries found')));
                return;
              }

              final studentProvider = context.read<StudentProvider>();
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              final success = await studentProvider.bulkAddStudents(
                    classId: widget.classId,
                    studentData: studentData,
                  );

              if (mounted) {
                if (success) {
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Successfully added ${studentData.length} students'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(studentProvider.error ?? 'Failed to add students'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}

