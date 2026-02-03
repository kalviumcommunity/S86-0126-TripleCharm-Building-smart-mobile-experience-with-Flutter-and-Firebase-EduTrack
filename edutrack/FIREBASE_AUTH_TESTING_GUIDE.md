# Firebase Authentication Testing Guide

## Complete Testing Checklist

### 1. Signup/Registration Tests

#### Valid Signup
- [ ] Sign up with valid email and password (6+ characters)
- [ ] Verify user appears in Firebase Console → Authentication → Users
- [ ] Verify email format is correct in Firebase
- [ ] App navigates to home/dashboard screen automatically

#### Invalid Email Tests
- [ ] Try signup with invalid email format (missing @domain)
  - Expected: "The email address is invalid" error
- [ ] Try signup with empty email
  - Expected: Validation error "Please enter your email"
- [ ] Try signup with spaces in email
  - Expected: Email validation error

#### Invalid Password Tests
- [ ] Try signup with password less than 6 characters
  - Expected: "Password should be at least 6 characters" error
- [ ] Try signup with empty password
  - Expected: Validation error "Please enter your password"
- [ ] Try signup with spaces only
  - Expected: Validation error

#### Duplicate Email Tests
- [ ] Sign up with email "test@example.com"
- [ ] Try signing up again with same email
  - Expected: "An account already exists for that email" error
- [ ] Verify user is only listed once in Firebase Console

#### Form Validation Tests
- [ ] Submit form with empty fields
  - Expected: Validation errors appear
- [ ] Submit form with only email filled
  - Expected: "Please enter your password" error
- [ ] Try to proceed without checking password match (on signup)
  - Expected: "Passwords do not match" error

### 2. Login Tests

#### Valid Login
- [ ] Log in with correct email and password
  - Expected: Navigate to home/dashboard
- [ ] Log in with uppercase email (should be case-insensitive)
  - Expected: Login successful
- [ ] Log in with extra spaces around email (should be trimmed)
  - Expected: Login successful

#### Invalid Credentials Tests
- [ ] Try login with wrong password
  - Expected: "Wrong password provided" error
- [ ] Try login with non-existent email
  - Expected: "No user found for that email" error
- [ ] Try login with valid email but empty password
  - Expected: Validation error

#### Form Validation Tests
- [ ] Try login with invalid email format
  - Expected: Email validation error
- [ ] Submit empty form
  - Expected: Validation errors appear
- [ ] Try email with special characters only
  - Expected: Email validation error

### 3. Password Visibility Tests

#### Password Toggle
- [ ] Check that password is hidden by default (dots/asterisks shown)
- [ ] Click "show password" icon
  - Expected: Password becomes visible
- [ ] Click "hide password" icon
  - Expected: Password is hidden again
- [ ] Verify toggle works in both signup and login modes

### 4. Mode Switching Tests

#### Login to Signup
- [ ] On login screen, click "Create new account"
  - Expected: Switch to signup form
  - Expected: Confirm password field appears
- [ ] Verify password toggle works
- [ ] Fill form and submit

#### Signup to Login
- [ ] On signup screen, click "Already have an account? Login"
  - Expected: Switch to login form
  - Expected: Confirm password field disappears
- [ ] Verify email and password fields are cleared
- [ ] Fill form and submit

### 5. Authentication State Tests

#### User Persistence
- [ ] Log in successfully
- [ ] Close and reopen the app
  - Expected: User remains logged in (no login screen)
- [ ] Navigate back without logging out
  - Expected: User still logged in

#### Logout Functionality
- [ ] Log in successfully
- [ ] Click logout button
  - Expected: Navigate to login screen
  - Expected: User data is cleared
- [ ] Close and reopen app
  - Expected: Login screen appears (user logged out)

#### Auth State Stream
- [ ] Start app while logged out
  - Expected: Auth stream emits `null`
- [ ] Log in
  - Expected: Auth stream emits `User` object
- [ ] Log out
  - Expected: Auth stream emits `null` again

### 6. Error Handling Tests

#### Network Errors
- [ ] Turn off internet connection
- [ ] Try to sign up
  - Expected: "Network error. Please check your internet connection"
- [ ] Try to log in
  - Expected: Network error message
- [ ] Try to log out
  - Expected: Network error message
- [ ] Turn internet back on and retry
  - Expected: Operations succeed

#### Rate Limiting
- [ ] Attempt login 5+ times with wrong password
  - Expected: "Too many login attempts. Please try again later"
- [ ] Wait a few minutes and try again
  - Expected: Can log in again

#### Error Message Display
- [ ] Trigger various errors (invalid email, weak password, etc.)
- [ ] Verify error messages are displayed clearly
- [ ] Verify error message can be dismissed
- [ ] Check that UI remains responsive during errors

### 7. Loading State Tests

#### Loading Indicators
- [ ] Click login/signup button
  - Expected: Spinner/loading indicator appears
  - Expected: Button is disabled
- [ ] Complete operation
  - Expected: Loading indicator disappears
  - Expected: Navigation happens or error shows
- [ ] Attempt to click button while loading
  - Expected: No additional requests sent

#### Long Operations
- [ ] Simulate slow network (using Chrome DevTools)
- [ ] Click login/signup
  - Expected: Loading state persists until response
  - Expected: Can dismiss loading by going back

### 8. Firebase Console Verification Tests

#### User Creation Verification
- [ ] Sign up new user in app
- [ ] Go to Firebase Console
- [ ] Click Authentication → Users
  - Expected: New user appears in list
  - Expected: Email matches what was entered
  - Expected: Creation date is recent

#### User Properties
- [ ] Click on a user in Firebase Console
- [ ] Verify the following properties are displayed:
  - [ ] User ID (UID)
  - [ ] Email address
  - [ ] Email verified status
  - [ ] Creation time
  - [ ] Last sign-in time
  - [ ] Sign-in providers

#### User Management
- [ ] Disable a user in Firebase Console
- [ ] Try to log in with that user
  - Expected: "This user account has been disabled" error
- [ ] Enable the user
  - Expected: Can log in successfully again
- [ ] Delete a user
  - Expected: User no longer appears in list
  - Expected: Cannot log in with that user

### 9. Security Tests

#### Password Security
- [ ] Verify passwords are never displayed in plain text in logs
- [ ] Verify password field input is masked
- [ ] Verify password is not sent to app logs
- [ ] Verify password is only sent over HTTPS to Firebase

#### Email Validation
- [ ] Verify email regex accepts valid emails
  - test@example.com
  - user.name@sub.domain.co.uk
  - name+tag@example.com
- [ ] Verify email regex rejects invalid emails
  - missing@domain
  - @example.com
  - user@
  - user name@example.com

#### Token Management
- [ ] Log in successfully
- [ ] Verify auth token is stored securely
- [ ] Verify token is refreshed automatically
- [ ] Log out and verify token is cleared

### 10. UI/UX Tests

#### Responsive Design
- [ ] Test on different phone sizes (small, medium, large)
- [ ] Test on tablets
- [ ] Test on landscape orientation
- [ ] Verify all fields are accessible and visible

#### Accessibility
- [ ] Test with screen reader (TalkBack on Android, VoiceOver on iOS)
- [ ] Verify all labels are readable
- [ ] Verify error messages are announced
- [ ] Verify button purposes are clear

#### User Feedback
- [ ] Verify success messages are shown after signup
- [ ] Verify success messages are shown after login
- [ ] Verify error messages are clear and helpful
- [ ] Verify loading states provide feedback

### 11. Edge Cases

#### Special Characters
- [ ] Sign up with email containing allowed special chars (. + -)
  - Expected: Success
- [ ] Try signup with email containing invalid chars (/ \ | etc)
  - Expected: Validation error

#### Long Inputs
- [ ] Enter very long email (200+ chars)
- [ ] Enter very long password (100+ chars)
- [ ] Verify app doesn't crash and validation works

#### Unicode Characters
- [ ] Try signup with unicode characters in password
  - Expected: Should work (if provider supports it)

### 12. Performance Tests

#### Signup/Login Speed
- [ ] Measure time from clicking button to navigation
  - Expected: < 5 seconds on good network
- [ ] Measure time on slow network
  - Expected: Loading state shows, doesn't freeze UI

#### Memory Tests
- [ ] Sign in/out multiple times
- [ ] Check for memory leaks in Flutter DevTools
- [ ] Verify controllers are disposed properly

## Test Execution

### Manual Testing Steps

1. **Prepare Test Environment**
   ```bash
   flutter clean
   flutter pub get
   flutter run --release
   ```

2. **Open Firebase Console**
   - Go to firebase.google.com
   - Select your "edutrack" project
   - Open Authentication tab

3. **Run Tests Systematically**
   - Follow checklist order
   - Mark each test as Pass/Fail
   - Screenshot failures
   - Document issues

### Automated Testing Example

```dart
// In test/ directory
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  group('Firebase Auth Tests', () {
    test('Sign up with valid credentials', () async {
      final auth = FirebaseAuth.instance;
      final result = await auth.createUserWithEmailAndPassword(
        email: 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
        password: 'password123',
      );
      
      expect(result.user, isNotNull);
      expect(result.user!.email, contains('@example.com'));
    });

    test('Login with invalid password', () async {
      final auth = FirebaseAuth.instance;
      
      expect(
        () => auth.signInWithEmailAndPassword(
          email: 'nonexistent@example.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });
}
```

## Issue Tracking Template

```markdown
## Test Case: [Test Name]
- Status: Pass / Fail
- Date: [Date]
- Device: [Device Info]
- Expected: [What should happen]
- Actual: [What happened]
- Steps to Reproduce:
  1. [Step 1]
  2. [Step 2]
- Screenshot: [Attach screenshot if applicable]
- Notes: [Additional notes]
```

## Success Criteria

- [ ] All 12 test categories pass
- [ ] No unhandled exceptions
- [ ] Users visible in Firebase Console
- [ ] Error messages are user-friendly
- [ ] App doesn't crash on errors
- [ ] Performance is acceptable
- [ ] Accessibility requirements met
