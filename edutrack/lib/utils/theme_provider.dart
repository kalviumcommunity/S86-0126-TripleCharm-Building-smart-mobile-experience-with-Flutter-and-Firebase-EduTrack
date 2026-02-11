import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Provider for managing app theme state
/// Supports Light, Dark, and System theme modes with persistence
class ThemeProvider with ChangeNotifier {
  // Private theme mode, defaults to system
  ThemeMode _themeMode = ThemeMode.system;
  
  // SharedPreferences key for storing theme preference
  static const String _themePrefKey = 'theme_mode';
  
  // Getter for current theme mode
  ThemeMode get themeMode => _themeMode;
  
  // Check if dark mode is currently active
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  // Check if light mode is currently active
  bool get isLightMode => _themeMode == ThemeMode.light;
  
  // Check if system mode is currently active
  bool get isSystemMode => _themeMode == ThemeMode.system;
  
  /// Constructor - loads saved theme preference
  ThemeProvider() {
    _loadThemePreference();
  }
  
  /// Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePrefKey);
      
      if (savedTheme != null) {
        _themeMode = _getThemeModeFromString(savedTheme);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }
  
  /// Save theme preference to SharedPreferences
  Future<void> _saveThemePreference(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePrefKey, mode.toString());
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }
  
  /// Set theme mode and persist the choice
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    await _saveThemePreference(mode);
  }
  
  /// Toggle between light and dark mode
  /// Note: This doesn't use system mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
  
  /// Set dark mode (convenience method)
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }
  
  /// Set light mode (convenience method)
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }
  
  /// Set system mode (follow device settings)
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }
  
  /// Convert ThemeMode to string for storage
  String _getThemeModeString(ThemeMode mode) {
    return mode.toString();
  }
  
  /// Convert string to ThemeMode from storage
  ThemeMode _getThemeModeFromString(String modeString) {
    switch (modeString) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
  
  /// Get theme mode display name
  String getThemeModeDisplayName() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
  
  /// Get theme icon based on current mode
  IconData getThemeIcon() {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
