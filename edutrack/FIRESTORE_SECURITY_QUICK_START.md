# Firestore Security - Quick Start Implementation Checklist

## 5-Minute Setup

### Phase 1: Enable Authentication (2 minutes)

- [ ] Go to Firebase Console > Authentication
- [ ] Click "Get Started"
- [ ] Enable "Email/Password" provider
- [ ] Set up secondary providers (Google is optional)

### Phase 2: Deploy Security Rules (2 minutes)

**Option A: Firebase Console**

1. Go to Firebase Console > Firestore Database > Rules
2. Copy entire content of `firestore.rules` file in your project
3. Paste into Rules editor
4. Click "Publish"

**Option B: Firebase CLI**

```bash
npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules
```

### Phase 3: Update Your App (1 minute)

Your app already has `SecurityService` at `lib/services/security_service.dart`. Use it in your code:

```dart
import 'services/security_service.dart';

final securityService = SecurityService();

// Check if user is authenticated
if (securityService.isLoggedIn) {
  // Allow access
}

// Check user role
UserRole? role = await securityService.getCurrentUserRole();
```

---

## Implementation Checklist

### ✅ Pre-Deployment

- [ ] All Firebase dependencies are added to `pubspec.yaml`
- [ ] Firebase is initialized in `main.dart`
- [ ] Firebase Authentication is enabled in console
- [ ] Test mode rules are NOT being used
- [ ] You have reviewed the `firestore.rules` file

### ✅ During Deployment

- [ ] Firestore rules are copied correctly from `firestore.rules`
- [ ] No syntax errors in rules (Firebase Console will show them)
- [ ] Rules are published/deployed
- [ ] Deployment shows "success" message
- [ ] No collections are left in test mode

### ✅ Post-Deployment Testing

- [ ] Unauthenticated users are blocked from reading documents
- [ ] Authenticated users can read their own documents
- [ ] Teachers can create assignments
- [ ] Admin users have full access
- [ ] Students cannot delete records
- [ ] Audit logs are being created

### ✅ Application Code

- [ ] AuthService is used for sign up/login
- [ ] SecurityService is used for permission checks
- [ ] User creation includes setting user role
- [ ] Data is validated before saving
- [ ] Error messages are user-friendly

---

## Key Security Service Methods

```dart
// Authentication
securityService.isLoggedIn          // bool
securityService.currentUserId       // String?
securityService.currentUser         // User?

// Roles
await securityService.getCurrentUserRole()     // UserRole?
await securityService.currentUserIsAdmin()     // bool
await securityService.currentUserIsTeacher()   // bool
await securityService.currentUserIsStudent()   // bool

// Validation
securityService.validateUserData(data)
securityService.validateStudentData(data)
securityService.validateAssignmentData(data)

// Operations
await securityService.setUserRole(uid, role)
await securityService.createUserDocument(...)
await securityService.updateOwnProfile(data)
await securityService.deactivateAccount(uid)
await securityService.logAction(...)
```

---

## Common Firestore Rules Scenarios

### Scenario 1: "User can only read their own data"

```firestore
match /users/{uid} {
  allow read, write: if request.auth.uid == uid;
}
```

### Scenario 2: "Teachers can create, but not delete"

```firestore
match /assignments/{assignmentId} {
  allow create, update: if hasRole('teacher');
  allow delete: if hasRole('admin');
}
```

### Scenario 3: "Admin has full access everywhere"

```firestore
match /{document=**} {
  allow read, write, delete: if isAdmin();
}
```

### Scenario 4: "Anyone can read, only author can write"

```firestore
match /posts/{postId} {
  allow read: if true;
  allow write: if request.auth.uid == resource.data.authorId;
}
```

---

## Testing Rules

### In Firebase Console

1. Go to Firestore Rules tab
2. Click "Rules Playground" (if available)
3. Select test type (Authenticated/Unauthenticated)
4. Enter UID and collection path
5. Try a read/write operation
6. Check result (Allow/Deny)

### In Your App

```dart
// Example: Test permissions
final securityService = SecurityService();

try {
  // Check if current user is teacher
  bool isTeacher = await securityService.currentUserIsTeacher();
  
  if (isTeacher) {
    // Allowed operation
    await firestoreService.createAssignment(data);
  } else {
    print('❌ Only teachers can create assignments');
  }
} catch (e) {
  print('❌ Error: $e');
}
```

---

## Troubleshooting

### "PERMISSION_DENIED" Error

**Cause:** Your rules deny the operation

**Fix:**
1. Check that user is authenticated: `if request.auth != null`
2. Verify user role is set: `getRole(request.auth.uid) == 'teacher'`
3. Check UID matches document ID for user data
4. Test rules in Firebase Console

### "Unauthorized: Missing or insufficient permissions"

**Cause:** Rules or auth issue

**Fix:**
1. Ensure user is signed in: `if (securityService.isLoggedIn)`
2. Verify role: `await securityService.getCurrentUserRole()`
3. Check Firestore rules are deployed (not in test mode)
4. Re-authenticate user

### Rules Syntax Error

**Cause:** Invalid Firestore rules syntax

**Fix:**
1. Check rules in Firebase Console for error messages
2. Copy rules directly from `firestore.rules` file
3. Standard syntax:
   ```firestore
   allow read: if condition;
   allow write: if condition;
   ```

---

## Production Deployment Checklist

Before launching to real users:

- [ ] All test mode rules have been replaced
- [ ] No hardcoded UIDs in rules
- [ ] Catch-all rule denies everything: `match /{document=**} { allow read, write: if false; }`
- [ ] Sensitive collections are restricted
- [ ] Role checks work correctly
- [ ] Admin functions are admin-only
- [ ] Student data is protected
- [ ] Audit logging is enabled
- [ ] Rate limiting is configured (optional but recommended)
- [ ] Backups are enabled

---

## Rules Update Checklist

When modifying rules:

1. **Test First**
   - Test in Firebase Console Rules Playground
   - Verify with different UIDs and roles

2. **Deploy to Staging**
   - Create a staging database if possible
   - Deploy rules to staging first

3. **Monitor**
   - Check Firebase Monitoring for errors
   - Watch for "Permission Denied" errors in logs

4. **Document Changes**
   - Note what rules changed and why
   - Update your team documentation

---

## File References

| File | Purpose |
|------|---------|
| `firestore.rules` | Firestore security rules (deploy to Firebase) |
| `lib/services/security_service.dart` | Dart security service for checks |
| `lib/services/auth_service.dart` | Authentication service |
| `lib/services/firestore_service.dart` | Database operations |
| `FIRESTORE_SECURITY_LESSON.md` | Full lesson documentation |

---

## Quick Command Reference

```bash
# Deploy rules via CLI
firebase deploy --only firestore:rules

# Deploy with specific project
firebase deploy --project YOUR_PROJECT_ID --only firestore:rules

# View current rules
firebase rules:list

# Test rules locally
npm install -m firebase-tools
firebase emulators:start
```

---

## Next Steps

1. ✅ Deploy `firestore.rules` to Firebase Console
2. ✅ Set up user signup with role assignment
3. ✅ Test rules with different user roles
4. ✅ Implement permission checks in UI
5. ✅ Monitor error logs in Firebase Console
6. ✅ Regular security audits (monthly)

---

## Emergency: Rollback to Open Rules

**Only if production is blocked** (should never do this):

```firestore
// TEMPORARY - Development only
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

Then immediately:
1. Identify and fix the issue
2. Re-deploy secure rules
3. Document what went wrong
4. Add tests to prevent repetition

---

**Remember:** Security is not optional. Always use the restrictive rules for production deployments.
