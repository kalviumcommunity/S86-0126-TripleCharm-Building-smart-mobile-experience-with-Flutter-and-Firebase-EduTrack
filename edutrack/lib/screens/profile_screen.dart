import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

/// Profile Screen for Bottom Navigation
/// 
/// This screen is designed to be used within a BottomNavigationBar layout.
/// It displays user information from Firebase Auth and allows logout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigation will be handled automatically by StreamBuilder in main.dart
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String displayName = currentUser?.displayName ?? currentUser?.email?.split('@')[0] ?? 'User';
    final String email = currentUser?.email ?? 'No email';
    final String userId = currentUser?.uid ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove back button for bottom nav
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient background
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
                        child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Profile Information Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // User ID Card
                  _buildInfoCard(
                    icon: Icons.fingerprint,
                    title: 'User ID',
                    value: userId.substring(0, userId.length > 20 ? 20 : userId.length) + '...',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  
                  // Email Verification Status
                  _buildInfoCard(
                    icon: currentUser?.emailVerified == true 
                        ? Icons.verified_user 
                        : Icons.warning,
                    title: 'Email Status',
                    value: currentUser?.emailVerified == true 
                        ? 'Verified' 
                        : 'Not Verified',
                    color: currentUser?.emailVerified == true 
                        ? Colors.green 
                        : Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  
                  // Account Creation
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Member Since',
                    value: currentUser?.metadata.creationTime != null
                        ? _formatDate(currentUser!.metadata.creationTime!)
                        : 'Unknown',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 12),
                  
                  // Last Sign In
                  _buildInfoCard(
                    icon: Icons.access_time,
                    title: 'Last Sign In',
                    value: currentUser?.metadata.lastSignInTime != null
                        ? _formatDate(currentUser!.metadata.lastSignInTime!)
                        : 'Unknown',
                    color: Colors.teal,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // App Info
                  Text(
                    'EduTrack v1.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Bottom Navigation Implementation',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
