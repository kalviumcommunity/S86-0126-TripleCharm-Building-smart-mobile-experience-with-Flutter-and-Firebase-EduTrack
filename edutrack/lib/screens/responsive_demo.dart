import 'package:flutter/material.dart';

class ResponsiveDemo extends StatelessWidget {
  const ResponsiveDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Responsive Demo')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use LayoutBuilder constraints for structural decisions
          if (constraints.maxWidth < 600) {
            // Mobile layout using MediaQuery for proportional sizing
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.18,
                    decoration: BoxDecoration(
                      color: Colors.tealAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('Mobile View', style: TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(height: 16),
                  Text('Width: ${screenWidth.toStringAsFixed(0)} px'),
                  Text('Height: ${screenHeight.toStringAsFixed(0)} px'),
                ],
              ),
            );
          } else {
            // Tablet / large screen layout
            return Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('Tablet Left Panel', style: TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 24),
                  Container(
                    width: 300,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.tealAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('Tablet Right Panel', style: TextStyle(fontSize: 18))),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
