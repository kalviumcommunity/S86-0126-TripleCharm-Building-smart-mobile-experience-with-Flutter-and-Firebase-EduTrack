import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/student_provider.dart';
import '../../config/theme.dart';
import 'add_student_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _selectedClassId = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        context.read<ClassProvider>().fetchClasses(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        elevation: 0,
      ),
      body: Consumer<ClassProvider>(
        builder: (context, classProvider, _) {
          if (classProvider.classes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.class_, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No classes. Create a class first!'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to add class if you have that route
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please ask your teacher to create classes')),
                      );
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Class Filter
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedClassId.isEmpty ? null : _selectedClassId,
                  items: classProvider.classes
                      .map((c) => DropdownMenuItem(
                    value: c.classId,
                    child: Text(c.className),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClassId = value ?? '';
                      if (_selectedClassId.isNotEmpty) {
                        context.read<StudentProvider>().loadClassStudents(_selectedClassId);
                      }
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Class',
                    prefixIcon: const Icon(Icons.class_),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              // Students List
              if (_selectedClassId.isNotEmpty)
                Expanded(
                  child: Consumer<StudentProvider>(
                    builder: (context, studentProvider, _) {
                      if (studentProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (studentProvider.classStudents.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              const Text('No students in this class'),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddStudentScreen(argument: _selectedClassId),
                                    ),
                                  );
                                  // Stream will auto-update
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
                        itemCount: studentProvider.classStudents.length,
                        itemBuilder: (context, index) {
                          final student = studentProvider.classStudents[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              title: Text(
                                student.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Roll: ${student.rollNumber ?? 'N/A'}'),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text('Edit'),
                                    onTap: () {
                                      Future.delayed(const Duration(milliseconds: 100), () async {
                                        if (!context.mounted) return;
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddStudentScreen(argument: student),
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: const Text('Delete'),
                                    onTap: () => _deleteStudent(context, student.studentId),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: _selectedClassId.isNotEmpty
          ? FloatingActionButton(
        heroTag: 'students_screen_fab',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddStudentScreen(argument: _selectedClassId),
            ),
          );
          // Stream will auto-update
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  void _deleteStudent(BuildContext context, String studentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final provider = context.read<StudentProvider>();
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              
              await provider.deleteStudent(studentId, _selectedClassId);
              
              if (mounted) {
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Student deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
