import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../config/constants.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _selectedClassId = '';
  DateTime _selectedDate = DateTime.now();
  final Map<String, String> _attendanceStatus = {}; // studentId -> status
  bool _isLoading = false;

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
        title: const Text('Mark Attendance'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<ClassProvider>(
          builder: (context, classProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class Dropdown
                DropdownButtonFormField<String>(
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
                      _attendanceStatus.clear();
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
                const SizedBox(height: 16),
                // Date Picker
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectDate,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  controller: TextEditingController(
                    text: _selectedDate.toString().split(' ')[0],
                  ),
                ),
                const SizedBox(height: 24),
                // Students List
                if (_selectedClassId.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Students',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Consumer<StudentProvider>(
                        builder: (context, studentProvider, _) {
                          if (studentProvider.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (studentProvider.classStudents.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    Icon(Icons.person, size: 48, color: Colors.grey[300]),
                                    const SizedBox(height: 16),
                                    const Text('No students in this class'),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: studentProvider.classStudents.map((student) {
                              final status = _attendanceStatus[student.studentId] ??
                                  AppConstants.present;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  student.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (student.rollNumber != null)
                                                  Text(
                                                    'Roll: ${student.rollNumber}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          SegmentedButton<String>(
                                            segments: const [
                                              ButtonSegment(
                                                value: AppConstants.present,
                                                label: Text('P'),
                                              ),
                                              ButtonSegment(
                                                value: AppConstants.absent,
                                                label: Text('A'),
                                              ),
                                              ButtonSegment(
                                                value: 'Leave',
                                                label: Text('L'),
                                              ),
                                            ],
                                            selected: {status},
                                            onSelectionChanged: (Set<String> newSelection) {
                                              setState(() {
                                                _attendanceStatus[student.studentId] =
                                                newSelection.first;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                        },
                      ),
                      const SizedBox(height: 32),
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveAttendance,
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Text('Save Attendance'),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveAttendance() async {
    if (_selectedClassId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();

      for (final entry in _attendanceStatus.entries) {
        await attendanceProvider.markAttendance(
          teacherId: authProvider.user!.uid,
          classId: _selectedClassId,
          studentId: entry.key,
          date: _selectedDate,
          isPresent: entry.value == AppConstants.present,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.successAttendanceSaved),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }
}
