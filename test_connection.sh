#!/usr/bin/env bash

# 🔧 EduTrack Firestore Connection Test Script
# This tests the Firestore connection and configuration before running the app

echo "🔧 EduTrack Firestore Connection Test"
echo "======================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

# Change to project directory
PROJECT_DIR="d:/Kalvium/Simulation work/Sem-4/EduTrack-Demo/edutrack_demo"
cd "$PROJECT_DIR" || {
    echo "❌ Could not change to project directory: $PROJECT_DIR"
    exit 1
}

echo "✅ Project directory: $(pwd)"
echo ""

# Check for Firebase configuration
if [ ! -f "lib/firebase_options.dart" ]; then
    echo "❌ Firebase configuration not found!"
    echo "   Please ensure 'lib/firebase_options.dart' exists"
    exit 1
fi

echo "✅ Firebase configuration found"

# Check for pubspec.yaml
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ pubspec.yaml not found!"
    exit 1
fi

echo "✅ pubspec.yaml found"

# Get dependencies
echo ""
echo "📦 Getting Flutter dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Failed to get dependencies"
    exit 1
fi
echo "✅ Dependencies updated"

# Build for web (since you're using Chrome)
echo ""
echo "🏗️ Building for web (to test Firestore connection)..."
flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true
if [ $? -ne 0 ]; then
    echo "❌ Build failed - there might be compilation errors"
    echo "   Try running: flutter analyze"
    exit 1
fi
echo "✅ Build successful"

# Check for common Firestore issues
echo ""
echo "🔍 Checking for common Firestore configuration issues..."

# Check if Firestore rules allow writes
echo "⚠️  Remember to check your Firestore security rules:"
echo "   - Go to Firebase Console > Firestore Database > Rules"
echo "   - For development, you can use:"
echo "     rules_version = '2';"
echo "     service cloud.firestore {"
echo "       match /databases/{database}/documents {"
echo "         match /{document=**} {"
echo "           allow read, write: if request.auth != null;"
echo "         }"
echo "       }"
echo "     }"

echo ""
echo "📊 Network connectivity test..."
ping -c 3 8.8.8.8 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Internet connection is working"
else
    echo "❌ No internet connection detected"
    exit 1
fi

echo ""
echo "🚀 Configuration looks good! You can now run:"
echo "   flutter run -d chrome --web-port=8080"
echo ""
echo "💡 If you still get Firestore timeouts, try:"
echo "1. Check your Firebase project billing (Firestore needs Blaze plan for production)"
echo "2. Verify your internet connection is stable"
echo "3. Check Firebase Console for any service outages"
echo "4. Try running in incognito mode to avoid cache issues"
echo ""
echo "🔍 For debugging, watch the browser console (F12) for detailed errors"