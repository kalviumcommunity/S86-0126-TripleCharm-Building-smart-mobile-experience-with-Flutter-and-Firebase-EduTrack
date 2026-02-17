import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/student_provider.dart';
import 'classes_screen.dart';
import 'add_student_screen.dart';
import 'students_screen.dart';
import 'attendance_screen.dart';
import 'attendance_class_selector_screen.dart';
import 'marks_entry_screen.dart';
import 'add_class_screen.dart';
import 'class_details_screen.dart';
import 'announcements_screen.dart';
import 'reports_screen.dart';
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
    final mainContext = context; // Capture the state's context
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 16),
              child: Text(
                'Quick Actions',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                    Navigator.pop(sheetContext);
                    Navigator.push(mainContext, MaterialPageRoute(builder: (_) => const AddClassScreen()));
                  },
                ),
                _QuickActionItem(
                  icon: Icons.person_add_alt_1_outlined,
                  label: 'Add Student',
                  color: Colors.orange,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    _showClassSelector(mainContext, (selected) async {
                      final result = await Navigator.push(
                        mainContext,
                        MaterialPageRoute(
                          builder: (_) => AddStudentScreen(
                            classId: selected.id,
                          ),
                        ),
                      );
                      
                      // If student was added successfully, navigate to students list
                      if (result == true && mainContext.mounted) {
                        Navigator.push(
                          mainContext,
                          MaterialPageRoute(
                            builder: (_) => StudentsScreen(
                              classId: selected.id,
                              className: selected.name,
                            ),
                          ),
                        );
                      }
                    });
                  },
                ),
                _QuickActionItem(
                  icon: Icons.playlist_add_check_rounded,
                  label: 'Mark Attendance',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showClassSelector(mainContext, (selected) {
                      Navigator.push(
                        mainContext,
                        MaterialPageRoute(
                          builder: (_) => AttendanceScreen(
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
                    Navigator.pop(sheetContext);
                    _showClassSelector(mainContext, (selected) {
                      Navigator.push(
                        mainContext,
                        MaterialPageRoute(
                          builder: (_) => MarksEntryScreen(
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
                    Navigator.pop(sheetContext);
                    _showClassSelector(mainContext, (selected) {
                      Navigator.push(
                        mainContext,
                        MaterialPageRoute(
                          builder: (_) => AnnouncementsScreen(
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'teacher_dashboard_fab',
        onPressed: _showQuickActions,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: const Text('Teacher Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
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
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withValues(alpha: 0.8)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${authProvider.user?.name ?? 'Teacher'}!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Here's your dashboard at a glance.",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Stats Grid
                _buildStatsGrid(
                    classProvider.classes.length,
                    studentProvider.students.length,
                    avgAttendanceStr,
                    avgMarksStr),
                const SizedBox(height: 28),

                // Recent Classes Section
                _buildSectionHeader(context, 'My Classes', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ClassesScreen()));
                }),
                const SizedBox(height: 8),
                classProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : classProvider.classes.isEmpty
                        ? _buildEmptyState(
                            'No classes found. Create one to get started!')
                        : Column(
                            children: [
                              ...classProvider.classes
                                  .take(3)
                                  .map((c) => _ClassItemRow(classModel: c)),
                            ],
                          ),
                const SizedBox(height: 28),

                // Performance Overview
                _buildSectionHeader(context, 'Performance Overview', () {
                  // Optional: Navigate to a detailed performance screen
                }),
                const SizedBox(height: 12),
                Consumer<StudentProvider>(
                  builder: (context, studentProvider, _) {
                    return _buildPerformanceCard(context, classProvider.classes, studentProvider);
                  },
                ),

                const SizedBox(height: 28),

                // Recent Activity Feed
                _buildSectionHeader(context, 'Recent Activity', () {
                  // Optional: Navigate to a full activity log
                }),
                const SizedBox(height: 12),
                _buildActivitySection(),

                const SizedBox(
                    height: 100), // Space for FAB
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, VoidCallback onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style:
              Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onViewAll,
          child: const Text('View All'),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(int classCount, int studentCount,
      String avgAttendance, String avgMarks) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'Total Classes',
          value: classCount.toString(),
          icon: Icons.class_rounded,
          color: Colors.blue,
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ClassesScreen()));
          },
        ),
        _StatCard(
          title: 'Total Students',
          value: studentCount.toString(),
          icon: Icons.people_alt_rounded,
          color: Colors.orange,
          onTap: () {
            _showStudentBreakdown();
          },
        ),
        _StatCard(
          title: 'Attendance',
          value: avgAttendance,
          icon: Icons.check_circle_rounded,
          color: Colors.green,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AttendanceClassSelectorScreen()));
          },
        ),
        _StatCard(
          title: 'Avg. Marks',
          value: avgMarks,
          icon: Icons.auto_graph_rounded,
          color: Colors.purple,
          onTap: () {
            _showMarksBreakdown();
          },
        ),
      ],
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

  Widget _buildPerformanceCard(BuildContext context, List<ClassModel> classes, StudentProvider studentProvider) {
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
            // Calculate real average marks for this class from students
            final classStudents = studentProvider.students.where((s) => s.classId == c.id).toList();
            double classAverage = 0.0;
            
            if (classStudents.isNotEmpty) {
              double totalMarks = 0.0;
              int studentsWithMarks = 0;
              
              for (var student in classStudents) {
                if (student.averageMarks != null && student.averageMarks! > 0) {
                  totalMarks += student.averageMarks!;
                  studentsWithMarks++;
                }
              }
              
              if (studentsWithMarks > 0) {
                classAverage = totalMarks / studentsWithMarks;
              }
            }
            
            final displayPercent = (classAverage / 100).clamp(0.0, 1.0);
            final displayText = classAverage > 0 ? '${classAverage.toStringAsFixed(1)}% avg' : 'No data';
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          c.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        displayText,
                        style: TextStyle(
                          color: classAverage > 0 ? AppTheme.primaryColor : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: displayPercent,
                      backgroundColor: Colors.grey[200],
                      color: classAverage > 0 ? AppTheme.primaryColor : Colors.grey,
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

  void _showMarksBreakdown() {
    final classes = context.read<ClassProvider>().classes;
    final studentProvider = context.read<StudentProvider>();
    
    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No classes available yet.')),
      );
      return;
    }

    // Calculate overall average marks
    double totalMarks = 0;
    int studentsWithMarks = 0;
    for (var student in studentProvider.students) {
      if (student.averageMarks != null && student.averageMarks! > 0) {
        totalMarks += student.averageMarks!;
        studentsWithMarks++;
      }
    }
    final overallAverage = studentsWithMarks > 0 ? totalMarks / studentsWithMarks : 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Overall average marks
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_graph_rounded,
                      color: Colors.purple,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Average',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        overallAverage > 0 ? '${overallAverage.toStringAsFixed(1)}%' : 'No data',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Average Marks by Class',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final classItem = classes[index];
                    
                    // Calculate average for this class
                    final classStudents = studentProvider.students
                        .where((s) => s.classId == classItem.id)
                        .toList();
                    
                    double classTotal = 0;
                    int classStudentsWithMarks = 0;
                    for (var student in classStudents) {
                      if (student.averageMarks != null && student.averageMarks! > 0) {
                        classTotal += student.averageMarks!;
                        classStudentsWithMarks++;
                      }
                    }
                    
                    final classAverage = classStudentsWithMarks > 0 
                        ? classTotal / classStudentsWithMarks 
                        : 0.0;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.class_,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          classItem.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          '${classStudentsWithMarks} student${classStudentsWithMarks != 1 ? 's' : ''} with marks',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            classAverage > 0 
                                ? '${classAverage.toStringAsFixed(1)}%'
                                : 'No data',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportsScreen(
                                classId: classItem.id,
                                className: classItem.name,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentBreakdown() {
    final classes = context.read<ClassProvider>().classes;
    final totalStudents = context.read<StudentProvider>().studentCount;

    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No classes available yet.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with total students
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      color: Colors.orange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Students',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        totalStudents.toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Students by Class',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final classItem = classes[index];
                    final studentCount = classItem.studentCount ?? 0;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.class_,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          classItem.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          classItem.description ?? 'No description',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                studentCount.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentsScreen(
                                classId: classItem.id,
                                className: classItem.name,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClassSelector(
      BuildContext outerContext, Function(ClassModel) onSelected) {
    final classes = context.read<ClassProvider>().classes;
    if (classes.isEmpty) {
      ScaffoldMessenger.of(outerContext).showSnackBar(
          const SnackBar(content: Text('No classes available. Create one first.')));
      return;
    }
    showModalBottomSheet(
      context: outerContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a Class',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: classes.length,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryLight,
                    child: const Icon(Icons.class_,
                        color: AppTheme.primaryColor, size: 20),
                  ),
                  title: Text(classes[index].name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    // Use Future.delayed to ensure the sheet is fully closed before navigating
                    Future.delayed(const Duration(milliseconds: 300), () {
                      onSelected(classes[index]);
                    });
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
        title: Text(classModel.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassDetailsScreen(classModel: classModel),
            ),
          );
        },
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ActivityItem(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
