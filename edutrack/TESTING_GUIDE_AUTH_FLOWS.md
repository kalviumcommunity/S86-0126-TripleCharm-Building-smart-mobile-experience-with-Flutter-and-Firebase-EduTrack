# Firebase Authentication Flows - Testing Guide

## 📋 Overview

This guide provides step-by-step instructions to test the complete Sign Up, Login, and Logout flows implemented in Lesson 2.

---

## 🎯 Pre-Testing Setup

### Prerequisites
1. Have the Flutter app running (or ready to run)
2. Have Firebase Console open in browser: https://console.firebase.google.com/
3. Have your device/emulator ready
4. Clear app data before starting (for fresh install test)

### Testing Environment
- **Project ID:** `edutrack-49094`
- **App Type:** Flutter (Android/iOS)
- **Firebase Services:** Authentication, Firestore

---

## 📝 Test Case 1: Fresh Install Sign Up

### Objective
Verify that a new user can sign up, account is created in Firebase, and user is automatically navigated to DashboardScreen.

### Steps

1. **Start with Fresh App**
   - Clear app data: Settings > Apps > EduTrack > Storage > Clear Data
   - Or reinstall app
   - Open Firebase Console: https://console.firebase.google.com/project/edutrack-49094/authentication/users

2. **Observe Initial Screen**
   ```
   ✅ Expected: AuthScreen appears with "Sign Up" and "Login" tabs
   ✅ Expected: No user is logged in yet
   ```

3. **Fill Sign Up Form**
   - Tab: "Sign Up"
   - Email: `testuser1@example.com`
   - Password: `TestPass123!`
   - Name: `Test User One`
   - School: `Test University`
   - Tap "Create Account" button

4. **Monitor Sign Up Process**
   ```
   ⏳ Expected: Button shows loading indicator
   ⏳ Expected: No errors appear
   ⏳ Expected: Takes 2-3 seconds to complete
   ```

5. **Verify Account Creation**
   - **In App:** Should automatically navigate to DashboardScreen
     ```
     ✅ Expected: Dashboard loads
     ✅ Expected: User info card shows "Test User One"
     ✅ Expected: Email shows "testuser1@example.com"
     ✅ Expected: Student list is empty
     ✅ Expected: Pull-to-refresh works
     ```
   - **In Firebase Console:**
     ```
     ✅ Expected: New user appears in Authentication > Users
     ✅ Expected: UID matches what app shows
     ✅ Expected: Created Date is "today"
     ```
   - **In Firestore:**
     - Navigate to: Firestore Database > Collections > `users`
     ```
     ✅ Expected: New document with UID as key
     ✅ Expected: Fields: email, name, school, createdAt
     ✅ Expected: Values match what was entered
     ```

### Success Criteria
- [ ] Account created successfully in Firebase Auth
- [ ] User automatically navigated to DashboardScreen
- [ ] User info displayed correctly on dashboard
- [ ] User document created in Firestore
- [ ] No errors shown in app or console

### Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| "User not created" error | Firebase not initialized | Check Firebase config in main.dart |
| Stays on AuthScreen after signup | AuthService.signUp() not triggered | Check auth_screen.dart _handleSignUp() |
| User data not in Firestore | FirestoreService.addUserData() failed | Check Firestore permissions in Firebase Console |
| Email validation error | Invalid email format | Use proper email format (test@domain.com) |

---

## 📝 Test Case 2: Login After Sign Up

### Objective
Verify that a user can log in with correct credentials and see their previous data.

### Steps

1. **Close App Completely**
   - Swipe app away from recent apps
   - Or use "Stop" in Android Studio/Xcode
   - Wait 2 seconds

2. **Reopen App**
   ```
   ⏳ Expected: App loading screen/splash
   ⏳ Expected: Brief moment of checking auth state
   ✅ Expected: AuthScreen appears (login screen)
   ```

3. **Fill Login Form**
   - Tab: "Login"
   - Email: `testuser1@example.com`
   - Password: `TestPass123!`
   - Tap "Login" button

4. **Monitor Login Process**
   ```
   ⏳ Expected: Button shows loading indicator
   ⏳ Expected: No errors appear
   ⏳ Expected: Takes 2-3 seconds
   ```

5. **Verify Login Success**
   - **In App:**
     ```
     ✅ Expected: Automatically navigate to DashboardScreen
     ✅ Expected: User info shows "Test User One"
     ✅ Expected: Shows previously created students (if any)
     ✅ Expected: No data loss
     ```
   - **In Firebase Console:**
     - Check Authentication > Users > Last Signed In
     ```
     ✅ Expected: Updated to current time
     ```

### Success Criteria
- [ ] Login successful with correct credentials
- [ ] Automatically navigated to DashboardScreen
- [ ] User data loaded correctly
- [ ] Previous students appear (if any were added)
- [ ] No errors shown

### Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| "Invalid password" error | Wrong password entered | Verify password is correct |
| "User not found" error | Wrong email entered | Check email spelling |
| Login button keeps loading | Network issue | Check internet connection |
| AuthScreen keeps showing | AuthService.login() not called | Check auth_screen.dart _handleLogin() |

---

## 📝 Test Case 3: Wrong Credentials Login

### Objective
Verify that error handling works for invalid credentials.

### Steps

1. **On LoginTab, Enter Wrong Password**
   - Email: `testuser1@example.com`
   - Password: `WrongPassword123`
   - Tap "Login"

2. **Observe Error Handling**
   ```
   ✅ Expected: Error dialog appears
   ✅ Expected: Message: "The password is invalid" or similar
   ✅ Expected: Dismiss error by tapping "OK"
   ✅ Expected: Stay on AuthScreen (don't navigate)
   ```

3. **Try Wrong Email**
   - Email: `wrongemail@example.com`
   - Password: `TestPass123!`
   - Tap "Login"

4. **Observe Error**
   ```
   ✅ Expected: Error message indicates user not found
   ✅ Expected: Stay on AuthScreen
   ```

### Success Criteria
- [ ] Wrong password shows appropriate error
- [ ] Wrong email shows appropriate error
- [ ] App doesn't navigate on error
- [ ] User can retry with correct credentials
- [ ] No app crash

---

## 📝 Test Case 4: Logout Flow

### Objective
Verify that logout properly clears session and navigates to AuthScreen.

### Steps

1. **Start Logged In**
   - Log in with: `testuser1@example.com` / `TestPass123!`
   - Verify you're on DashboardScreen with user data

2. **Locate Logout Button**
   - Look at AppBar (top right area)
   ```
   ✅ Expected: Logout icon button (or "Logout" text)
   ```

3. **Tap Logout Button**
   - Icon should show loading indicator during logout
   ```
   ⏳ Expected: Button becomes disabled and shows spinner
   ⏳ Expected: Takes 1-2 seconds
   ```

4. **Verify Logout Success**
   ```
   ✅ Expected: Automatically navigate to AuthScreen
   ✅ Expected: AuthScreen appears fresh (Sign Up tab)
   ✅ Expected: No user data visible
   ✅ Expected: Empty email/password fields
   ```

5. **Verify Session Cleared**
   - Try to log in with a different account:
   - Email: Create a new test account (e.g., `testuser2@example.com`)
   - Or log in with different credentials
   ```
   ✅ Expected: Logs in successfully with new account
   ✅ Expected: Old user data not visible
   ```

### Success Criteria
- [ ] Logout button works without errors
- [ ] Automatically navigated to AuthScreen after logout
- [ ] Session properly cleared (can't use old session)
- [ ] Can log in with different account immediately
- [ ] No data from previous user visible

### Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Logout button doesn't work | _handleLogout() not connected | Check button onPressed callback |
| Stay on DashboardScreen | authStateChanges() not emitting null | Check _authService.logout() in AuthService |
| App crashes on logout | Exception not caught | Check try-catch in _handleLogout() |
| Loading indicator stuck | mounted check missing | Verify if (mounted) before setState |

---

## 📝 Test Case 5: Persistent Login (App Restart)

### Objective
Verify that session persists when app is closed and reopened.

### Steps

1. **Start Logged In**
   - Log in with: `testuser1@example.com`
   - Wait for DashboardScreen to fully load with user data

2. **Close App Completely**
   ```
   ⏳ Expected: App closes
   ⏳ Expected: Session saved locally by Firebase
   ```

3. **Wait 5 Seconds**
   - This simulates time passing and ensures session is truly saved

4. **Reopen App**
   ```
   ⏳ Expected: App splash/loading screen
   ⏳ Expected: Firebase checks local session cache
   ⏳ Expected: Takes 2-3 seconds to initialize
   ```

5. **Verify Persistent Session**
   ```
   ✅ Expected: DashboardScreen appears (NOT AuthScreen)
   ✅ Expected: User data loads
   ✅ Expected: No login required
   ```

### Success Criteria
- [ ] Session persists across app close/open
- [ ] User automatically logged in on app restart
- [ ] User data loads immediately
- [ ] No manual login required
- [ ] Previous students still visible

### Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Shows AuthScreen instead | Firebase not restoring session | Check Firebase initialization |
| User data missing | Firestore takes time to load | Wait longer or pull-to-refresh |
| Very slow to load | Network lag | Check internet connection |

---

## 📝 Test Case 6: Weak Password Validation

### Objective
Verify that password validation works before Firebase call.

### Steps

1. **On SignupTab**
   - Email: `newuser@example.com`
   - Password: `123` (less than 6 characters)
   - Name: `New User`
   - School: `Test School`
   - Tap "Create Account"

2. **Observe Validation**
   ```
   ✅ Expected: Form validation error appears
   ✅ Expected: Message: "Password must be at least 6 characters"
   ✅ Expected: Button not tapped (form validation blocked it)
   ✅ Expected: No Firebase call made
   ```

3. **Fix Password and Retry**
   - Change password to: `StrongPass123!`
   - Tap "Create Account"
   ```
   ✅ Expected: Account created successfully
   ✅ Expected: Navigate to DashboardScreen
   ```

### Success Criteria
- [ ] Weak password rejected by form validation
- [ ] User-friendly error message shown
- [ ] No Firebase call made for invalid form
- [ ] Can fix and retry successfully

---

## 📝 Test Case 7: Duplicate Email Prevention

### Objective
Verify that Firebase prevents creating account with existing email.

### Steps

1. **Try to Sign Up with Existing Email**
   - Email: `testuser1@example.com` (from Test Case 1)
   - Password: `NewPassword123!`
   - Name: `Another User`
   - School: `Another School`
   - Tap "Create Account"

2. **Observe Error Handling**
   ```
   ✅ Expected: Error dialog appears
   ✅ Expected: Message: "The email address is already in use"
   ✅ Expected: Stay on AuthScreen
   ✅ Expected: Original account unaffected
   ```

3. **Verify Original Account Still Works**
   - Switch to LoginTab
   - Log in with: `testuser1@example.com` / `TestPass123!`
   ```
   ✅ Expected: Original password still works
   ✅ Expected: User data unchanged
   ```

### Success Criteria
- [ ] Duplicate email detected and rejected
- [ ] Error message clearly indicates email exists
- [ ] Original account unaffected
- [ ] Original account can still log in

---

## 📝 Test Case 8: Multiple User Accounts

### Objective
Verify that app handles multiple accounts correctly and switches between them.

### Steps

1. **Create Account A**
   - Sign up: `accountA@example.com` / `PasswordA123!`
   - Name: `User A`
   - Verify you're on DashboardScreen

2. **Add a Student to Account A** (optional)
   - Click "Add Student" button
   - Name: `Student A1`
   - Class: `Class A`
   - Tap "Add"
   ```
   ✅ Expected: Student appears in list
   ```

3. **Logout**
   - Tap logout button
   ```
   ✅ Expected: Back on AuthScreen
   ```

4. **Create Account B**
   - Sign up: `accountB@example.com` / `PasswordB123!`
   - Name: `User B`
   - Verify DashboardScreen loads
   ```
   ✅ Expected: No students (fresh account)
   ✅ Expected: Different user info
   ```

5. **Add a Student to Account B**
   - Click "Add Student"
   - Name: `Student B1`
   - Class: `Class B`
   - Tap "Add"

6. **Switch Back to Account A**
   - Logout
   - Log in with: `accountA@example.com` / `PasswordA123!`
   ```
   ✅ Expected: Student A1 still there
   ✅ Expected: Student B1 not visible
   ✅ Expected: User info shows "User A"
   ✅ Expected: Correct account data restored
   ```

7. **Switch to Account B Again**
   - Logout
   - Log in with: `accountB@example.com` / `PasswordB123!`
   ```
   ✅ Expected: Student B1 visible
   ✅ Expected: Student A1 not visible
   ✅ Expected: Account B data restored
   ```

### Success Criteria
- [ ] Can create multiple accounts
- [ ] Each account has separate data
- [ ] Students associate with correct account
- [ ] Switching accounts shows correct data
- [ ] No data mixing between accounts

---

## 📝 Test Case 9: Firebase Console Verification

### Objective
Verify that data in Firebase Console matches app behavior.

### Steps

1. **Open Firebase Console**
   - Go to: https://console.firebase.google.com
   - Select project: `edutrack-49094`

2. **Check Authentication Users**
   - Navigate to: **Authentication** > **Users**
   ```
   ✅ Expected: See all test accounts created
      - testuser1@example.com
      - newuser@example.com
      - accountA@example.com
      - accountB@example.com
   ✅ Expected: Each shows "Email & Password" provider
   ✅ Expected: "Created" date matches when accounts were created
   ```

3. **Check Firestore User Data**
   - Navigate to: **Firestore Database** > **Collections** > **users**
   ```
   ✅ Expected: Document for each user
   ✅ Expected: Document ID = User UID (matches Firebase Auth)
   ✅ Expected: Fields: email, name, school, createdAt
   ✅ Expected: Values match what was entered in app
   ```

4. **Check Firestore Student Data** (if you added students)
   - Navigate to: **Firestore Database** > **Collections** > **students**
   ```
   ✅ Expected: Documents for students added
   ✅ Expected: Fields: name, class, teacherId, timestamp
   ✅ Expected: teacherId matches account's UID
   ✅ Expected: Only students from that account visible
   ```

5. **Verify Last Sign In Times**
   - In Authentication > Users > Click user
   - Check "Last Signed In"
   ```
   ✅ Expected: Updated to recent login time
   ✅ Expected: Matches when you logged in
   ```

### Success Criteria
- [ ] All test accounts appear in Firebase Auth
- [ ] User data in Firestore matches app
- [ ] Student data correctly associated with teachers
- [ ] Last Sign In times are accurate
- [ ] No orphaned or extra data

### Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| User in Auth but not in Firestore | addUserData() failed | Check Firestore write permissions |
| Student data missing teacherId | Code didn't save teacherId | Check addStudent() implementation |
| Data looks incorrect | Timestamp formatting | Check how dates are displayed |

---

## 🔍 Regression Testing Checklist

After making any code changes to authentication, run these quick tests:

- [ ] **T1:** Fresh sign up → account created and auto-navigate
- [ ] **T2:** Login with correct credentials → auto-navigate
- [ ] **T3:** Login with wrong password → error shown, stay on auth screen
- [ ] **T4:** Logout → auto-navigate to auth screen
- [ ] **T5:** Close and reopen while logged in → still logged in

If any of these fail, you likely broke the authentication flow.

---

## 📊 Test Results Template

Use this template to document your testing:

```
Test Suite: Firebase Authentication Flows
Date: _______________
Tester: _______________
Environment: [ ] Emulator  [ ] Physical Device  [ ] iOS  [ ] Android

Test Case 1: Fresh Install Sign Up
Result: [ ] PASS  [ ] FAIL
Notes: _______________________________________________

Test Case 2: Login After Sign Up
Result: [ ] PASS  [ ] FAIL
Notes: _______________________________________________

Test Case 3: Wrong Credentials
Result: [ ] PASS  [ ] FAIL
Notes: _______________________________________________

Test Case 4: Logout Flow
Result: [ ] PASS  [ ] FAIL
Notes: _______________________________________________

Test Case 5: Persistent Login
Result: [ ] PASS  [ ] FAIL
Notes: _______________________________________________

Test Case 6: Weak Password Validation
Result: [ ] PASS  [ ] FAIL
Notes: _______________________________________________

Test Case 7: Duplicate Email Prevention
Result: [ ] PASS  [ ] FAIL
Notes: _______________________________________________

Test Case 8: Multiple User Accounts
Result: [ ] PASS  [ ] FAIL
Notes: _______________________________________________

Test Case 9: Firebase Console Verification
Result: [ ] PASS  [ ] FAIL
Notes: _______________________________________________

Overall Result: [ ] ALL PASS  [ ] SOME FAILURES

Critical Issues: _________________________________________
```

---

## 🎯 Performance Expectations

| Operation | Expected Time | Max Acceptable |
|-----------|---|---|
| Sign Up | 2-3 seconds | 5 seconds |
| Login | 2-3 seconds | 5 seconds |
| Logout | 1-2 seconds | 3 seconds |
| Load User Data | < 1 second | 2 seconds |
| Load Students List | < 1 second | 2 seconds |
| App Startup (logged in) | 2-3 seconds | 5 seconds |
| App Startup (logged out) | 1-2 seconds | 3 seconds |

If any operation takes longer, check:
- Network connection
- Firebase emulator response times
- Device performance (especially emulator)
- Firestore indexes

---

## 🔐 Security Testing

### Test: Password Not Visible
- [ ] Password field shows dots/asterisks (never plain text)
- [ ] Password not logged in console

### Test: Session Not Exposed
- [ ] User token not visible in app UI
- [ ] Session cleared on logout (verified by failed access)

### Test: HTTPS Only
- [ ] Firebase calls use HTTPS (check network monitor)
- [ ] No plaintext credentials transmitted

### Test: Input Validation
- [ ] SQL injection not possible (not relevant for Firebase)
- [ ] Script injection prevented (Flutter/Dart handles this)
- [ ] Email format validated

---

## 📞 Common Testing Issues

### "Firebase not initialized"
```
Cause: Firebase.initializeApp() not called
Solution: Verify main.dart calls Firebase.initializeApp()
```

### "Permissions denied" in Firestore
```
Cause: Firestore security rules don't allow write
Solution: Update rules to allow authenticated users
```

### Emulator Very Slow
```
Cause: Emulator resource constraints
Solution: Use physical device or increase emulator RAM
```

### Tests Pass on Emulator but Fail on Device
```
Cause: Network connectivity differences
Solution: Test both emulator and device
```

---

## ✅ Test Completion Checklist

- [ ] All 9 test cases passed
- [ ] Performance within acceptable limits
- [ ] Firebase Console data verified
- [ ] No errors in app logs
- [ ] No errors in Firebase console logs
- [ ] Tested on both emulator and device
- [ ] Results documented

**Congratulations!** Your authentication system is production-ready. 🎉

