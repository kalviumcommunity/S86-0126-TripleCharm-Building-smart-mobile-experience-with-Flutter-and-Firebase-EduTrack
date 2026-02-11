import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';

/// Theme Toggle Widget
/// A reusable widget that displays a switch to toggle between light and dark themes
class ThemeToggleWidget extends StatelessWidget {
  /// Optional custom label for the switch
  final String? label;
  
  /// Optional icon to display instead of label
  final bool showIcon;
  
  /// Optional callback when theme changes
  final VoidCallback? onThemeChanged;

  const ThemeToggleWidget({
    super.key,
    this.label,
    this.showIcon = false,
    this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    if (showIcon) {
      return IconButton(
        icon: Icon(themeProvider.getThemeIcon()),
        tooltip: 'Toggle ${isDark ? 'Light' : 'Dark'} Mode',
        onPressed: () {
          themeProvider.toggleTheme();
          onThemeChanged?.call();
        },
      );
    }

    return SwitchListTile(
      title: Text(label ?? 'Dark Mode'),
      secondary: Icon(
        isDark ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.primary,
      ),
      value: isDark,
      onChanged: (value) {
        themeProvider.toggleTheme();
        onThemeChanged?.call();
      },
    );
  }
}

/// Simple Theme Toggle Switch (without ListTile)
class SimpleThemeToggle extends StatelessWidget {
  const SimpleThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.light_mode,
          color: !isDark 
              ? Theme.of(context).colorScheme.primary 
              : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 8),
        Switch(
          value: isDark,
          onChanged: (value) => themeProvider.toggleTheme(),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.dark_mode,
          color: isDark 
              ? Theme.of(context).colorScheme.primary 
              : Colors.grey,
          size: 20,
        ),
      ],
    );
  }
}

/// Theme Mode Selector Widget
/// Displays radio buttons for Light, Dark, and System theme modes
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<ThemeMode>(
          title: const Text('Light Mode'),
          subtitle: const Text('Always use light theme'),
          secondary: const Icon(Icons.light_mode),
          value: ThemeMode.light,
          groupValue: themeProvider.themeMode,
          onChanged: (mode) {
            if (mode != null) themeProvider.setThemeMode(mode);
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark Mode'),
          subtitle: const Text('Always use dark theme'),
          secondary: const Icon(Icons.dark_mode),
          value: ThemeMode.dark,
          groupValue: themeProvider.themeMode,
          onChanged: (mode) {
            if (mode != null) themeProvider.setThemeMode(mode);
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('System Default'),
          subtitle: const Text('Follow device theme settings'),
          secondary: const Icon(Icons.brightness_auto),
          value: ThemeMode.system,
          groupValue: themeProvider.themeMode,
          onChanged: (mode) {
            if (mode != null) themeProvider.setThemeMode(mode);
          },
        ),
      ],
    );
  }
}

/// Theme Mode Chip Selector
/// Displays chips for selecting theme mode (more compact)
class ThemeModeChipSelector extends StatelessWidget {
  const ThemeModeChipSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Wrap(
      spacing: 8,
      children: [
        _buildThemeChip(
          context,
          themeProvider,
          ThemeMode.light,
          'Light',
          Icons.light_mode,
        ),
        _buildThemeChip(
          context,
          themeProvider,
          ThemeMode.dark,
          'Dark',
          Icons.dark_mode,
        ),
        _buildThemeChip(
          context,
          themeProvider,
          ThemeMode.system,
          'System',
          Icons.brightness_auto,
        ),
      ],
    );
  }

  Widget _buildThemeChip(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode mode,
    String label,
    IconData icon,
  ) {
    final isSelected = themeProvider.themeMode == mode;
    final colorScheme = Theme.of(context).colorScheme;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) themeProvider.setThemeMode(mode);
      },
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
    );
  }
}
