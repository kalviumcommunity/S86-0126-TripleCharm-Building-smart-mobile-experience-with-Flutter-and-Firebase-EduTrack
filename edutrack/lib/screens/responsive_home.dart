import 'package:flutter/material.dart';

class ResponsiveHome extends StatelessWidget {
  const ResponsiveHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;

    final header = AppBar(
      title: const Text('EduTrack - Responsive Layout'),
      backgroundColor: const Color(0xFF6C63FF),
    );

    // Phone Layout - Single Column
    Widget contentForPhone() {
      return Column(
        children: [
          // Header Section with Image
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6C63FF),
                        const Color(0xFF00D4FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.school, size: 64, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          // Main Content Area
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Welcome to EduTrack',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Responsive layout adapts to different screen sizes and orientations. This demo uses MediaQuery, LayoutBuilder, and flexible widgets for optimal viewing on phones and tablets.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const Spacer(),
                  // Action Buttons with Wrap for responsiveness
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Get Started'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Learn More'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6C63FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Footer Section
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Mark Attendance'),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Tablet Layout - Two Column Grid
    Widget contentForTablet() {
      return Row(
        children: [
          // Left Panel - Main Content
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                children: [
                  // Feature Image
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6C63FF),
                            const Color(0xFF00D4FF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.school, size: 96, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Grid of Feature Cards
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildFeatureCard('Attendance', Icons.check_circle, Colors.blue),
                        _buildFeatureCard('Progress', Icons.trending_up, Colors.green),
                        _buildFeatureCard('Students', Icons.people, Colors.orange),
                        _buildFeatureCard('Reports', Icons.assessment, Colors.purple),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right Panel - Actions
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey.shade50,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.add_circle, color: Color(0xFF6C63FF)),
                            title: const Text('Add Student'),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(Icons.check_box, color: Color(0xFF6C63FF)),
                            title: const Text('Mark Attendance'),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(Icons.bar_chart, color: Color(0xFF6C63FF)),
                            title: const Text('View Progress'),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(Icons.settings, color: Color(0xFF6C63FF)),
                            title: const Text('Settings'),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('View Dashboard'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: header,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use LayoutBuilder to get available space
          final width = constraints.maxWidth.isFinite ? constraints.maxWidth : screenWidth;
          final tablet = width > 600;
          return SafeArea(
            child: tablet ? contentForTablet() : contentForPhone(),
          );
        },
      ),
    );
  }

  // Helper method to build feature cards
  Widget _buildFeatureCard(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
