#!/usr/bin/env bash

# 🧪 EduTrack Testing Script
# This script runs comprehensive integration tests for EduTrack Demo
# Tests account creation, student management, and attendance functionality

echo "🧪 EduTrack Integration Testing Script"
echo "======================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "   Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter detected: $(flutter --version | head -n 1)"

# Change to project directory
PROJECT_DIR="d:/Kalvium/Simulation work/Sem-4/EduTrack-Demo/edutrack_demo"
cd "$PROJECT_DIR" || {
    echo "❌ Could not change to project directory: $PROJECT_DIR"
    exit 1
}

echo "✅ Project directory: $(pwd)"
echo ""

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Failed to get dependencies"
    exit 1
fi
echo "✅ Dependencies updated successfully"
echo ""

# Run the complete integration test
echo "🚀 Running Complete Integration Tests..."
echo "   This will test:"
echo "   • Account creation (teacher & student)"
echo "   • Student management (adding, bulk operations)"
echo "   • Attendance marking and retrieval"
echo "   • Data validation and error handling"
echo ""

flutter test test/complete_integration_test.dart --verbose

# Check test result
if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 ALL TESTS PASSED! 🎉"
    echo "======================================"
    echo "✅ Account creation tests: PASSED"
    echo "✅ Student management tests: PASSED"
    echo "✅ Attendance tests: PASSED"
    echo "✅ Data integrity tests: PASSED"
    echo ""
    echo "Your EduTrack application is working correctly!"
else
    echo ""
    echo "❌ SOME TESTS FAILED"
    echo "======================================"
    echo "Please check the output above for details."
    echo "Common issues:"
    echo "• Firebase not configured properly"
    echo "• Internet connection problems"
    echo "• Missing dependencies"
    echo ""
    echo "Run with --verbose for more details"
fi

echo ""
echo "💡 To run specific test groups:"
echo "   flutter test test/complete_integration_test.dart --name \"Account Creation\""
echo "   flutter test test/complete_integration_test.dart --name \"Student Management\""
echo "   flutter test test/complete_integration_test.dart --name \"Attendance Management\""
echo ""
echo "💡 To run tests in watch mode (re-run on file changes):"
echo "   flutter test --watch test/complete_integration_test.dart"