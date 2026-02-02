import 'package:flutter/material.dart';

class ResponsiveDemo extends StatelessWidget {
  const ResponsiveDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Demo'),
        backgroundColor: const Color(0xFF6C63FF),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use LayoutBuilder constraints for layout decisions
          final maxWidth = constraints.maxWidth;

          if (maxWidth < 600) {
            // Mobile layout: vertical stacking, use MediaQuery percentages
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.22,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('Mobile Top Panel', style: TextStyle(fontSize: 18))),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.18,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('Mobile Bottom Panel', style: TextStyle(fontSize: 18))),
                    ),
                    const SizedBox(height: 12),
                    _buildResponsiveButtons(isTablet: false, screenWidth: screenWidth),
                  ],
                ),
              ),
            );
          }

          // Tablet / Large layout: two-column design
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.04, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: screenHeight * 0.7,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('Tablet Left Panel', style: TextStyle(fontSize: 20))),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: Text('Tablet Right Top', style: TextStyle(fontSize: 18))),
                        ),
                      ),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _buildResponsiveButtons(isTablet: true, screenWidth: screenWidth),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResponsiveButtons({required bool isTablet, required double screenWidth}) {
    if (isTablet) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: () {}, child: const Text('Action A')),
            ElevatedButton(onPressed: () {}, child: const Text('Action B')),
            ElevatedButton(onPressed: () {}, child: const Text('Action C')),
          ],
        ),
      );
    }

    // Mobile: stacked buttons sized relative to screen width
    return Column(
      children: [
        SizedBox(
          width: screenWidth * 0.9,
          child: ElevatedButton(onPressed: () {}, child: const Text('Primary Action')),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: screenWidth * 0.9,
          child: OutlinedButton(onPressed: () {}, child: const Text('Secondary')),
        ),
      ],
    );
  }
}
