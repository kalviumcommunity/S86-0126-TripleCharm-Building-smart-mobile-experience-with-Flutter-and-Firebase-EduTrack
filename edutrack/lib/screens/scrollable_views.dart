import 'package:flutter/material.dart';

class ScrollableViews extends StatelessWidget {
  const ScrollableViews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrollable Views Demo'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildSectionHeader(
              'ListView - Horizontal Scroll',
              'Swipe left/right to see cards',
            ),
            
            // Horizontal ListView
            _buildHorizontalListView(),
            
            const Divider(thickness: 2, height: 32),
            
            // Vertical ListView Header
            _buildSectionHeader(
              'ListView.builder - Vertical List',
              'Students list with avatars',
            ),
            
            // Vertical ListView with ListTiles
            _buildVerticalListView(),
            
            const Divider(thickness: 2, height: 32),
            
            // GridView Header
            _buildSectionHeader(
              'GridView.builder - Grid Layout',
              'EduTrack feature modules',
            ),
            
            // GridView
            _buildGridView(),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Section Header Widget
  Widget _buildSectionHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Horizontal ListView with Cards
  Widget _buildHorizontalListView() {
    final subjects = [
      {'name': 'Mathematics', 'icon': Icons.calculate, 'color': Colors.blue},
      {'name': 'Science', 'icon': Icons.science, 'color': Colors.green},
      {'name': 'History', 'icon': Icons.history_edu, 'color': Colors.orange},
      {'name': 'English', 'icon': Icons.book, 'color': Colors.purple},
      {'name': 'Geography', 'icon': Icons.public, 'color': Colors.teal},
    ];

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (subject['color'] as Color).withOpacity(0.7),
                  (subject['color'] as Color),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  subject['icon'] as IconData,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  subject['name'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Vertical ListView with Student List
  Widget _buildVerticalListView() {
    final students = List.generate(
      10,
      (index) => {
        'name': 'Student ${index + 1}',
        'email': 'student${index + 1}@edutrack.com',
        'status': index % 3 == 0 ? 'Present' : index % 2 == 0 ? 'Absent' : 'Late',
        'avatar': String.fromCharCode(65 + index),
      },
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          final statusColor = student['status'] == 'Present'
              ? Colors.green
              : student['status'] == 'Absent'
                  ? Colors.red
                  : Colors.orange;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF6C63FF),
                child: Text(
                  student['avatar'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                student['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                student['email'] as String,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  student['status'] as String,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // GridView with Feature Modules
  Widget _buildGridView() {
    final modules = [
      {
        'title': 'Attendance',
        'icon': Icons.how_to_reg,
        'color': Colors.blue,
        'count': '245'
      },
      {
        'title': 'Assignments',
        'icon': Icons.assignment,
        'color': Colors.orange,
        'count': '18'
      },
      {
        'title': 'Grades',
        'icon': Icons.grade,
        'color': Colors.green,
        'count': '12'
      },
      {
        'title': 'Schedule',
        'icon': Icons.calendar_today,
        'color': Colors.purple,
        'count': '8'
      },
      {
        'title': 'Reports',
        'icon': Icons.assessment,
        'color': Colors.red,
        'count': '5'
      },
      {
        'title': 'Messages',
        'icon': Icons.message,
        'color': Colors.teal,
        'count': '34'
      },
      {
        'title': 'Library',
        'icon': Icons.library_books,
        'color': Colors.indigo,
        'count': '156'
      },
      {
        'title': 'Settings',
        'icon': Icons.settings,
        'color': Colors.grey,
        'count': '-'
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          return Container(
            decoration: BoxDecoration(
              color: (module['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (module['color'] as Color).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  module['icon'] as IconData,
                  size: 48,
                  color: module['color'] as Color,
                ),
                const SizedBox(height: 12),
                Text(
                  module['title'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: module['color'] as Color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  module['count'] as String,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: (module['color'] as Color).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
