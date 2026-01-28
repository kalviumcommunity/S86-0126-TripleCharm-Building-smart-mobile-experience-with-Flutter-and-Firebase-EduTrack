import 'package:flutter/material.dart';

// === Color Scheme Constants ===
const Color kPrimaryColor = Color(0xFF6C63FF);
const Color kSecondaryColor = Color(0xFF00D4FF);
const Color kTextPrimaryColor = Color(0xFF2C2C2C);
const Color kTextSecondaryColor = Color(0xFF7A7A7A);
const Color kBackgroundColor = Colors.white;
const Color kDividerColor = Color(0xFFE8E8E8);

class ScrollableViews extends StatelessWidget {
  const ScrollableViews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduTrack Scrollable Views'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildSectionHeader(
              context,
              'Subject Categories',
              'Swipe left → right to browse subjects',
            ),
            
            // Horizontal ListView
            _buildHorizontalListView(),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(
                thickness: 1.5,
                color: kDividerColor,
                height: 32,
              ),
            ),
            
            // Vertical ListView Header
            _buildSectionHeader(
              context,
              'Student Attendance Roll',
              'Track daily attendance records',
            ),
            
            // Vertical ListView with ListTiles
            _buildVerticalListView(),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(
                thickness: 1.5,
                color: kDividerColor,
                height: 32,
              ),
            ),
            
            // GridView Header
            _buildSectionHeader(
              context,
              'EduTrack Features',
              'Access all modules and tools',
            ),
            
            // GridView
            _buildGridView(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Section Header Widget with consistent theming
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.08),
        border: Border(
          bottom: BorderSide(
            color: kPrimaryColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: kPrimaryColor,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: 0.5,
            ) ?? const TextStyle(),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: kTextSecondaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ) ?? const TextStyle(),
          ),
        ],
      ),
    );
  }

  // Horizontal ListView with Subject Cards
  Widget _buildHorizontalListView() {
    final subjects = [
      {'name': 'Mathematics', 'icon': Icons.calculate, 'color': Colors.blue, 'count': '24'},
      {'name': 'Physics', 'icon': Icons.science, 'color': Colors.purple, 'count': '18'},
      {'name': 'Chemistry', 'icon': Icons.biotech, 'color': Colors.green, 'count': '22'},
      {'name': 'English', 'icon': Icons.book, 'color': Colors.orange, 'count': '20'},
      {'name': 'History', 'icon': Icons.history_edu, 'color': Colors.teal, 'count': '16'},
      {'name': 'Geography', 'icon': Icons.public, 'color': Colors.indigo, 'count': '19'},
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final color = subject['color'] as Color;
          
          return Container(
            width: 140,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.6),
                  color.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opened ${subject['name']}'),
                      duration: const Duration(milliseconds: 800),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        subject['icon'] as IconData,
                        size: 50,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subject['name'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${subject['count']} classes',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Vertical ListView with Student List
  Widget _buildVerticalListView() {
    final students = List.generate(
      12,
      (index) => {
        'name': 'Student ${index + 1}',
        'email': 'student${index + 1}@edutrack.in',
        'status': index % 3 == 0 ? 'Present' : index % 2 == 0 ? 'Absent' : 'Late',
        'avatar': String.fromCharCode(65 + (index % 26)),
        'rollNo': 'E20${1000 + index}',
      },
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: kPrimaryColor,
                radius: 24,
                child: Text(
                  student['avatar'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              title: Text(
                student['name'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: kTextPrimaryColor,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${student['rollNo']} • ${student['email']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: kTextSecondaryColor,
                  ),
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor, width: 1.5),
                ),
                child: Text(
                  student['status'] as String,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
        'count': '245',
        'subtitle': 'Daily check-ins'
      },
      {
        'title': 'Assignments',
        'icon': Icons.assignment,
        'color': Colors.orange,
        'count': '18',
        'subtitle': 'Pending tasks'
      },
      {
        'title': 'Grades',
        'icon': Icons.grade,
        'color': Colors.green,
        'count': '95',
        'subtitle': 'Avg score'
      },
      {
        'title': 'Schedule',
        'icon': Icons.calendar_today,
        'color': Colors.purple,
        'count': '8',
        'subtitle': 'Classes'
      },
      {
        'title': 'Reports',
        'icon': Icons.assessment,
        'color': Colors.red,
        'count': '5',
        'subtitle': 'Generated'
      },
      {
        'title': 'Messages',
        'icon': Icons.message,
        'color': Colors.teal,
        'count': '34',
        'subtitle': 'Unread'
      },
      {
        'title': 'Library',
        'icon': Icons.library_books,
        'color': Colors.indigo,
        'count': '156',
        'subtitle': 'Books'
      },
      {
        'title': 'Settings',
        'icon': Icons.settings,
        'color': Colors.grey,
        'count': '-',
        'subtitle': 'Configure'
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
        ),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          final color = module['color'] as Color;
          
          return Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: color.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.08),
                    color.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${module['title']} module opened'),
                        duration: const Duration(milliseconds: 800),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          module['icon'] as IconData,
                          size: 44,
                          color: color,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          module['title'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          module['count'] as String,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: color.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          module['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: color.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
