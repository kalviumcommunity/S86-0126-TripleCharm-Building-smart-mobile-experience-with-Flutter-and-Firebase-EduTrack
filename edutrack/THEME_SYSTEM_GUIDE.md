# 🎨 Theme System Documentation - EduTrack

Complete guide to implementing and using the dark mode and dynamic theming system in EduTrack.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Installation & Setup](#installation--setup)
4. [File Structure](#file-structure)
5. [Usage Guide](#usage-guide)
6. [Components](#components)
7. [Best Practices](#best-practices)
8. [Common Issues](#common-issues)
9. [Examples](#examples)

---

## 🌟 Overview

EduTrack implements a comprehensive theming system using:
- **Material 3 Design** - Modern, adaptive design system
- **Provider** - State management for theme changes
- **SharedPreferences** - Persistent theme storage
- **Custom Themes** - Fully customizable light and dark themes

### Why Theming Matters

✅ **Enhanced UX** - Better user experience in different lighting conditions  
✅ **Battery Savings** - Dark mode reduces battery consumption on OLED screens  
✅ **Accessibility** - Improves app accessibility for users with visual preferences  
✅ **Brand Consistency** - Maintains consistent design across all screens  
✅ **Modern UI** - Meets user expectations for modern mobile apps  

---

## 🚀 Features

- ✨ **Light & Dark Themes** - Complete custom themes optimized for each mode
- 🌓 **System Theme Support** - Automatically follows device settings
- 💾 **Persistent Storage** - Remembers user preference across app restarts
- 🎨 **Material 3** - Uses latest Material Design guidelines
- 🔄 **Dynamic Switching** - Instant theme changes without app restart
- 🎯 **Multiple Toggle Options** - Switch, Radio, Chip, and Icon toggles
- 📱 **Fully Responsive** - All UI components adapt to theme changes

---

## 📦 Installation & Setup

### 1. Dependencies

Already added to `pubspec.yaml`:

```yaml
dependencies:
  provider: ^6.1.2
  shared_preferences: ^2.2.3
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Project Structure

The theming system has been automatically set up in your project.

---

## 📁 File Structure

```
edutrack/
├── lib/
│   ├── main.dart                    # App entry with ThemeProvider
│   ├── utils/
│   │   ├── theme_light.dart         # Light theme configuration
│   │   ├── theme_dark.dart          # Dark theme configuration
│   │   └── theme_provider.dart      # Theme state management
│   ├── screens/
│   │   └── theme_settings_screen.dart  # Theme settings UI
│   ├── widgets/
│   │   └── theme_toggle_widget.dart    # Reusable theme toggles
│   └── examples/
│       └── theme_usage_examples.dart   # Implementation examples
```

---

## 💡 Usage Guide

### Basic Usage

#### 1. Access Current Theme

```dart
// In any widget
final colorScheme = Theme.of(context).colorScheme;
final textTheme = Theme.of(context).textTheme;

// Use theme colors
Container(
  color: colorScheme.primary,
  child: Text(
    'Themed Text',
    style: textTheme.titleLarge,
  ),
)
```

#### 2. Access Theme Provider

```dart
// Get theme provider
final themeProvider = Provider.of<ThemeProvider>(context);

// Check current mode
bool isDark = themeProvider.isDarkMode;
String mode = themeProvider.getThemeModeDisplayName(); // "Light", "Dark", "System"
IconData icon = themeProvider.getThemeIcon();
```

#### 3. Change Theme

```dart
// Toggle between light and dark
themeProvider.toggleTheme();

// Set specific mode
themeProvider.setLightMode();
themeProvider.setDarkMode();
themeProvider.setSystemMode();

// Or use ThemeMode enum
themeProvider.setThemeMode(ThemeMode.dark);
```

---

## 🧩 Components

### 1. Theme Provider (`theme_provider.dart`)

Manages theme state with persistence.

**Methods:**
- `toggleTheme()` - Toggle between light/dark
- `setLightMode()` - Force light theme
- `setDarkMode()` - Force dark theme
- `setSystemMode()` - Follow device settings
- `getThemeModeDisplayName()` - Get readable name
- `getThemeIcon()` - Get theme icon

### 2. Theme Configurations

**Light Theme** (`theme_light.dart`)
- Primary: `#6C63FF` (Purple)
- Background: `#F5F5F5` (Light gray)
- Surface: White
- Optimized for daylight viewing

**Dark Theme** (`theme_dark.dart`)
- Primary: `#8B82FF` (Light purple)
- Background: `#121212` (True black)
- Surface: `#1E1E1E` (Dark gray)
- OLED optimized for battery saving

### 3. Toggle Widgets

#### ThemeToggleWidget
```dart
// ListTile style with switch
ThemeToggleWidget(
  label: 'Dark Mode',
  onThemeChanged: () => print('Theme changed'),
)

// Icon button for app bars
ThemeToggleWidget(showIcon: true)
```

#### SimpleThemeToggle
```dart
// Compact switch with icons
SimpleThemeToggle()
```

#### ThemeModeSelector
```dart
// Radio buttons for Light/Dark/System
ThemeModeSelector()
```

#### ThemeModeChipSelector
```dart
// Compact chip selector
ThemeModeChipSelector()
```

### 4. Theme Settings Screen

Complete settings page accessible via:
```dart
Navigator.pushNamed(context, '/theme-settings');
```

Features:
- Theme preview with color palette
- Multiple toggle options
- Current theme information
- Benefits explanation

---

## ✅ Best Practices

### 1. Always Use Theme Colors

❌ **DON'T:**
```dart
Container(color: Colors.blue)
Text('Hello', style: TextStyle(color: Colors.black))
```

✅ **DO:**
```dart
Container(color: Theme.of(context).colorScheme.primary)
Text('Hello', style: Theme.of(context).textTheme.bodyLarge)
```

### 2. Responsive to Theme

```dart
// Check brightness
final isDark = Theme.of(context).brightness == Brightness.dark;

// Use different assets
Image.asset(isDark ? 'dark_logo.png' : 'light_logo.png')

// Conditional styling
Container(
  color: isDark ? Colors.grey[800] : Colors.grey[200],
)
```

### 3. Use Material 3 Components

The themes are built for Material 3. Always use:
- `FilledButton` and `FilledButton.tonal`
- `Card` with elevation
- `NavigationBar` instead of BottomNavigationBar
- Color roles: `primary`, `secondary`, `tertiary`, `surface`, etc.

### 4. Provider Best Practices

```dart
// For rebuilding on change
final theme = Provider.of<ThemeProvider>(context);
// or
final theme = context.watch<ThemeProvider>();

// For actions without rebuild
context.read<ThemeProvider>().toggleTheme();
```

### 5. Theme Persistence

The system automatically saves user preferences. No manual action needed!

---

## ⚠️ Common Issues & Fixes

### Issue 1: Theme Doesn't Update

**Cause:** Not using Provider.of or watch  
**Fix:**
```dart
// ❌ Wrong
final theme = ThemeProvider();

// ✅ Correct
final theme = Provider.of<ThemeProvider>(context);
```

### Issue 2: UI Flickers on Toggle

**Cause:** Rebuilding entire app  
**Fix:** Theme provider is already at app root in `main.dart`

### Issue 3: Some Widgets Have Fixed Colors

**Cause:** Hard-coded colors  
**Fix:** Use theme colors everywhere:
```dart
// ❌ Wrong
color: Colors.white

// ✅ Correct
color: Theme.of(context).colorScheme.surface
```

### Issue 4: Theme Not Persisting

**Cause:** SharedPreferences not initialized  
**Fix:** Already handled in ThemeProvider constructor

---

## 📝 Examples

### Example 1: Simple Theme Toggle

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Screen'),
        actions: [
          ThemeToggleWidget(showIcon: true),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<ThemeProvider>().toggleTheme();
          },
          child: Text('Toggle Theme'),
        ),
      ),
    );
  }
}
```

### Example 2: Settings Page

```dart
ListTile(
  leading: Icon(Icons.palette),
  title: Text('Theme'),
  subtitle: Text('Customize appearance'),
  onTap: () {
    Navigator.pushNamed(context, '/theme-settings');
  },
)
```

### Example 3: Conditional UI

```dart
final isDark = Theme.of(context).brightness == Brightness.dark;

Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: isDark 
        ? [Colors.grey[900]!, Colors.black]
        : [Colors.blue[50]!, Colors.white],
    ),
  ),
)
```

### Example 4: Custom Themed Card

```dart
Card(
  child: ListTile(
    leading: CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        Icons.person,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    ),
    title: Text('User Name'),
    subtitle: Text('user@email.com'),
  ),
)
```

---

## 🎯 Quick Navigation

### Add Theme Toggle to Any Screen

```dart
// In AppBar
AppBar(
  actions: [ThemeToggleWidget(showIcon: true)],
)

// In Settings
ThemeToggleWidget(label: 'Dark Mode')

// As Floating Action Button
FloatingActionButton(
  onPressed: () => context.read<ThemeProvider>().toggleTheme(),
  child: Icon(context.watch<ThemeProvider>().getThemeIcon()),
)
```

### Navigate to Settings

```dart
Navigator.pushNamed(context, '/theme-settings');
```

---

## 🔧 Customization

### Modify Theme Colors

Edit `theme_light.dart` or `theme_dark.dart`:

```dart
// Change primary color
const Color primaryColor = Color(0xFF6C63FF); // Your color here

// Update ColorScheme
colorScheme: ColorScheme.fromSeed(
  seedColor: primaryColor,
  brightness: Brightness.light,
)
```

### Add Custom Theme Properties

```dart
// In theme files
ThemeData(
  // ... existing theme
  extensions: [
    MyCustomColors(accent: Colors.orange),
  ],
)
```

---

## 📚 Additional Resources

- [Material 3 Guidelines](https://m3.material.io/)
- [Flutter Theming Docs](https://docs.flutter.dev/cookbook/design/themes)
- [Provider Package](https://pub.dev/packages/provider)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)

---

## 🎓 Learning Outcomes

After implementing this theming system, you've learned:

✅ Material 3 design system implementation  
✅ State management with Provider  
✅ Data persistence with SharedPreferences  
✅ Creating custom themes  
✅ Building reusable UI components  
✅ Best practices for production apps  
✅ Accessibility considerations  

---

## 📞 Support

For issues or questions:
1. Check [Common Issues](#common-issues) section
2. Review example files in `lib/examples/theme_usage_examples.dart`
3. Refer to Flutter documentation

---

**Happy Theming! 🎨**

*Built with ❤️ for EduTrack*
