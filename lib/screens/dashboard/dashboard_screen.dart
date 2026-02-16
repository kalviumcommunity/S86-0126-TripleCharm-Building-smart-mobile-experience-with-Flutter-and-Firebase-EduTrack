import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/student_provider.dart';
import '../../config/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated && authProvider.user != null) {
        context.read<ClassProvider>().fetchClasses(authProvider.user!.uid);
        context.read<StudentProvider>().fetchTeacherStudents(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (!authProvider.isAuthenticated || authProvider.teacher == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome ${authProvider.teacher!.name}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Consumer2<ClassProvider, StudentProvider>(
                  builder: (context, classProvider, studentProvider, _) {
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _StatCard(
                          icon: Icons.class_,
                          label: 'Classes',
                          value: classProvider.classes.length.toString(),
                        ),
                        _StatCard(
                          icon: Icons.people,
                          label: 'Students',
                          value: studentProvider.students.length.toString(),
                        ),
                        _StatCard(
                          icon: Icons.trending_up,
                          label: 'Attendance %',
                          value: '85',
                        ),
                        _StatCard(
                          icon: Icons.payment,
                          label: 'Pending Fees',
                          value: '12',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _ActionButton(
                      icon: Icons.class_,
                      label: 'My Classes',
                      onTap: () => Navigator.pushNamed(context, '/classes'),
                    ),
                    _ActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'Add Class',
                      onTap: () => Navigator.pushNamed(context, '/add-class'),
                    ),
                    _ActionButton(
                      icon: Icons.people,
                      label: 'Students',
                      onTap: () => Navigator.pushNamed(context, '/students'),
                    ),
                    _ActionButton(
                      icon: Icons.person_add_outlined,
                      label: 'Add Student',
                      onTap: () => Navigator.pushNamed(context, '/add-student'),
                    ),
                    _ActionButton(
                      icon: Icons.event_available_outlined,
                      label: 'Mark Attendance',
                      onTap: () => Navigator.pushNamed(context, '/attendance'),
                    ),
                    _ActionButton(
                      icon: Icons.assignment_outlined,
                      label: 'Exams',
                      onTap: () => Navigator.pushNamed(context, '/exams'),
                    ),
                    _ActionButton(
                      icon: Icons.assessment_outlined,
                      label: 'Create Exam',
                      onTap: () => Navigator.pushNamed(context, '/create-exam'),
                    ),
                    _ActionButton(
                      icon: Icons.payment,
                      label: 'Fees',
                      onTap: () => Navigator.pushNamed(context, '/fees'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: AppTheme.secondaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
