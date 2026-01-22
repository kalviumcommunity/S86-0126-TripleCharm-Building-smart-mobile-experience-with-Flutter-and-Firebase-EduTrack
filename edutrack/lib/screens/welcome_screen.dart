import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _showMessage = false;
  Color _buttonColor = const Color(0xFF6C63FF);

  void _toggleMessage() {
    setState(() {
      _showMessage = !_showMessage;
      _buttonColor = _showMessage
          ? const Color(0xFF00D4FF)
          : const Color(0xFF6C63FF);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduTrack - Smart Learning'),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6C63FF).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Welcome Title
                  const Text(
                    'Welcome to EduTrack',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  const Text(
                    'Smart Attendance & Progress Tracker',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  // Icon/Logo
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                    ),
                    padding: const EdgeInsets.all(30),
                    child: const Icon(
                      Icons.school,
                      size: 80,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Info Text
                  Container(
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
                    child: const Text(
                      'Track attendance, manage students, and monitor academic progress with ease. Built for rural coaching centers to simplify record keeping and enhance transparency.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Interactive Message
                  if (_showMessage)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D4FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00D4FF),
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        '✓ You\'re ready to begin! Proceed to login to start tracking attendance and student progress.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF00D4FF),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_showMessage) const SizedBox(height: 24),
                  
                  // Interactive Button
                  ElevatedButton(
                    onPressed: _toggleMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _showMessage ? 'Got It!' : 'Get Started',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Version Info
                  Text(
                    'Sprint #2 MVP - Version 1.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
