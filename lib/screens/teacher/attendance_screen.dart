import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../services/database_service.dart';

/// Attendance Marking Screen - Modern UI matching design
class AttendanceScreen extends StatefulWidget {
  final String classId;
  final String className;

  const AttendanceScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late DateTime _selectedDate;
  final Map<String, bool> _attendance = {};
  StreamSubscription? _attendanceSubscription;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (kDebugMode) print('📊 [ATTENDANCE] Loading students for class: ${widget.classId}');
      context.read<StudentProvider>().loadClassStudents(widget.classId);
      _subscribeToAttendance();
    });
  }

  @override
  void dispose() {
    _attendanceSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToAttendance() {
    _attendanceSubscription?.cancel();
    
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
    if (kDebugMode) print('📊 [ATTENDANCE] Loading attendance for date: $dateString');
    
    // Listen to real-time attendance updates
    _attendanceSubscription = DatabaseService.getAttendanceByDateStream(
      classId: widget.classId,
      date: _selectedDate,
    ).listen((records) {
      if (!mounted) return;
      
      if (kDebugMode) print('📊 [ATTENDANCE] Received ${records.length} attendance records');
      
      setState(() {
        // Don't clear during save to preserve user changes
        if (!_isSaving) {
          _attendance.clear();
        }
        
        // Map existing records, but don't override if user is currently editing
        for (var record in records) {
          // Only update if we don't have a user-set value or we're not currently saving
          if (!_attendance.containsKey(record.studentId) || !_isSaving) {
            _attendance[record.studentId] = record.isPresent;
            if (kDebugMode) print('📊 [ATTENDANCE] Student ${record.studentId}: ${record.isPresent ? 'Present' : 'Absent'}');
          }
        }
        
        // Default to Present for students without records (only if not saving)
        if (!_isSaving) {
          final students = context.read<StudentProvider>().classStudents;
          for (var student in students) {
            if (!_attendance.containsKey(student.id)) {
              _attendance[student.id] = true;
            }
          }
        }
      });
    });
  }

  Future<void> _saveAttendance() async {
    if (_isSaving) return; // Prevent double-save
    
    setState(() => _isSaving = true);
    
    final attendanceProvider = context.read<AttendanceProvider>();
    final students = context.read<StudentProvider>().classStudents;

    if (kDebugMode) print('📊 [ATTENDANCE] Saving attendance for ${students.length} students...');
    
    int successCount = 0;
    int totalCount = students.length;

    for (var student in students) {
      final isPresent = _attendance[student.id] ?? true;
      if (kDebugMode) print('📊 [ATTENDANCE] Saving ${student.name}: ${isPresent ? 'Present' : 'Absent'}');
      
      final success = await attendanceProvider.recordAttendance(
        classId: widget.classId,
        studentId: student.id,
        date: _selectedDate,
        isPresent: isPresent,
      );
      if (success) successCount++;
    }

    if (kDebugMode) print('📊 [ATTENDANCE] Saved $successCount of $totalCount records');

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (successCount == totalCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Attendance saved successfully for ${DateFormat('MMM dd, yyyy').format(_selectedDate)}'),
              ),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (kDebugMode) print('✅ [ATTENDANCE] All attendance records saved successfully');
    } else if (successCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Saved $successCount of $totalCount records. Some failed.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (kDebugMode) print('⚠️ [ATTENDANCE] Partial save: $successCount of $totalCount');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${attendanceProvider.error ?? 'Failed to save attendance'}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (kDebugMode) print('❌ [ATTENDANCE] Failed to save attendance');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Class Info & Date Selector Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.className,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (date != null && mounted) {
                          setState(() {
                            _selectedDate = date;
                          });
                          if (kDebugMode) print('📊 [ATTENDANCE] Date changed to: ${DateFormat('yyyy-MM-dd').format(date)}');
                          _subscribeToAttendance(); // Reload attendance for new date
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: const Text('Change Date'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMMM dd, yyyy').format(_selectedDate),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Students List
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
                        Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No students in this class',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add students to mark attendance',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: studentProvider.classStudents.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final student = studentProvider.classStudents[index];
                    final isPresent = _attendance[student.id] ?? true;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: isPresent
                                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              child: Text(
                                student.name.isNotEmpty 
                                    ? student.name[0].toUpperCase() 
                                    : '?',
                                style: TextStyle(
                                  color: isPresent ? AppTheme.primaryColor : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Student Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    student.email,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Attendance Toggle
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Absent Button
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _attendance[student.id] = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !isPresent ? Colors.red : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: !isPresent ? Colors.red : Colors.grey[300]!,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      'Absent',
                                      style: TextStyle(
                                        color: !isPresent ? Colors.white : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Present Button
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _attendance[student.id] = true;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isPresent ? AppTheme.primaryColor : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isPresent ? AppTheme.primaryColor : Colors.grey[300]!,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isPresent)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 4),
                                            child: Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        Text(
                                          'Present',
                                          style: TextStyle(
                                            color: isPresent ? Colors.white : Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
          // Save Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Saving...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Save Attendance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
