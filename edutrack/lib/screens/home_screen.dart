import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.home,
                size: 100,
                color: Color(0xFF6C63FF),
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Navigation Demo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'EduTrack Multi-Screen Navigation System',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Use the buttons below to explore different navigation methods.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Go to Second Screen',
                icon: Icons.arrow_forward,
                color: const Color(0xFF6C63FF),
                onPressed: () {
                  Navigator.pushNamed(context, '/second');
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Go to Profile (with data)',
                icon: Icons.person,
                color: const Color(0xFF00D4FF),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/profile',
                    arguments: 'John Doe',
                  );
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/responsive');
                },
                icon: Icon(Icons.phone_android),
                label: const Text('View Responsive Layout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/scrollable');
                },
                icon: const Icon(Icons.view_list),
                label: const Text('View Scrollable Lists'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'View Widget Demo',
                icon: Icons.widgets,
                outline: true,
                color: const Color(0xFF6C63FF),
                onPressed: () {
                  Navigator.pushNamed(context, '/demo');
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/user-input');
                },
                icon: const Icon(Icons.edit_document),
                label: const Text('User Input Form'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/state-management');
                },
                icon: const Icon(Icons.show_chart),
                label: const Text('State Management Demo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
