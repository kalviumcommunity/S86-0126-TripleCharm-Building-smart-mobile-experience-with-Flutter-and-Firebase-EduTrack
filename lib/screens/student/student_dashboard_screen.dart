import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import 'student_attendance_view.dart';
import 'student_marks_view.dart';
import '../profile/profile_screen.dart';
import '../teacher/announcements_screen.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/marks_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../models/student_model.dart';


/// Student Dashboard Screen - Main navigation hub for students
class StudentDashboardScreen extends StatefulWidget {
  final bool isTab;
  const StudentDashboardScreen({super.key, this.isTab = false});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  StudentModel? _studentData;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  void _loadStudentData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      if (auth.user == null) return;

      if (kDebugMode) print('📱 [STUDENT DASHBOARD] Loading student data for user: ${auth.user!.id}');

      final studentProvider = context.read<StudentProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();
      final marksProvider = context.read<MarksProvider>();

      // First try to load student by userId (faster and more direct)
      StudentModel? student = await studentProvider.loadStudentByUserId(auth.user!.id);
      
      // Fallback to email if userId link doesn't exist yet (legacy accounts)
      if (student == null) {
        if (kDebugMode) print('📱 [STUDENT DASHBOARD] Student not found by userId, trying email: ${auth.user!.email}');
        student = await studentProvider.loadStudentByEmail(auth.user!.email);
      }
      
      if (student != null && mounted) {
        if (kDebugMode) print('📱 [STUDENT DASHBOARD] Student found: ${student.name}, Class: ${student.classId}');
        setState(() => _studentData = student);
        
        // Load attendance, marks, and announcements
        if (kDebugMode) print('📱 [STUDENT DASHBOARD] Loading attendance for student: ${student.id}');
        attendanceProvider.loadStudentAttendance(student.id);
        
        if (kDebugMode) print('📱 [STUDENT DASHBOARD] Loading marks for student: ${student.id}');
        marksProvider.loadStudentMarks(student.id);
        
        if (kDebugMode) print('📱 [STUDENT DASHBOARD] Loading announcements for class: ${student.classId}');
        context.read<AnnouncementProvider>().loadClassAnnouncements(student.classId);
      } else {
        if (kDebugMode) print('❌ [STUDENT DASHBOARD] Student not found for user: ${auth.user!.id}');
      }

    });
  }



  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pop(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isMobile = MediaQuery.of(context).size.width < 600;
    final attendanceProvider = context.watch<AttendanceProvider>();
    final marksProvider = context.watch<MarksProvider>();
    final attPct = attendanceProvider.getAttendancePercentage(attendanceProvider.studentAttendance);
    final avgMarks = marksProvider.getAverageMarks(marksProvider.studentMarks);

    if (kDebugMode) print('📱 [STUDENT DASHBOARD] Attendance records: ${attendanceProvider.studentAttendance.length}');
    if (kDebugMode) print('📱 [STUDENT DASHBOARD] Attendance percentage: ${attPct.toStringAsFixed(2)}%');
    if (kDebugMode) print('📱 [STUDENT DASHBOARD] Average marks: ${avgMarks.toStringAsFixed(2)}');

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: const Text('Student Dashboard', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              actions: [
                if (!widget.isTab)
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen()));
                    },
                    tooltip: 'Profile',
                  ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: _handleLogout,
                  tooltip: 'Logout',
                ),
              ],
              floating: true,
              pinned: true,
              snap: true,
            ),
          ];
        },
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${authProvider.user?.name ?? 'Student'}!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track your progress and stay updated',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Stats
              Text(
                'Your Progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: isMobile ? 2 : 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _ProgressCard(
                    title: 'Attendance',
                    value: '${attPct.toStringAsFixed(1)}%',
                    icon: Icons.check_circle,
                    color: AppTheme.primaryColor,
                  ),
                  _ProgressCard(
                    title: 'Avg. Marks',
                    value: '${avgMarks.toStringAsFixed(1)}%',
                    icon: Icons.grade,
                    color: AppTheme.accentColor,
                  ),
                  _ProgressCard(
                    title: 'Enrolled Classes',
                    value: _studentData != null ? '1' : '0',
                    icon: Icons.class_,
                    color: AppTheme.warningColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Menu Options
              Text(
                'Quick Links',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: isMobile ? 2 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _MenuCard(
                    icon: Icons.calendar_today,
                    label: 'My Attendance',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const StudentAttendanceView()));
                    },
                  ),
                  _MenuCard(
                    icon: Icons.assessment,
                    label: 'My Marks',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const StudentMarksView()));
                    },
                  ),
                  _MenuCard(
                    icon: Icons.announcement,
                    label: 'Announcements',
                    onTap: () {
                      // Navigate to announcements (read-only)
                      // We need a classId here. Students belong to a class.
                      final student =
                          context.read<StudentProvider>().selectedStudent;
                      if (student != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AnnouncementsScreen(
                                      classId: student.classId,
                                      className: 'My Class',
                                      isTeacher: false,
                                    )));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('No class assigned yet')));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ProgressCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppTheme.primaryColor),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
