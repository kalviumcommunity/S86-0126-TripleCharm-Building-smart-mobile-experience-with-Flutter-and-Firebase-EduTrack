# Screenshots Directory

This folder contains screenshots demonstrating the EduTrack app functionality and setup verification.

## Required Screenshots

### Setup Verification (Task 0)
- [ ] `flutter_doctor_output.png` - Flutter Doctor showing healthy setup
- [ ] `emulator_first_run.png` - EduTrack running on Android emulator
- [ ] `chrome_web_run.png` - EduTrack running on Chrome browser

### Firebase Integration (Task 3)
- [ ] `firebase_auth_success.png` - Successful signup/login
- [ ] `firestore_data_display.png` - Dashboard showing Firestore data
- [ ] `firebase_console.png` - Firebase Console showing users and data

### App Features
- [ ] `welcome_screen.png` - Welcome/onboarding screen
- [ ] `login_screen.png` - Login screen UI
- [ ] `signup_screen.png` - Signup screen UI
- [ ] `dashboard_screen.png` - Dashboard with student list

## How to Capture Screenshots

### For Android Emulator:
1. Run `flutter run -d emulator-5554`
2. In emulator, press `Ctrl + S` or use toolbar camera icon
3. Screenshots saved to: `C:\Users\YourName\.android\avd\*.avd\screenshots\`

### For Chrome:
1. Run `flutter run -d chrome`
2. Press `F12` → Device Toolbar → Camera icon
3. Or use Windows Snipping Tool (`Win + Shift + S`)

### For Flutter Doctor:
1. Run `flutter doctor -v`
2. Take screenshot of terminal output
3. Save as `flutter_doctor_output.png`

## Screenshot Guidelines

- **Resolution**: Minimum 1280x720 for clarity
- **Format**: PNG (preferred) or JPG
- **Content**: Ensure sensitive data is hidden (emails, API keys)
- **Naming**: Use descriptive names matching the checklist above
- **Size**: Keep under 2MB each for GitHub

---

**Note**: Add actual screenshots here before final submission. Placeholders are currently referenced in README.md.
