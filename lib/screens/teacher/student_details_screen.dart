import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/student_model.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/marks_provider.dart';

class StudentDetailsScreen extends StatefulWidget {
  final StudentModel student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().getStudentAttendanceStream(widget.student.id);
      context.read<MarksProvider>().loadStudentMarks(widget.student.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final marksProvider = context.watch<MarksProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student.name),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryLight,
                    child: Text(
                      widget.student.name.isNotEmpty ? widget.student.name[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 40, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.student.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.student.email,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  if (widget.student.phone != null && widget.student.phone!.isNotEmpty)
                    Text(
                      widget.student.phone!,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Academic Stats
            Row(
              children: [
                _buildStatCard(
                  context,
                  'Attendance',
                  '${(widget.student.attendancePercentage ?? 0.0).toStringAsFixed(1)}%',
                  Icons.check_circle,
                  AppTheme.successColor,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  'Avg. Marks',
                  '${(widget.student.averageMarks ?? 0.0).toStringAsFixed(1)}%',
                  Icons.grade,
                  AppTheme.warningColor,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Attendance History (Brief)
            _SectionHeader(
              title: 'Recent Attendance',
              onSeeAll: () {
                // Navigate to attendance logs
              },
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<AttendanceModel>>(
              stream: context.read<AttendanceProvider>().getStudentAttendanceStream(widget.student.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ));
                }
                
                final records = snapshot.data ?? [];
                
                if (records.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No attendance records found'),
                  ));
                }
                
                return Column(
                  children: records.take(5).map((record) => Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: record.isPresent ? AppTheme.successColor.withValues(alpha: 0.1) : AppTheme.errorColor.withValues(alpha: 0.1),
                        child: Icon(
                          record.isPresent ? Icons.check_circle : Icons.cancel,
                          color: record.isPresent ? AppTheme.successColor : AppTheme.errorColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        '${record.date.day}/${record.date.month}/${record.date.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: record.isPresent ? AppTheme.successColor.withValues(alpha: 0.1) : AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          record.isPresent ? 'Present' : 'Absent',
                          style: TextStyle(
                            color: record.isPresent ? AppTheme.successColor : AppTheme.errorColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  )).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            // Performance
            _SectionHeader(title: 'Recent Performance'),
            const SizedBox(height: 8),
            if (marksProvider.studentMarks.isEmpty)
              const Center(child: Text('No marks recorded yet'))
            else
              ...marksProvider.studentMarks.take(3).map((mark) => Card(
                child: ListTile(
                  title: Text(mark.testName),
                  subtitle: Text('Score: ${mark.obtainedMarks}/${mark.totalMarks}'),
                  trailing: Text(
                    '${((mark.obtainedMarks / mark.totalMarks) * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (mark.obtainedMarks / mark.totalMarks) > 0.4 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              )),
              
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(title, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('See All')),
      ],
    );
  }
}
