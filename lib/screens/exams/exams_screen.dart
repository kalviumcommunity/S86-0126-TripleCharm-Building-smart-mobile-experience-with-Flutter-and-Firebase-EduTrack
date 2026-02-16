import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/exam_provider.dart';
import '../../config/theme.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  String _selectedClassId = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      context.read<ClassProvider>().fetchClasses(authProvider.user!.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams & Progress'),
        elevation: 0,
      ),
      body: Consumer<ClassProvider>(
        builder: (context, classProvider, _) {
          if (classProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    classProvider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (classProvider.classes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No classes. Create a class first!'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/add-class'),
                    child: const Text('Create Class'),
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
                    setState(() => _selectedClassId = value ?? '');
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
              // Exams List
              if (_selectedClassId.isNotEmpty)
                Expanded(
                  child: Consumer<ExamProvider>(
                    builder: (context, examProvider, _) {
                      if (examProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (examProvider.exams.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              const Text('No exams created yet'),
                              const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      '/create-exam',
                                      arguments: _selectedClassId,
                                    ),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Create Exam'),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: examProvider.exams.length,
                            itemBuilder: (context, index) {
                              final exam = examProvider.exams[index];
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
                                      Icons.assignment,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  title: Text(
                                    exam.examName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Total Marks: ${exam.totalMarks}',
                                  ),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: const Text('View Results'),
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          '/exam-results',
                                          arguments: exam.examId,
                                        ),
                                      ),
                                      PopupMenuItem(
                                        child: const Text('Add Marks'),
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          '/add-marks',
                                          arguments: {'examId': exam.examId, 'classId': _selectedClassId},
                                        ),
                                      ),
                                      PopupMenuItem(
                                        child: const Text('Delete'),
                                        onTap: () => _deleteExam(context, exam.examId),
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
        heroTag: 'exams_screen_fab',
        onPressed: () => Navigator.pushNamed(
          context,
          '/create-exam',
          arguments: _selectedClassId,
        ),
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  void _deleteExam(BuildContext context, String examId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam'),
        content: const Text('Are you sure you want to delete this exam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final provider = context.read<ExamProvider>();
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              
              await provider.deleteExam(examId);
              
              if (mounted) {
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Exam deleted'),
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
