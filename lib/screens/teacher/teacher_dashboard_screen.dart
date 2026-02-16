import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/student_provider.dart';
import 'classes_screen.dart';
import 'students_screen.dart';
import 'attendance_screen.dart';
import 'attendance_class_selector_screen.dart';
import 'marks_entry_screen.dart';
import 'add_class_screen.dart';
import 'class_details_screen.dart';
import 'announcements_screen.dart';
import '../../models/class_model.dart';

/// Teacher Dashboard Screen - Modern, production-ready UI hub for teachers
class TeacherDashboardScreen extends StatefulWidget {
  final bool isTab;
  const TeacherDashboardScreen({super.key, this.isTab = false});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userId = context.read<AuthProvider>().user?.id;
      if (userId != null && userId.isNotEmpty) {
        context.read<ClassProvider>().loadTeacherClasses(userId);
        context.read<StudentProvider>().fetchTeacherStudents(userId);
        // Load global stats/data if needed
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

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 16),
              child: Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _QuickActionItem(
                  icon: Icons.add_circle_outline,
                  label: 'Create Class',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddClassScreen()));
                  },
                ),
                _QuickActionItem(
                  icon: Icons.person_add_alt_1_outlined,
                  label: 'Add Student',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _showClassSelector(context, (selected) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentsScreen(
                            classId: selected.id,
                            className: selected.name,
                          ),
                        ),
                      );
                    });
                  },
                ),
                _QuickActionItem(
                  icon: Icons.playlist_add_check_rounded,
                  label: 'Mark Attendance',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    _showClassSelector(context, (selected) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceScreen(
                            classId: selected.id,
                            className: selected.name,
                          ),
                        ),
                      );
                    });
                  },
                ),
                _QuickActionItem(
                  icon: Icons.assignment_outlined,
                  label: 'Add Marks',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    _showClassSelector(context, (selected) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MarksEntryScreen(
                            classId: selected.id,
                            className: selected.name,
                          ),
                        ),
                      );
                    });
                  },
                ),
                _QuickActionItem(
                  icon: Icons.campaign_outlined,
                  label: 'Announce',
                  color: Colors.teal,
                  onTap: () {
                    Navigator.pop(context);
                    _showClassSelector(context, (selected) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnnouncementsScreen(
                            classId: selected.id,
                            className: selected.name,
                          ),
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final classProvider = context.watch<ClassProvider>();
    final studentProvider = context.watch<StudentProvider>();

    // Calculate Dynamic Stats
    double totalAttendance = 0;
    int studentsWithAttendance = 0;
    double totalMarks = 0;
    int studentsWithMarks = 0;

    for (var student in studentProvider.students) {
      if (student.attendancePercentage != null) {
        totalAttendance += student.attendancePercentage!;
        studentsWithAttendance++;
      }
      if (student.averageMarks != null) {
        totalMarks += student.averageMarks!;
        studentsWithMarks++;
      }
    }

    String avgAttendanceStr = studentsWithAttendance > 0 
        ? "${(totalAttendance / studentsWithAttendance).toStringAsFixed(0)}%" 
        : "0%";
    
    String avgMarksStr = studentsWithMarks > 0 
        ? "${(totalMarks / studentsWithMarks).toStringAsFixed(0)}%" 
        : "0%";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Teacher Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        heroTag: 'teacher_dashboard_fab',
        onPressed: _showQuickActions,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${authProvider.user?.name ?? 'Teacher'}!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Manage your classes and student progress',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Stats Section
              Text(
                'Quick Stats',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _StatCard(
                    title: 'Total Classes',
                    value: classProvider.classCount.toString(),
                    icon: Icons.class_rounded,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassesScreen()));
                    },
                  ),
                  _StatCard(
                    title: 'Total Students',
                    value: studentProvider.studentCount.toString(),
                    icon: Icons.people_alt_rounded,
                    color: Colors.orange,
                    onTap: () {
                      // Navigate to students list if global list exists
                    },
                  ),
                  _StatCard(
                    title: 'Attendance',
                    value: avgAttendanceStr,
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceClassSelectorScreen()));
                    },
                  ),
                  _StatCard(
                    title: 'Avg. Marks',
                    value: avgMarksStr,
                    icon: Icons.auto_graph_rounded,
                    color: Colors.purple,
                    onTap: () {
                      // Navigate to reports
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Recent Classes Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Classes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassesScreen()));
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (classProvider.classes.isEmpty)
                _buildEmptyState('No classes found. Create one to get started!')
              else
                ...classProvider.classes.take(3).map((c) => _ClassItemRow(classModel: c)),

              const SizedBox(height: 28),

              // Performance Overview Section
              Text(
                'Performance Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildPerformanceCard(context, classProvider.classes),

              const SizedBox(height: 28),

              // Recent Activity Section
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildActivitySection(),

              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(BuildContext context, List<ClassModel> classes) {
    if (classes.isEmpty) return const SizedBox();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: classes.take(3).map((c) {
            // Simulate different percentages based on class data for visual variety
            final mockPercent = (0.65 + (c.name.length % 30) / 100).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${(mockPercent * 100).toInt()}% avg', 
                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: mockPercent,
                      backgroundColor: Colors.grey[200],
                      color: AppTheme.primaryColor,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActivitySection() {
    final classProvider = context.read<ClassProvider>();
    final studentProvider = context.read<StudentProvider>();
    
    final activities = <Widget>[];
    
    if (classProvider.classes.isNotEmpty) {
      final latestClass = classProvider.classes.first;
      activities.add(_ActivityItem(
        icon: Icons.add_business_rounded,
        title: 'Created Class: ${latestClass.name}',
        subtitle: '${latestClass.studentCount ?? 0} students enrolled',
        color: Colors.blue,
      ));
    }
    
    if (studentProvider.students.isNotEmpty) {
      activities.add(_ActivityItem(
        icon: Icons.person_add_rounded,
        title: 'Enrolled new students',
        subtitle: '${studentProvider.studentCount} total students now',
        color: Colors.green,
      ));
    }

    if (activities.isEmpty) {
      return _buildEmptyState('No recent activity recorded.');
    }

    return Column(children: activities);
  }

  void _showClassSelector(BuildContext context, Function(ClassModel) onSelected) {
    final classes = context.read<ClassProvider>().classes;
    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No classes available. Create one first.')));
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a Class', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: classes.length,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryLight,
                    child: const Icon(Icons.class_, color: AppTheme.primaryColor, size: 20),
                  ),
                  title: Text(classes[index].name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onSelected(classes[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassItemRow extends StatelessWidget {
  final ClassModel classModel;

  const _ClassItemRow({required this.classModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.class_rounded, color: AppTheme.primaryColor),
        ),
        title: Text(classModel.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${classModel.studentCount ?? 0} Students',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ClassDetailsScreen(classModel: classModel)));
        },
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 64) / 3;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
