```dart
/// 🏗️ THEME SYSTEM ARCHITECTURE
/// 
/// This file provides a visual overview of how the theme system works in EduTrack

/*

┌─────────────────────────────────────────────────────────────────────────┐
│                             ARCHITECTURE FLOW                           │
└─────────────────────────────────────────────────────────────────────────┘

1. APP INITIALIZATION
   ═══════════════════
   
   main.dart
      │
      ├─ Initialize Firebase
      ├─ ChangeNotifierProvider<ThemeProvider>
      │     │
      │     └─ Loads saved theme from SharedPreferences
      │
      └─ MaterialApp
            ├─ theme: getLightTheme()
            ├─ darkTheme: getDarkTheme()
            └─ themeMode: themeProvider.themeMode


2. THEME PROVIDER STATE
   ═══════════════════
   
   ThemeProvider (ChangeNotifier)
      │
      ├─ State: ThemeMode (light/dark/system)
      ├─ Load from SharedPreferences
      ├─ Save to SharedPreferences
      │
      └─ Methods:
            ├─ toggleTheme()
            ├─ setLightMode()
            ├─ setDarkMode()
            ├─ setSystemMode()
            └─ getThemeModeDisplayName()


3. THEME CONFIGURATION
   ═══════════════════
   
   ┌─────────────────┐         ┌─────────────────┐
   │  theme_light.dart   │         │  theme_dark.dart    │
   ├─────────────────┤         ├─────────────────┤
   │ • Primary Color │         │ • Primary Color │
   │ • Background    │         │ • Background    │
   │ • Surface       │         │ • Surface       │
   │ • Text Styles   │         │ • Text Styles   │
   │ • Button Styles │         │ • Button Styles │
   │ • Input Styles  │         │ • Input Styles  │
   └─────────────────┘         └─────────────────┘
           ▲                           ▲
           │                           │
           └──────── Applied by ───────┘
                   MaterialApp


4. UI COMPONENTS
   ═════════════
   
   theme_toggle_widget.dart
      │
      ├─ ThemeToggleWidget
      │     └─ ListTile with Switch
      │
      ├─ SimpleThemeToggle
      │     └─ Compact Switch with Icons
      │
      ├─ ThemeModeSelector
      │     └─ Radio Buttons (Light/Dark/System)
      │
      └─ ThemeModeChipSelector
            └─ FilterChips for Selection


5. USER INTERACTION FLOW
   ═══════════════════════
   
   User Action
      │
      ├─ Toggles Theme Switch
      │     │
      │     ├─ Widget calls ThemeProvider method
      │     │
      │     ├─ ThemeProvider updates state
      │     │     ├─ _themeMode = new mode
      │     │     ├─ notifyListeners()
      │     │     └─ Save to SharedPreferences
      │     │
      │     └─ MaterialApp rebuilds
      │           │
      │           └─ Applies new theme
      │                 │
      │                 └─ All widgets update instantly
      │
      └─ App Restarts
            │
            └─ ThemeProvider loads saved preference
                  │
                  └─ App starts with user's last choice


6. DATA FLOW
   ═════════
   
   ┌──────────────┐
   │   User Input │
   └──────┬───────┘
          │
          ▼
   ┌──────────────────┐
   │ Toggle Widget    │
   │ (UI Component)   │
   └──────┬───────────┘
          │
          │ context.read<ThemeProvider>()
          │
          ▼
   ┌──────────────────┐
   │ ThemeProvider    │
   │ (State Manager)  │
   └──────┬───────────┘
          │
          ├─────────────┬──────────────┐
          │             │              │
          ▼             ▼              ▼
   ┌──────────┐  ┌──────────┐  ┌──────────────┐
   │ Update   │  │ Persist  │  │ Notify       │
   │ State    │  │ to Disk  │  │ Listeners    │
   └──────────┘  └──────────┘  └──────┬───────┘
                                       │
                                       ▼
                              ┌──────────────────┐
                              │ MaterialApp      │
                              │ Rebuilds         │
                              └──────┬───────────┘
                                     │
                                     ▼
                              ┌──────────────────┐
                              │ Apply New Theme  │
                              │ All Screens      │
                              └──────────────────┘


7. WIDGET TREE WITH PROVIDER
   ═══════════════════════════
   
   main()
      │
      └─ runApp(
            ChangeNotifierProvider(
               create: (_) => ThemeProvider(),
               child: MyApp(),
            )
         )
               │
               └─ MyApp
                     │
                     └─ Consumer/Provider.of/context.watch
                           │
                           ├─ Read current theme mode
                           │
                           └─ Pass to MaterialApp
                                 │
                                 └─ All child widgets
                                       │
                                       └─ Access via Theme.of(context)


8. PERSISTENCE MECHANISM
   ══════════════════════
   
   ┌────────────────────────────────────────┐
   │         SharedPreferences              │
   │  (Key-Value Storage on Device)         │
   ├────────────────────────────────────────┤
   │  Key: "theme_mode"                     │
   │  Value: "ThemeMode.dark" | "light" |   │
   │         "system"                       │
   └────────────────────────────────────────┘
              ▲                    │
              │                    │
       Save   │                    │  Load
              │                    ▼
   ┌────────────────────────────────────────┐
   │         ThemeProvider                  │
   │                                        │
   │  _saveThemePreference()                │
   │  _loadThemePreference()                │
   └────────────────────────────────────────┘


9. THEME APPLICATION TO WIDGETS
   ═════════════════════════════
   
   Any Widget in App
      │
      ├─ Access Theme
      │     Theme.of(context).colorScheme
      │     Theme.of(context).textTheme
      │
      ├─ Use Theme Colors
      │     Container(
      │       color: colorScheme.primary
      │     )
      │
      ├─ Use Theme Text Styles
      │     Text(
      │       style: textTheme.titleLarge
      │     )
      │
      └─ Check Current Brightness
            Theme.of(context).brightness == Brightness.dark


10. COMPLETE LIFECYCLE
    ═══════════════════
    
    App Startup
       │
       ├─ Initialize Firebase
       ├─ Create ThemeProvider
       │     └─ Load saved theme from SharedPreferences
       │
       ├─ Wrap MaterialApp with Provider
       │
       ├─ Apply themes to MaterialApp
       │
       └─ User sees UI with saved theme
             │
             ├─ User interacts with toggle
             │     │
             │     ├─ State updates
             │     ├─ Save to disk
             │     ├─ Notify listeners
             │     └─ UI rebuilds
             │
             └─ App closes
                   │
                   └─ Theme preference persisted
                         │
                         └─ Next launch uses saved theme


11. ERROR HANDLING
    ══════════════
    
    ThemeProvider
       │
       ├─ Loading Theme
       │     try {
       │       SharedPreferences.getInstance()
       │     } catch (e) {
       │       debugPrint('Error loading')
       │       → Default to system theme
       │     }
       │
       └─ Saving Theme
             try {
               prefs.setString()
             } catch (e) {
               debugPrint('Error saving')
               → Continue with current theme
             }


╔════════════════════════════════════════════════════════════════════════╗
║                        KEY CONCEPTS                                    ║
╠════════════════════════════════════════════════════════════════════════╣
║                                                                        ║
║  1. Provider Pattern      → State management                          ║
║  2. ChangeNotifier        → Reactive updates                          ║
║  3. SharedPreferences     → Data persistence                          ║
║  4. Material 3            → Design system                             ║
║  5. Theme.of(context)     → Access current theme                      ║
║  6. ColorScheme           → Color management                          ║
║  7. ThemeMode             → Light/Dark/System                         ║
║                                                                        ║
╚════════════════════════════════════════════════════════════════════════╝

*/

// Example: Complete Theme Usage in a Widget
class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Access theme
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // 2. Access theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // 3. Check current mode
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Example'),
        // 4. Add toggle
        actions: const [
          ThemeToggleWidget(showIcon: true),
        ],
      ),
      body: Column(
        children: [
          // 5. Use theme colors
          Container(
            color: colorScheme.primary,
            child: Text(
              'Themed Container',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          
          // 6. Conditional UI based on theme
          if (isDark)
            const Text('Dark mode is active')
          else
            const Text('Light mode is active'),
            
          // 7. Theme toggle button
          ElevatedButton(
            onPressed: () => themeProvider.toggleTheme(),
            child: const Text('Toggle Theme'),
          ),
        ],
      ),
    );
  }
}
```
