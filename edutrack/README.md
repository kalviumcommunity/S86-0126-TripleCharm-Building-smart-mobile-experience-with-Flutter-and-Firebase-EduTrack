# EduTrack
## Responsive Layout Demo

 This workspace includes a responsive screen example that demonstrates using `MediaQuery` and `LayoutBuilder` to adapt UI between phone and tablet layouts.
 
 - **Screen file**: [lib/screens/responsive_home.dart](lib/screens/responsive_home.dart)
 
 Code snippet (how screen width is detected):
 
 ```dart
 final screenWidth = MediaQuery.of(context).size.width;
 final isTablet = screenWidth > 600;
 ```
 
 The demo uses flexible widgets (`Expanded`, `AspectRatio`, `Wrap`, `GridView`) and `LayoutBuilder` to switch between a single-column phone layout and a two-column tablet layout.
 
 Screenshots
 
 - Add screenshots here (portrait phone, landscape phone, tablet portrait, tablet landscape).
 
 Reflection
 
 - Challenges: Handling spacing and text scaling across devices; deciding breakpoints for tablet vs phone.
 - Benefit: Responsive design improves usability across multiple device sizes without duplicating UI code.
# EduTrack – Smart Attendance and Progress Tracker

## 📱 Project Overview

**EduTrack** is a mobile-first Flutter application designed for rural coaching centers to digitally track student attendance and academic progress in real time. Built with Flutter and Firebase, it provides an intuitive interface that requires minimal infrastructure and technical expertise.

**Team Name:** Triple Charm  
**Sprint:** Sprint #2  
**Version:** 1.0 MVP

---

## 🎯 Problem Statement

Rural coaching centers struggle with:
- ❌ Manual, paper-based attendance systems prone to errors
- ❌ Lack of real-time visibility into student performance
- ❌ Data loss and inaccurate records
- ❌ Limited access to digital tools and infrastructure

**Solution:** EduTrack provides a simple, mobile-first app that enables teachers and administrators to record attendance and academic data instantly from anywhere.

---

## 📂 Folder Structure

```
edutrack/
├── lib/
│   ├── main.dart                          # Entry point of the application
│   ├── screens/                           # UI screens
│   │   └── welcome_screen.dart           # Welcome/onboarding screen
│   ├── widgets/                           # Reusable UI components
│   │   └── (custom buttons, cards, etc.)
│   ├── models/                            # Data models & structures
│   │   └── (User, Student, Attendance models)
│   └── services/                          # Firebase & API services
│       └── (Firebase Auth, Firestore operations)
├── assets/
│   ├── images/                            # App images & icons
│   └── icons/                             # Custom icons
├── android/                               # Android-specific configuration
├── ios/                                   # iOS-specific configuration
├── pubspec.yaml                           # Project dependencies & metadata
├── pubspec.lock                           # Locked dependency versions
└── README.md                              # Documentation
```

### 📋 Directory Explanations

| Directory | Purpose | Usage |
|-----------|---------|-------|
| **lib/main.dart** | Application entry point and root widget | Defines the MaterialApp and navigation setup |
| **lib/screens/** | Individual UI screens for each feature | Splash, Login, Dashboard, Student List, Attendance, Progress |
| **lib/widgets/** | Reusable UI components | Custom buttons, cards, input fields for consistency |
| **lib/models/** | Data structures and classes | User, Student, Attendance, Progress models |
| **lib/services/** | Backend integration logic | Firebase Authentication, Firestore CRUD operations |
| **assets/images/** | Static image assets | App branding, icons, illustrations |
| **android/ & ios/** | Platform-specific code | Native Android/iOS configuration and plugins |
| **pubspec.yaml** | Project configuration file | Dependencies (Firebase, etc.), versioning, assets |

---

## 🏗️ Architecture & Modular Design

This structure supports **scalable, modular development**:

1. **Separation of Concerns:** UI (screens), logic (services), and data (models) are separated
2. **Reusability:** Widgets can be reused across multiple screens
3. **Easy Testing:** Models and services are independent and testable
4. **Future Expansion:** New screens, features, and services can be added without affecting existing code
5. **Team Collaboration:** Team members can work on different screens/services in parallel

---

## 📝 Naming Conventions

### Files & Classes

- **Screens:** `*_screen.dart` (e.g., `welcome_screen.dart`, `login_screen.dart`)
- **Widgets:** `*_widget.dart` or descriptive name (e.g., `custom_button.dart`)
- **Models:** PascalCase (e.g., `Student.dart`, `Attendance.dart`)
- **Services:** `*_service.dart` (e.g., `firebase_service.dart`)

### Dart Code

- **Classes:** PascalCase (e.g., `WelcomeScreen`, `StudentList`)
- **Functions/Methods:** camelCase (e.g., `addStudent()`, `markAttendance()`)
- **Variables:** camelCase (e.g., `studentName`, `isPresent`)
- **Constants:** camelCase with `k` prefix (e.g., `kPrimaryColor`, `kAppTitle`)

### Colors & Styling

- **Primary Color:** `0xFF6C63FF` (Purple)
- **Secondary Color:** `0xFF00D4FF` (Cyan)
- **Text Color:** `0xFF2C2C2C` (Dark Gray)

---

## 🚀 Setup Instructions

### Prerequisites

- **Flutter SDK:** [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Android Studio** or **VS Code** with Flutter & Dart extensions
- **Android Emulator** or physical device
- **Git** for version control

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd edutrack
   ```

2. **Verify Flutter installation:**
   ```bash
   flutter doctor
   ```
   Ensure all required tools are installed. You should see a green checkmark for:
   - Flutter SDK
   - Android SDK (for development)
   - Flutter and Dart plugins

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the app on an emulator:**
   ```bash
   flutter run
   ```

   Or if you have a physical device connected:
   ```bash
   flutter run -d <device-id>
   ```

5. **View available devices:**
   ```bash
   flutter devices
   ```

---

## 📲 Current MVP Features

### ✅ Implemented (Sprint #2)

1. **Welcome Screen**
   - AppBar with branding
   - Welcome title and description
   - School icon/logo
   - Interactive "Get Started" button with state changes
   - Responsive design with gradient background

2. **Project Structure**
   - Organized folder hierarchy
   - Modular file organization for future expansion
   - Firebase service layer ready for implementation
   - Model structures for Student, Attendance, Progress

### 🔄 Coming Next (Sprint #3+)

1. Firebase Authentication (Login/Signup)
2. Student Management (Add/View students)
3. Daily Attendance Tracking
4. Academic Progress Entry
5. Data visualization and reports

---

## 🌲 Understanding the Widget Tree & Flutter's Reactive UI Model

### What is a Widget Tree?

In Flutter, **everything is a widget** — from the entire app structure down to individual buttons and text elements. These widgets are organized in a **hierarchical tree structure** called the **widget tree**, where:

- Each node represents a widget (UI component)
- Parent widgets contain child widgets
- The root is typically `MaterialApp` or `CupertinoApp`
- The tree flows from top to bottom, defining the complete UI structure

**Why does this matter?**
- Makes UI composition intuitive and predictable
- Enables Flutter to efficiently track and update only changed parts
- Allows for flexible, reusable component design
- Simplifies debugging with clear parent-child relationships

---

### 📊 EduTrack's Widget Tree Hierarchy

Here's the complete widget tree structure of our **Welcome Screen**:

```
MaterialApp (root)
 └── WelcomeScreen (StatefulWidget)
      └── Scaffold
           ┣━━ AppBar
           ┃    └── Text ('EduTrack - Smart Learning')
           ┃
           └━━ Container (gradient background)
                └── Center
                     └── SingleChildScrollView
                          └── Padding
                               └── Column (main content container)
                                    ┣━━ Text ('Welcome to EduTrack')
                                    ┣━━ SizedBox (spacing)
                                    ┣━━ Text ('Smart Attendance & Progress Tracker')
                                    ┣━━ SizedBox (spacing)
                                    ┣━━ Container (circular icon background)
                                    ┃    └── Icon (school icon)
                                    ┣━━ SizedBox (spacing)
                                    ┣━━ Container (info card)
                                    ┃    └── Text (description)
                                    ┣━━ SizedBox (spacing)
                                    ┣━━ Container (conditional - shows when _showMessage = true)
                                    ┃    └── Text (success message)
                                    ┣━━ SizedBox (conditional spacing)
                                    ┣━━ ElevatedButton (interactive)
                                    ┃    └── Text ('Get Started' or 'Got It!')
                                    ┣━━ SizedBox (spacing)
                                    └━━ Text (version info)
```

**Key Observations:**
- **Root:** MaterialApp wraps the entire application
- **State Management:** WelcomeScreen is a `StatefulWidget`, enabling reactive updates
- **Layout Hierarchy:** Scaffold → Container → Center → Column creates a centered, scrollable layout
- **Conditional Rendering:** The success message Container only appears when `_showMessage = true`
- **Interactive Element:** ElevatedButton triggers state changes via `_toggleMessage()`

---

### ⚛️ Flutter's Reactive UI Model Explained

Flutter uses a **declarative, reactive approach** to UI updates:

#### How It Works:

1. **Declare UI based on current state**
   ```dart
   // State variables
   bool _showMessage = false;
   Color _buttonColor = const Color(0xFF6C63FF);
   ```

2. **User interaction triggers state change**
   ```dart
   void _toggleMessage() {
     setState(() {
       _showMessage = !_showMessage;  // Toggle boolean
       _buttonColor = _showMessage 
           ? const Color(0xFF00D4FF)   // Change to cyan
           : const Color(0xFF6C63FF);  // Back to purple
     });
   }
   ```

3. **Flutter automatically rebuilds affected widgets**
   - Only the `build()` method is re-executed
   - Flutter's diffing algorithm identifies what changed
   - Only modified parts of the tree are re-rendered

#### Real Example from Our WelcomeScreen:

**Initial State:**
- Button shows: "Get Started"
- Button color: Purple (`#6C63FF`)
- Success message: Hidden

**After Button Press (setState triggered):**
- Button shows: "Got It!"
- Button color: Cyan (`#00D4FF`)
- Success message: Visible with border and icon

**What Actually Happened:**
```dart
// When button is pressed:
onPressed: _toggleMessage  // Triggers setState()

// setState() tells Flutter: "Something changed, rebuild this widget"
setState(() {
  _showMessage = !_showMessage;  // false → true
  _buttonColor = _showMessage ? cyan : purple;  // purple → cyan
});

// Flutter re-runs build() method
// Compares old widget tree vs new widget tree
// Updates ONLY the changed parts:
//   1. ElevatedButton text: 'Get Started' → 'Got It!'
//   2. ElevatedButton color: purple → cyan
//   3. Adds Container with success message
```

---

### 🔄 Why Flutter Rebuilds Only Parts of the Tree (Not the Entire UI)

This is Flutter's secret to **blazing-fast performance**:

#### 1. **Widget Tree vs Element Tree vs Render Tree**

Flutter maintains three trees internally:

| Tree | Purpose | Lifecycle |
|------|---------|-----------|
| **Widget Tree** | Immutable configuration (your code) | Rebuilt on every `setState()` |
| **Element Tree** | Mutable connections between widgets & render objects | Updated only when structure changes |
| **Render Tree** | Actual rendering logic | Repainted only when necessary |

#### 2. **Efficient Diffing Algorithm**

When `setState()` is called:
1. Flutter creates a NEW widget tree from `build()`
2. Compares it with the OLD widget tree (O(n) complexity)
3. Identifies differences (diff)
4. Updates only the changed Elements/RenderObjects

**Example from our WelcomeScreen:**
```
setState() called
    ↓
build() re-runs → Creates NEW Column with children
    ↓
Flutter compares:
  Old: Column with 10 children (_showMessage = false)
  New: Column with 12 children (_showMessage = true)
    ↓
Diff detected: 2 new children added (Container + SizedBox)
    ↓
Updates Element tree: Insert new Container element
    ↓
Render tree: Paint only the new Container
```

#### 3. **Stateless vs Stateful Optimization**

- **StatelessWidget:** Completely immutable. If parent doesn't change, child isn't rebuilt
- **StatefulWidget:** Only rebuilds when `setState()` is explicitly called
- **Keys:** Help Flutter identify which widgets are the same across rebuilds

#### 4. **Rebuild vs Repaint vs Relayout**

Not all operations are equally expensive:

| Operation | Cost | When It Happens |
|-----------|------|-----------------|
| **Rebuild** | Low | `setState()` re-runs `build()` (cheap - just code execution) |
| **Relayout** | Medium | Widget size/position changes (requires measurement) |
| **Repaint** | Medium-High | Visual properties change (color, shadows, etc.) |

In our example:
- **Rebuild:** Entire Column's `build()` runs
- **Relayout:** Only new Container needs layout calculation
- **Repaint:** Only button color + new Container painted

---

### 🎬 State Update Demo: Before & After

#### **Before (Initial State)**
```
🖼️ UI Elements Visible:
├─ Title: "Welcome to EduTrack"
├─ Subtitle: "Smart Attendance & Progress Tracker"  
├─ School Icon (purple circle)
├─ Info Card (white background)
├─ Button: "Get Started" (purple #6C63FF)
└─ Version: "Sprint #2 MVP - Version 1.0"

State Variables:
_showMessage = false
_buttonColor = Color(0xFF6C63FF)  // Purple
```

#### **After Button Press (State Updated)**
```
🖼️ UI Elements Visible:
├─ Title: "Welcome to EduTrack"
├─ Subtitle: "Smart Attendance & Progress Tracker"
├─ School Icon (purple circle)
├─ Info Card (white background)
├─ ✨ NEW: Success Message Container (cyan border + background)
│   └─ "✓ You're ready to begin! Proceed to login..."
├─ Button: "Got It!" (cyan #00D4FF)  ← TEXT CHANGED + COLOR CHANGED
└─ Version: "Sprint #2 MVP - Version 1.0"

State Variables:
_showMessage = true  ← CHANGED
_buttonColor = Color(0xFF00D4FF)  ← CHANGED (Cyan)
```

**Visual Changes:**
1. ✅ New Container widget rendered (success message)
2. ✅ Button text updated: "Get Started" → "Got It!"
3. ✅ Button color transitions: Purple → Cyan
4. ✅ Additional SizedBox spacing appears

**Unchanged (Not Rebuilt):**
- AppBar remains the same
- Gradient background Container unchanged
- Title and subtitle Text widgets unchanged
- School Icon unchanged

---

## 💡 Learning Reflections: Dart & Flutter

### What We Learned

**Dart Language Insights:**
- **Null Safety:** Dart's sound null safety prevents many runtime errors. The `?` operator makes nullability explicit
- **State Management:** `setState()` rebuilds UI efficiently. Understanding reactive programming is crucial
- **Widgets are Functions:** Everything in Flutter is a widget. Composition over inheritance makes UI code clean
- **Type System:** Strong typing catches errors at compile time, making code more reliable

**Flutter Framework Benefits:**
- **Hot Reload:** See changes instantly without rebuilding the entire app
- **Widget Composition:** Build complex UIs by combining simple widgets
- **Material Design:** Pre-built components follow Material 3 guidelines
- **Responsive Design:** Easy to create layouts that work across different screen sizes

**Widget Tree Insights:**
- **Everything is a Widget:** From the entire app down to text and icons
- **Tree Structure:** Parent-child relationships make UI composition logical
- **Efficient Updates:** Flutter's diffing algorithm updates only changed widgets
- **Reactive Model:** UI automatically reflects state changes via `setState()`

### How This Structure Helps Build Complex UIs

1. **Scalability:** Separating screens, widgets, and services keeps code organized as the app grows
2. **Reusability:** Common UI patterns (buttons, cards, dialogs) are extracted into reusable widgets
3. **Testability:** Services and models can be tested independently
4. **Maintainability:** Changes to one screen don't affect others
5. **Collaboration:** Team members can work on different features without merge conflicts
6. **Performance:** Modular structure allows lazy loading and code splitting
7. **Predictable Updates:** Reactive model ensures UI always matches current state

### Future Development Strategy

- Use **Provider** or **Riverpod** for state management across multiple screens
- Implement **routing** to navigate between screens cleanly
- Create **shared widgets** for consistent UI/UX across all screens
- Separate **business logic** into services for cleaner code
- Leverage **Keys** for optimizing list rendering performance
- Implement **const constructors** for widgets that never change

---

## 📸 Demo

### Welcome Screen Running

![EduTrack Welcome Screen](./demo/welcome_screen.png)

*Screenshot: The interactive Welcome screen with animated button and state changes*

### Key Features Demonstrated:
- ✓ Clean Material Design UI with custom theming
- ✓ AppBar with EduTrack branding
- ✓ Responsive layout with gradient background
- ✓ Interactive button that toggles message display
- ✓ State management using StatefulWidget
- ✓ Custom color scheme matching brand identity

---

## 🎨 UI Components & Styling

### Theme Colors
- **Primary:** #6C63FF (Purple) - Main brand color
- **Secondary:** #00D4FF (Cyan) - Accent color
- **Background:** White with subtle gradient
- **Text:** #2C2C2C (Dark Gray) for contrast

### Button Styling
- Rounded corners (12px border radius)
- Smooth color transitions on interaction
- Elevated shadows for depth perception

---

## 🔧 Development Workflow

### Running in Development Mode

```bash
# Run with hot reload enabled
flutter run

# Run with verbose logging
flutter run -v

# Run on specific device
flutter run -d <device-id>
```

### Building Release APK

```bash
# Generate optimized APK for testing/demo
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

### Debugging

```bash
# Enable debug painting to visualize widget layout
# Press 'p' in the terminal or use IDE shortcut

# Hot Reload: Press 'r' in terminal
# Hot Restart: Press 'R' in terminal
```

---

## 📊 Project Status

| Task | Status | Owner |
|------|--------|-------|
| Project Setup & Structure | ✅ Complete | Triple Charm |
| Welcome Screen UI | ✅ Complete | P V Sonali (UI Lead) |
| Firebase Authentication | 🔄 In Progress | Bhanusree (Firebase Lead) |
| Student Management | ⏳ Planned | Team |
| Attendance Tracking | ⏳ Planned | Team |
| Testing & Deployment | ⏳ Planned | N Supriya (Testing Lead) |

---

## 🤝 Team Roles

| Role | Team Member | Responsibilities |
|------|-------------|------------------|
| **UI Lead** | P V Sonali | UI design, Flutter screens, responsive layouts |
| **Firebase Lead** | Bhanusree | Auth setup, Firestore schema, security rules |
| **Testing & Deployment Lead** | N Supriya | Testing, bug fixing, APK build, deployment |

---

## 📚 Resources & Documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Material Design 3](https://m3.material.io/)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

---

## 🐛 Known Issues & Solutions

| Issue | Solution |
|-------|----------|
| `flutter doctor` shows SDK issues | Update Flutter SDK: `flutter upgrade` |
| Emulator not starting | Restart Android Studio and select a compatible AVD |
| Dependency conflicts | Run `flutter clean` then `flutter pub get` |
| Build fails on hot reload | Use `flutter run -R` for hot restart |

---

## 📝 Notes for Mentors & Reviewers

- The Welcome screen demonstrates understanding of **StatefulWidget** and **state management**
- Folder structure follows industry best practices for scalability
- Color scheme and design are consistent with EduTrack brand identity
- Code is well-commented and follows Dart naming conventions
- Future sprints will integrate this with Firebase for full functionality

---

## 🎯 Sprint #2 Deliverables Checklist

- ✅ Flutter project created with clean structure
- ✅ Folder hierarchy with screens/, widgets/, models/, services/
- ✅ Welcome screen UI with interactive elements
- ✅ Main.dart updated to use Welcome screen
- ✅ README.md with comprehensive documentation
- ✅ App running successfully on emulator/device
- ✅ Code follows naming conventions and best practices

---

## 📞 Contact & Support

**Team:** Triple Charm  
**Project:** EduTrack – Smart Attendance & Progress Tracker  
**Sprint:** #2 (4-week development cycle)

---

**Last Updated:** January 2026  
**Version:** 1.0 MVP
