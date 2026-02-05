import 'package:flutter/material.dart';
import 'firestore_queries_demo.dart';

/// Demo Launcher Screen
/// 
/// A simple screen that provides quick access to various
/// Firestore and Firebase demos including the Queries Demo
class DemoLauncherScreen extends StatelessWidget {
  const DemoLauncherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Demos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDemoCard(
              context,
              title: 'Firestore Queries',
              subtitle: 'Filters, Ordering & Limits',
              icon: Icons.filter_list,
              color: Colors.deepPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FirestoreQueriesDemo(),
                  ),
                );
              },
            ),
            _buildDemoCard(
              context,
              title: 'Real-time Sync',
              subtitle: 'StreamBuilder Examples',
              icon: Icons.sync,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/realtime');
              },
            ),
            _buildDemoCard(
              context,
              title: 'Authentication',
              subtitle: 'Login & Sign Up',
              icon: Icons.lock,
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/auth');
              },
            ),
            _buildDemoCard(
              context,
              title: 'Firebase Storage',
              subtitle: 'Media Uploads & Management',
              icon: Icons.cloud_upload,
              color: Colors.teal,
              onTap: () {
                Navigator.pushNamed(context, '/firebase-storage-upload');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
