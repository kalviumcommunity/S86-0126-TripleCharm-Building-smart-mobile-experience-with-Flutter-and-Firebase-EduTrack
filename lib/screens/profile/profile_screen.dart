import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset if cancelled
        final user = context.read<AuthProvider>().user;
        _nameController.text = user?.name ?? '';
        _phoneController.text = user?.phone ?? '';
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AuthProvider>().updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (mounted) {
      if (success) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${context.read<AuthProvider>().error ?? 'Update failed'}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              const Text('Change Password'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscurePassword = !obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmController,
                obscureText: obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (passwordController.text.isEmpty || passwordController.text != confirmController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }

                final authProvider = context.read<AuthProvider>();
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                final success = await authProvider.changePassword(passwordController.text);
                
                if (mounted) {
                  navigator.pop();
                  if (success) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Password changed successfully'), backgroundColor: Colors.green),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(content: Text(authProvider.error ?? 'Failed to change password')),
                    );
                  }
                }
              },
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          if (user == null) return const Center(child: CircularProgressIndicator());

          return CustomScrollView(
            slivers: [
              // Modern App Bar with Gradient
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withAlpha(200),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          // Profile Avatar with Edit Button
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(50),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      fontSize: 40, 
                                      fontWeight: FontWeight.bold, 
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              if (!_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _toggleEdit,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(30),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (_isEditing)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _toggleEdit,
                    ),
                ],
              ),
              
              // Content
              SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      
                      // Name & Role Badge
                      if (!_isEditing) ...[
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: user.role == 'teacher' 
                                ? Colors.blue.withAlpha(30)
                                : Colors.purple.withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                user.role == 'teacher' ? Icons.school : Icons.person,
                                size: 16,
                                color: user.role == 'teacher' ? Colors.blue : Colors.purple,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                user.role.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: user.role == 'teacher' ? Colors.blue : Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      if (_isEditing) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Edit Your Profile',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      // Personal Information Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withAlpha(20),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.person_outline, 
                                        color: AppTheme.primaryColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Personal Information',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                
                                // Full Name
                                TextFormField(
                                  controller: _nameController,
                                  enabled: _isEditing,
                                  style: TextStyle(
                                    color: _isEditing ? Colors.black : Colors.grey[700],
                                    fontWeight: _isEditing ? FontWeight.normal : FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Full Name',
                                    prefixIcon: const Icon(Icons.person),
                                    filled: true,
                                    fillColor: _isEditing ? Colors.grey[100] : Colors.transparent,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _isEditing ? Colors.grey[300]! : Colors.transparent,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _isEditing ? Colors.grey[300]! : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 16),
                                
                                // Email
                                TextFormField(
                                  initialValue: user.email,
                                  enabled: false,
                                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    helperText: 'Email cannot be changed',
                                    helperStyle: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                    prefixIcon: const Icon(Icons.email),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Phone
                                TextFormField(
                                  controller: _phoneController,
                                  enabled: _isEditing,
                                  style: TextStyle(
                                    color: _isEditing ? Colors.black : Colors.grey[700],
                                    fontWeight: _isEditing ? FontWeight.normal : FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    prefixIcon: const Icon(Icons.phone),
                                    filled: true,
                                    fillColor: _isEditing ? Colors.grey[100] : Colors.transparent,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _isEditing ? Colors.grey[300]! : Colors.transparent,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _isEditing ? Colors.grey[300]! : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Save Button (when editing)
                      if (_isEditing)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: _saveProfile,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text(
                                'Save Changes',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      
                      // Actions (when not editing)
                      if (!_isEditing) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              children: [
                                _buildActionTile(
                                  icon: Icons.lock_outline,
                                  title: 'Change Password',
                                  subtitle: 'Update your account password',
                                  color: Colors.orange,
                                  onTap: _showChangePasswordDialog,
                                ),
                                Divider(height: 1, color: Colors.grey[300]),
                                _buildActionTile(
                                  icon: Icons.info_outline,
                                  title: 'About',
                                  subtitle: 'Version 1.0.0',
                                  color: Colors.blue,
                                  onTap: () {
                                    showAboutDialog(
                                      context: context,
                                      applicationName: 'EduTrack',
                                      applicationVersion: '1.0.0',
                                      applicationLegalese: '© 2026 EduTrack. All rights reserved.',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Logout Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () => _handleLogout(context, authProvider),
                              icon: const Icon(Icons.logout),
                              label: const Text(
                                'Logout',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout from your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              authProvider.logout();
              Navigator.pop(context);
            }, 
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
