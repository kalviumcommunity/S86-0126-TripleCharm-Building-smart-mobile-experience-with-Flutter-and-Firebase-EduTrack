import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import '../widgets/theme_toggle_widget.dart';

/// Theme Settings Screen
/// Allows users to customize the app's theme and appearance
class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        actions: [
          // Quick toggle icon button in app bar
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ThemeToggleWidget(showIcon: true),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Preview Card
          _buildThemePreviewCard(context, isDark),
          
          const SizedBox(height: 24),
          
          // Theme Mode Section
          _buildSectionTitle(context, 'Theme Mode'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ThemeModeSelector(),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Toggle Section
          _buildSectionTitle(context, 'Quick Toggle'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Switch between Light and Dark themes',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Center(child: SimpleThemeToggle()),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Theme Chips Section
          _buildSectionTitle(context, 'Theme Selection Chips'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ThemeModeChipSelector(),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Current Theme Info
          _buildThemeInfoCard(context, themeProvider, isDark),
          
          const SizedBox(height: 24),
          
          // Benefits Section
          _buildBenefitsSection(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildThemePreviewCard(BuildContext context, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  size: 32,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Theme',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        isDark ? 'Dark Mode Active' : 'Light Mode Active',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Color palette preview
            Row(
              children: [
                _buildColorCircle(colorScheme.primary, 'Primary'),
                const SizedBox(width: 12),
                _buildColorCircle(colorScheme.secondary, 'Secondary'),
                const SizedBox(width: 12),
                _buildColorCircle(colorScheme.tertiary, 'Tertiary'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildThemeInfoCard(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isDark,
  ) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Theme Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Mode', themeProvider.getThemeModeDisplayName()),
            _buildInfoRow('Material Version', 'Material 3'),
            _buildInfoRow('Status', isDark ? 'Dark Mode' : 'Light Mode'),
            _buildInfoRow('Persistence', 'Enabled (SharedPreferences)'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.stars,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Theme Benefits',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBenefitItem(
              Icons.visibility,
              'Better Visibility',
              'Reduces eye strain in different lighting conditions',
            ),
            const SizedBox(height: 12),
            _buildBenefitItem(
              Icons.battery_charging_full,
              'Battery Saving',
              'Dark mode reduces battery consumption on OLED screens',
            ),
            const SizedBox(height: 12),
            _buildBenefitItem(
              Icons.accessible,
              'Accessibility',
              'Improves app accessibility for users with visual preferences',
            ),
            const SizedBox(height: 12),
            _buildBenefitItem(
              Icons.palette,
              'Consistent Design',
              'Maintains brand identity across all screens',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
