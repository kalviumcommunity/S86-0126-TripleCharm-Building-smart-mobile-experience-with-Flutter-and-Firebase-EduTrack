import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import '../widgets/theme_toggle_widget.dart';

/// Comprehensive Examples for Theme Usage in EduTrack
/// This file demonstrates various ways to use the theming system

// ========================================
// EXAMPLE 1: Basic Theme Usage
// ========================================

class BasicThemeExample extends StatelessWidget {
  const BasicThemeExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Access theme colors using Theme.of(context)
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Using theme colors
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'This uses theme colors!',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Buttons automatically use theme
            ElevatedButton(
              onPressed: () {},
              child: const Text('Themed Button'),
            ),
            
            const SizedBox(height: 8),
            
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
            
            const SizedBox(height: 8),
            
            TextButton(
              onPressed: () {},
              child: const Text('Text Button'),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// EXAMPLE 2: Accessing Theme Provider
// ========================================

class ThemeProviderExample extends StatelessWidget {
  const ThemeProviderExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Access ThemeProvider using Provider.of or context.watch/context.read
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Provider Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display current theme mode
            Text(
              'Current Theme: ${themeProvider.getThemeModeDisplayName()}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            
            const SizedBox(height: 24),
            
            // Display theme icon
            Icon(
              themeProvider.getThemeIcon(),
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            
            const SizedBox(height: 24),
            
            // Manual theme switching buttons
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => themeProvider.setLightMode(),
                  icon: const Icon(Icons.light_mode),
                  label: const Text('Light'),
                ),
                ElevatedButton.icon(
                  onPressed: () => themeProvider.setDarkMode(),
                  icon: const Icon(Icons.dark_mode),
                  label: const Text('Dark'),
                ),
                ElevatedButton.icon(
                  onPressed: () => themeProvider.setSystemMode(),
                  icon: const Icon(Icons.brightness_auto),
                  label: const Text('System'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Simple toggle button
            ElevatedButton(
              onPressed: () => themeProvider.toggleTheme(),
              child: const Text('Toggle Theme'),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// EXAMPLE 3: Using Theme Toggle Widgets
// ========================================

class ThemeToggleWidgetsExample extends StatelessWidget {
  const ThemeToggleWidgetsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Toggle Widgets'),
        // Icon button in app bar
        actions: const [
          ThemeToggleWidget(showIcon: true),
          SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Various Theme Toggle Widgets',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 16),
          
          // ListTile style toggle
          const Card(
            child: ThemeToggleWidget(
              label: 'Enable Dark Mode',
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Simple toggle
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Simple Switch Toggle'),
                  SizedBox(height: 8),
                  SimpleThemeToggle(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Radio buttons
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Theme Mode Selector',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const ThemeModeSelector(),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Chip selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Chips',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const ThemeModeChipSelector(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// EXAMPLE 4: Responsive to Theme Changes
// ========================================

class ResponsiveThemeExample extends StatelessWidget {
  const ResponsiveThemeExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if dark mode is active
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Theme'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display different images based on theme
            Image.asset(
              isDark 
                  ? 'assets/images/logo_dark.png' 
                  : 'assets/images/logo_light.png',
              width: 200,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Conditional styling based on theme
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                // Different shadow in light mode
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                isDark 
                    ? '🌙 Dark mode is active!'
                    : '☀️ Light mode is active!',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// EXAMPLE 5: Theme with Navigation
// ========================================

class ThemeNavigationExample extends StatelessWidget {
  const ThemeNavigationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Example'),
        actions: const [
          ThemeToggleWidget(showIcon: true),
          SizedBox(width: 8),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Theme Settings'),
            subtitle: const Text('Customize app appearance'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/theme-settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Theming'),
            subtitle: const Text('Learn about theme features'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showThemeInfoDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showThemeInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Theming'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Material 3 Design'),
            SizedBox(height: 8),
            Text('✅ Light & Dark Themes'),
            SizedBox(height: 8),
            Text('✅ System Theme Support'),
            SizedBox(height: 8),
            Text('✅ Persistent Preferences'),
            SizedBox(height: 8),
            Text('✅ Dynamic Color Scheme'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ========================================
// EXAMPLE 6: Custom Themed Widgets
// ========================================

class CustomThemedWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  
  const CustomThemedWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Card(
      // Card automatically uses theme colors
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: colorScheme.onPrimaryContainer,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example usage of custom themed widget
class CustomWidgetExample extends StatelessWidget {
  const CustomWidgetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Themed Widgets'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          CustomThemedWidget(
            icon: Icons.home,
            title: 'Home',
            subtitle: 'Navigate to home screen',
          ),
          SizedBox(height: 8),
          CustomThemedWidget(
            icon: Icons.person,
            title: 'Profile',
            subtitle: 'View your profile',
          ),
          SizedBox(height: 8),
          CustomThemedWidget(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'Customize app settings',
          ),
        ],
      ),
    );
  }
}
