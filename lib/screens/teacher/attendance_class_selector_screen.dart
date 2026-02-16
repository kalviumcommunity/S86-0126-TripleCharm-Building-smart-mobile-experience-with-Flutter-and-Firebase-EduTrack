import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/class_provider.dart';
import '../../models/class_model.dart';
import 'attendance_screen.dart';

/// Screen to select a class for marking attendance
class AttendanceClassSelectorScreen extends StatelessWidget {
  const AttendanceClassSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<ClassProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Class for Attendance'),
        elevation: 0,
      ),
      body: classProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : classProvider.classes.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: classProvider.classes.length,
                  itemBuilder: (context, index) {
                    final classData = classProvider.classes[index];
                    return _buildClassCard(context, classData);
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No classes found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          const Text('Create a class first to mark attendance'),
        ],
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassModel classData) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.class_rounded, color: AppTheme.primaryColor),
        ),
        title: Text(
          classData.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${classData.studentCount ?? 0} Students',
              style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttendanceScreen(
                classId: classData.id,
                className: classData.name,
              ),
            ),
          );
        },
      ),
    );
  }
}
