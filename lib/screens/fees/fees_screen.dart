import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/student_provider.dart';
import '../../config/constants.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  String _selectedClassId = '';
  String _filterStatus = 'All';

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
        title: const Text('Fees Management'),
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
              // Status Filter
              if (_selectedClassId.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'All', label: Text('All')),
                          ButtonSegment(value: 'Paid', label: Text('Paid')),
                          ButtonSegment(value: 'Pending', label: Text('Pending')),
                        ],
                        selected: {_filterStatus},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() => _filterStatus = newSelection.first);
                        },
                      ),
                    ],
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

                      var students = studentProvider.students;

                      // Filter by fees status
                      if (_filterStatus != 'All') {
                        students = students
                            .where((s) => s.feesStatus == _filterStatus)
                            .toList();
                      }

                      if (students.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                _filterStatus == 'All'
                                    ? 'No students in this class'
                                    : 'No $_filterStatus fees',
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
                              final isPaid = student.feesStatus == AppConstants.feesPaid;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                child: ListTile(
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: (isPaid ? Colors.green : Colors.orange)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.payments,
                                      color: isPaid ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                  title: Text(
                                    student.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    student.feesStatus,
                                    style: TextStyle(
                                      color: isPaid ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (context) => [
                                      if (!isPaid)
                                        PopupMenuItem(
                                          child: const Text('Mark as Paid'),
                                          onTap: () =>
                                              _updateFeesStatus(context, student.studentId),
                                        ),
                                      PopupMenuItem(
                                        child: const Text('View Details'),
                                        onTap: () => _showStudentDetails(context, student),
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
    );
  }

  void _updateFeesStatus(BuildContext context, String studentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Fees as Paid'),
        content: const Text('Are you sure you want to mark this as paid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<StudentProvider>().updateStudentFields(
                studentId: studentId,
                data: {'feesStatus': 'Paid'},
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fees marked as paid'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showStudentDetails(BuildContext context, dynamic student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Roll Number: ${student.rollNumber ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Phone: ${student.phone ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Fees Status: ${student.feesStatus ?? 'N/A'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
