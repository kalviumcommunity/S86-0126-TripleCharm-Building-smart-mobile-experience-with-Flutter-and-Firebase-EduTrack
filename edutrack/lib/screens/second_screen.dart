import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/info_card.dart';
import '../widgets/like_button.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
        backgroundColor: const Color(0xFF00D4FF),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.navigate_next,
                size: 100,
                color: Color(0xFF00D4FF),
              ),
              const SizedBox(height: 8),
              const LikeButton(),
              const SizedBox(height: 24),
              const Text(
                'Second Screen',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Navigation Successful! 🎉',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D4FF),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'You successfully navigated using Navigator.pushNamed()',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              InfoCard(
                title: 'Navigation Stack Info',
                subtitle:
                    'This screen was pushed onto the navigation stack. Tapping back or calling Navigator.pop() will return to the previous screen.',
                icon: Icons.info_outline,
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Back to Home',
                icon: Icons.arrow_back,
                color: const Color(0xFF00D4FF),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Go to Profile',
                icon: Icons.person,
                outline: true,
                color: const Color(0xFF00D4FF),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile', arguments: 'Jane Smith');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
