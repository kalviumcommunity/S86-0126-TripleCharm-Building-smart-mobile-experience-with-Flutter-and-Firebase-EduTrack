import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/class_model.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/marks_provider.dart';
import '../../providers/announcement_provider.dart';
import 'students_screen.dart';
import 'attendance_screen.dart';
import 'marks_entry_screen.dart';
import 'marks_view_screen.dart';
import 'reports_screen.dart';
import 'announcements_screen.dart';

class ClassDetailsScreen extends StatefulWidget {
  final ClassModel classModel;

  const ClassDetailsScreen({super.key, required this.classModel});

  @override
  State<ClassDetailsScreen> createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) print('📋 [CLASS DETAILS] Loading data for class: ${widget.classModel.id}');
      context.read<StudentProvider>().loadClassStudents(widget.classModel.id);
      context.read<AnnouncementProvider>().loadClassAnnouncements(widget.classModel.id);
      context.read<MarksProvider>().loadClassMarks(widget.classModel.id);
      context.read<AttendanceProvider>().getClassAttendanceSummary(widget.classModel.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final marksProvider = context.watch<MarksProvider>();
    final announcementProvider = context.watch<AnnouncementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classModel.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit class
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryLight,
                      child: Icon(Icons.class_, color: AppTheme.primaryColor, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.classModel.name, style: Theme.of(context).textTheme.titleLarge),
                          Text(widget.classModel.description ?? 'No description', 
                            style: TextStyle(color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats Row
            Row(
              children: [
                  _buildSimpleStatCard(
                  context, 
                  'Students', 
                  studentProvider.classStudentCount.toString(), 
                  Icons.people, 
                  AppTheme.primaryColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentsScreen(
                          classId: widget.classModel.id,
                          className: widget.classModel.name,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _buildSimpleStatCard(
                  context, 
                  'Attendance', 
                  '${(attendanceProvider.classAveragePercent ?? 0.0).toStringAsFixed(1)}%', 
                  Icons.check_circle, 
                  AppTheme.successColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceScreen(
                          classId: widget.classModel.id,
                          className: widget.classModel.name,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _buildSimpleStatCard(
                  context, 
                  'Avg Marks', 
                  '${(marksProvider.classAveragePercent).toStringAsFixed(1)}%', 
                  Icons.grade, 
                  AppTheme.warningColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportsScreen(
                          classId: widget.classModel.id,
                          className: widget.classModel.name,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildActionButton(context, 'Mark Attendance', Icons.calendar_today, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceScreen(
                    classId: widget.classModel.id, 
                    className: widget.classModel.name
                  )));
                }),
                _buildActionButton(context, 'Enter Marks', Icons.edit_note, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MarksEntryScreen(
                    classId: widget.classModel.id, 
                    className: widget.classModel.name
                  )));
                }),
                _buildActionButton(context, 'View Marks', Icons.assessment, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MarksViewScreen(
                    classId: widget.classModel.id, 
                    className: widget.classModel.name
                  )));
                }),
                _buildActionButton(context, 'Announcements', Icons.announcement, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AnnouncementsScreen(
                    classId: widget.classModel.id, 
                    className: widget.classModel.name
                  )));
                }),
                _buildActionButton(context, 'Manage Students', Icons.group_add, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => StudentsScreen(
                    classId: widget.classModel.id, 
                    className: widget.classModel.name
                  )));
                }),
                _buildActionButton(context, 'Reports', Icons.bar_chart, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsScreen(
                    classId: widget.classModel.id, 
                    className: widget.classModel.name
                  )));
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Announcements
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Announcements', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AnnouncementsScreen(
                      classId: widget.classModel.id, 
                      className: widget.classModel.name
                    )));
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (announcementProvider.announcements.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No announcements yet'),
              ))
            else
              ...announcementProvider.announcements.take(2).map((a) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(a.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AnnouncementsScreen(
                      classId: widget.classModel.id, 
                      className: widget.classModel.name
                    )));
                  },
                ),
              )),
            
            const SizedBox(height: 24),
            // Reports Card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.white, size: 30),
                title: const Text('Detailed Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: const Text('View deep insights and student progress', style: TextStyle(color: Colors.white70)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsScreen(
                    classId: widget.classModel.id, 
                    className: widget.classModel.name
                  )));
                },
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleStatCard(BuildContext context, String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                Text(title, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
