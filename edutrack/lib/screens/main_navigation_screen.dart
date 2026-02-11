import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'students_screen.dart';
import 'grades_screen.dart';
import 'profile_screen.dart';

/// Main Navigation Screen with BottomNavigationBar
/// 
/// This screen implements a tab-based navigation system using:
/// - BottomNavigationBar for intuitive navigation
/// - PageView for smooth screen transitions with swipe gestures
/// - PageController for programmatic page control
/// - State preservation to avoid rebuilding screens
/// 
/// Best Practices Implemented:
/// - 4 tabs (recommended 3-5 tabs for optimal UX)
/// - Consistent icons and short labels
/// - Smooth animations with easeInOut curve
/// - State preservation across tab switches
/// - Material Design 3 theming
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Current tab index
  int _currentIndex = 0;
  
  // PageController for managing PageView
  // Initialized outside build() for better performance
  late final PageController _pageController;
  
  // List of screens for each tab
  // Defined as late final to avoid rebuilding on each setState
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize PageController
    _pageController = PageController(initialPage: 0);
    
    // Initialize screens list
    // Using const constructors where possible for better performance
    _screens = const [
      DashboardScreen(),
      StudentsScreen(),
      GradesScreen(),
      ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    // Clean up PageController to prevent memory leaks
    _pageController.dispose();
    super.dispose();
  }

  /// Handles tab selection from BottomNavigationBar
  /// Animates to the selected page with smooth transition
  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Handles page changes from PageView swipes
  /// Updates the current index to sync with BottomNavigationBar
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // PageView allows swipe gestures for navigation
      // Preserves state of each screen
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        // Disable physics if you want to restrict navigation to bottom bar only
        // physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      
      // BottomNavigationBar provides visual navigation interface
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        
        // Styling
        type: BottomNavigationBarType.fixed, // Shows all items even when more than 3
        selectedItemColor: const Color(0xFF6C63FF), // Primary brand color
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true, // Show all labels for clarity
        elevation: 8,
        
        // Navigation items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            activeIcon: Icon(Icons.dashboard, size: 28),
            label: 'Dashboard',
            tooltip: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            activeIcon: Icon(Icons.people, size: 28),
            label: 'Students',
            tooltip: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grade),
            activeIcon: Icon(Icons.grade, size: 28),
            label: 'Grades',
            tooltip: 'Grades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person, size: 28),
            label: 'Profile',
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Alternative Implementation Using IndexedStack
/// 
/// Use this if you prefer no swipe gestures and want to ensure
/// all screens are kept alive and their state is always preserved.
/// 
/// Replace the body in Scaffold with:
/// ```dart
/// body: IndexedStack(
///   index: _currentIndex,
///   children: _screens,
/// ),
/// ```
/// 
/// And update _onTabTapped to:
/// ```dart
/// void _onTabTapped(int index) {
///   setState(() {
///     _currentIndex = index;
///   });
/// }
/// ```

/// UX Best Practices Applied:
/// 
/// 1. Tab Count: 4 tabs (within 3-5 recommended range)
/// 2. Labels: Short and descriptive
/// 3. Icons: Consistent and intuitive
/// 4. Active State: Larger icons and color highlight
/// 5. Smooth Transitions: 300ms animation with easeInOut curve
/// 6. State Preservation: PageView maintains state automatically
/// 7. Accessibility: Tooltips added for screen readers
/// 8. Performance: Screens defined outside build(), const constructors
/// 
/// Common Issues Addressed:
/// - ✅ State preservation (PageView keeps screens alive)
/// - ✅ Smooth navigation (animateToPage with curve)
/// - ✅ Synced selection (PageView onPageChanged updates index)
/// - ✅ No rebuilds (screens defined as late final)
/// - ✅ Memory management (PageController disposed)
