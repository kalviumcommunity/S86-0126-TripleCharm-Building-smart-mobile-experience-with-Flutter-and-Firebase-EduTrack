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

### How This Structure Helps Build Complex UIs

1. **Scalability:** Separating screens, widgets, and services keeps code organized as the app grows
2. **Reusability:** Common UI patterns (buttons, cards, dialogs) are extracted into reusable widgets
3. **Testability:** Services and models can be tested independently
4. **Maintainability:** Changes to one screen don't affect others
5. **Collaboration:** Team members can work on different features without merge conflicts
6. **Performance:** Modular structure allows lazy loading and code splitting

### Future Development Strategy

- Use **Provider** or **Riverpod** for state management across multiple screens
- Implement **routing** to navigate between screens cleanly
- Create **shared widgets** for consistent UI/UX across all screens
- Separate **business logic** into services for cleaner code

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
