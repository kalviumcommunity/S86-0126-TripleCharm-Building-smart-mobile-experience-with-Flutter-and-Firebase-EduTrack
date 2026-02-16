import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'teacher_dashboard_screen.dart';
import 'classes_screen.dart';
import 'attendance_class_selector_screen.dart';
import 'reports_screen.dart';
import '../profile/profile_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/class_provider.dart';

class TeacherMainScreen extends StatefulWidget {
  const TeacherMainScreen({super.key});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const TeacherDashboardScreen(isTab: true),
      const ClassesScreen(),
      const AttendanceClassSelectorScreen(),
      const _TeacherReportsPlaceholder(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.class_outlined),
              activeIcon: Icon(Icons.class_),
              label: 'Classes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherReportsPlaceholder extends StatelessWidget {
  const _TeacherReportsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<ClassProvider>();
    final selectedClass = classProvider.selectedClass;

    if (selectedClass == null) {
      return Scaffold(
         appBar: AppBar(title: const Text('Reports')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text('Select a class to view reports'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                   // This is a placeholder, ideally we'd switch to Classes tab
                },
                child: const Text('Go to Classes'),
              ),
            ],
          ),
        ),
      );
    }

    return ReportsScreen(
      classId: selectedClass.id,
      className: selectedClass.name,
    );
  }
}
