import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Layout Demo'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section - Full Width Container
              _buildHeaderSection(screenWidth),
              const SizedBox(height: 16),

              // Info Card showing screen dimensions
              _buildInfoCard(screenWidth, screenHeight, isTablet),
              const SizedBox(height: 16),

              // Responsive Grid Layout - Changes based on screen size
              isTablet 
                ? _buildTabletLayout(screenWidth)
                : _buildPhoneLayout(screenWidth),
              
              const SizedBox(height: 16),

              // Feature Cards Row - Horizontal scrollable on phone
              _buildFeatureCardsRow(isTablet),
              const SizedBox(height: 16),

              // Bottom Section with Expanded widgets
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Header Section - Demonstrates Container usage
  Widget _buildHeaderSection(double screenWidth) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard, size: 50, color: Colors.white),
            SizedBox(height: 8),
            Text(
              'EduTrack Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Responsive Layout with Rows & Columns',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // Info Card showing device info
  Widget _buildInfoCard(double width, double height, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.phone_android, 
            '${width.toInt()}px', 'Width'),
          _buildInfoItem(Icons.height, 
            '${height.toInt()}px', 'Height'),
          _buildInfoItem(
            isTablet ? Icons.tablet : Icons.smartphone,
            isTablet ? 'Tablet' : 'Phone',
            'Device',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6C63FF), size: 30),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  // Tablet Layout - Two Column Design
  Widget _buildTabletLayout(double screenWidth) {
    return SizedBox(
      height: 250,
      child: Row(
        children: [
          // Left Panel
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book, size: 50, color: Colors.amber),
                    SizedBox(height: 8),
                    Text(
                      'Left Panel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Tablet Mode', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
          // Right Panel
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment, size: 50, color: Colors.green),
                    SizedBox(height: 8),
                    Text(
                      'Right Panel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Expanded widgets', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Phone Layout - Single Column Design
  Widget _buildPhoneLayout(double screenWidth) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 120,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book, size: 40, color: Colors.amber),
                SizedBox(height: 8),
                Text(
                  'Top Section',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Phone Mode', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment, size: 40, color: Colors.green),
                SizedBox(height: 8),
                Text(
                  'Bottom Section',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Stacked vertically', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Feature Cards - Demonstrates Row usage
  Widget _buildFeatureCardsRow(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feature Cards (Row Layout)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        isTablet
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildFeatureCard(Icons.people, 'Students', Colors.blue)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildFeatureCard(Icons.calendar_today, 'Attendance', Colors.orange)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildFeatureCard(Icons.assessment, 'Reports', Colors.purple)),
                ],
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFeatureCard(Icons.people, 'Students', Colors.blue),
                    const SizedBox(width: 8),
                    _buildFeatureCard(Icons.calendar_today, 'Attendance', Colors.orange),
                    const SizedBox(width: 8),
                    _buildFeatureCard(Icons.assessment, 'Reports', Colors.purple),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, Color color) {
    return Container(
      width: 120,
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Section - Demonstrates Column with Expanded
  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Layout Widgets Used:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildLayoutInfoRow(Icons.view_column, 'Column', 
            'Stacks widgets vertically'),
          const SizedBox(height: 8),
          _buildLayoutInfoRow(Icons.view_week, 'Row', 
            'Arranges widgets horizontally'),
          const SizedBox(height: 8),
          _buildLayoutInfoRow(Icons.crop_square, 'Container', 
            'Holds child with styling'),
          const SizedBox(height: 8),
          _buildLayoutInfoRow(Icons.unfold_more, 'Expanded', 
            'Fills available space'),
        ],
      ),
    );
  }

  Widget _buildLayoutInfoRow(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF), size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
