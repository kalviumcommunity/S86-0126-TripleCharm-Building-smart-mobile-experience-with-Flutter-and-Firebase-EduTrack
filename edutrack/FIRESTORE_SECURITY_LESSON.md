# Securing Firebase with Authentication and Firestore Rules

## Overview

Modern mobile apps frequently store sensitive user data in the cloud. Firebase provides a powerful NoSQL database—Cloud Firestore—but it must be properly secured to prevent unauthorized access. This lesson teaches you how to secure Firestore using Authentication and custom security rules that determine who can read or write specific documents.

Every Firestore database starts in "test mode," which grants open read/write access to anyone. While convenient during initial development, **this is unsafe for production apps**. Using Firebase Authentication combined with Firestore Security Rules allows you to:

- Ensure only signed-in users can access data
- Apply fine-grained restrictions on specific collections
- Enforce role-based permissions (admin vs. teacher vs. student)
- Protect sensitive information
- Audit access and changes

## Why Securing Firestore Matters

1. **Protects User Data**: Prevents unauthorized access to student information, grades, and personal data
2. **Ensures Authentication**: Only authenticated users can read or write to the database
3. **Prevents Malicious Usage**: Blocks spam writes, data deletion, tampering, and unauthorized modifications
4. **Enforces Role-Based Permissions**: Different access levels for admins, teachers, and students
5. **Required for Production**: Essential before deploying apps to real users

## Firebase Authentication Setup

### Step 1: Verify Dependencies

Ensure your `pubspec.yaml` includes:

```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
```

### Step 2: Initialize Firebase

Your app already initializes Firebase in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

### Step 3: Enable Firebase Authentication

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (edutrack-49094)
3. Navigate to **Authentication** → **Sign-in method**
4. Enable:
   - ✅ **Email/Password** (for email-based signup/login)
   - ✅ **Google** (optional, for social login)

### Step 4: Sign Up / Sign In Users in Flutter

Use the existing `AuthService`:

```dart
final authService = AuthService();

// Sign up
User? user = await authService.signUp(email, password);

// Log in
User? user = await authService.login(email, password);

// Check current user
User? currentUser = authService.currentUser;
```

## Firestore Security Rules: Architecture

Firestore Security Rules are written in a custom language and control:

- **Who** can access documents
- **What** operations they can perform (read, write, delete)
- **Under what conditions** access is allowed

### Rule Structure

```firestore
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Collections and rules go here
    match /users/{uid} {
      allow read: if condition;
      allow write: if condition;
    }
  }
}
```

## Rule Writing Best Practices

### 1. Start with Deny-All (Most Secure)

```firestore
// Default: deny everything
match /{document=**} {
  allow read, write: if false;
}
```

Then explicitly allow access to specific collections.

### 2. Use Helper Functions

```firestore
// Check if user is authenticated
function isAuth() {
  return request.auth != null;
}

// Check if user owns the document
function isOwner(uid) {
  return isAuth() && request.auth.uid == uid;
}

// Check if user is admin
function isAdmin() {
  return isAuth() && 
         get(/databases/$(database)/documents/users/$(request.auth.uid))
         .data.role == 'admin';
}
```

### 3. Implement Role-Based Access Control

Your `SecurityService` provides role-based checks:

```dart
final securityService = SecurityService();

// Check user role
UserRole? role = await securityService.getCurrentUserRole();
bool isAdmin = await securityService.currentUserIsAdmin();
bool isTeacher = await securityService.currentUserIsTeacher();
```

## Firestore Rules: Collection-by-Collection

### Users Collection

```firestore
match /users/{uid} {
  // Users can only read/write their own profile
  allow read: if isOwner(uid);
  allow create: if isAuth() && isOwner(uid);
  allow update: if isOwner(uid);
  allow delete: if false; // Prevent deletion - use deactivation
  
  // Admins can read all user data
  allow read: if isAdmin();
}
```

**Key Points:**
- Users are identified by their UID
- Self-access only (read your own profile)
- Admins can access all user data
- No deletions (soft-delete via deactivation flag)

### Students Collection

```firestore
match /students/{studentId} {
  // Authenticated users can read (view directory)
  allow read: if isAuth();
  
  // Teachers and admins can create/update
  allow create: if (isAdmin() || hasRole('teacher'));
  
  // Only admins can delete
  allow delete: if isAdmin();
}
```

**Key Points:**
- All authenticated users can view student list
- Only teachers/admins can modify student records
- Prevents accidental deletion by restricting to admins

### Assignments Collection

```firestore
match /assignments/{assignmentId} {
  // Authenticated users can read
  allow read: if isAuth();
  
  // Only teachers/admins can create
  allow create: if (isAdmin() || hasRole('teacher'));
  
  // Teachers can update own assignments
  allow update: if isAdmin() || 
                    (hasRole('teacher') && resource.data.teacherId == request.auth.uid);
  
  // Only admins can delete
  allow delete: if isAdmin();
  
  // Submissions subcollection
  match /submissions/{submissionId} {
    allow read: if isAuth();
    allow create: if isAuth();
    allow update: if isAdmin() || hasRole('teacher');
    allow delete: if isAdmin();
  }
}
```

**Key Points:**
- Students can submit assignments
- Teachers can grade submissions
- Assignments cannot be deleted (preserved for records)

### Attendance Collection

```firestore
match /attendance/{attendanceId} {
  // Authenticated users can read
  allow read: if isAuth();
  
  // Teachers/admins can create/update
  allow create: if (isAdmin() || hasRole('teacher'));
  allow update: if (isAdmin() || hasRole('teacher'));
  
  // Only admins can delete
  allow delete: if isAdmin();
}
```

**Key Points:**
- Only teachers and admins can mark attendance
- Records are preserved (no deletion by teachers)

## Deploying Firestore Rules

### In Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Firestore Database** → **Rules** tab
4. Paste your rules from `firestore.rules`
5. Click **Publish** to deploy

### Using Firebase CLI

You can also deploy via command line:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Deploy rules
firebase deploy --only firestore:rules
```

## Testing Firestore Rules

### Using Firebase Console Rules Playground

1. Go to Firestore → Rules tab
2. Click "Rules Playground" (if available)
3. Simulate requests:
   - **Authenticated request**: Include a UID
   - **Unauthenticated request**: No UID
   - **Read/Write operation**: Test specific operations

### Testing in Flutter

Create test cases in your security service:

```dart
final securityService = SecurityService();

// Check if can read
bool canRead = await securityService.canReadDocument(
  uid: 'user123',
  collection: 'students',
  docId: 'student456',
);

// Check if can write
bool canWrite = await securityService.canWriteDocument(
  uid: 'user123',
  collection: 'students',
  docId: 'student456',
);
```

### Common Test Scenarios

| Scenario | Expected Result | How to Test |
|----------|----------------|------------|
| Unauthenticated user reads any document | ❌ DENIED | Make request without UID |
| User reads own profile | ✅ ALLOWED | Request with matching UID |
| User reads another user's profile | ❌ DENIED | Request with different UID |
| Teacher creates assignment | ✅ ALLOWED | hasRole('teacher') condition |
| Student deletes document | ❌ DENIED | Only admin deletion allowed |
| Admin writes to any collection | ✅ ALLOWED | isAdmin() condition |

## Firestore Rules: Development vs. Production

### Development Rules (Test Mode)

```firestore
// ❌ NEVER use this in production
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**Use only for:**
- Local development and testing
- Rapid prototyping
- Learning Firestore

### Production Rules (Secure)

```firestore
// ✅ Always use this in production
service cloud.firestore {
  match /databases/{database}/documents {
    // Deny everything by default
    match /{document=**} {
      allow read, write: if false;
    }
    
    // Explicitly allow specific access
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
  }
}
```

## Using SecurityService in Your App

### Initialize SecurityService

```dart
final securityService = SecurityService();

// Check current user
String? userId = securityService.currentUserId;
bool isLoggedIn = securityService.isLoggedIn;

// Get user role
UserRole? role = await securityService.getCurrentUserRole();
```

### Check Permissions Before Operations

```dart
// Before creating assignment
if (await securityService.currentUserIsTeacher()) {
  await firestoreService.createAssignment(data);
} else {
  showError('Only teachers can create assignments');
}

// Before deleting
if (await securityService.currentUserIsAdmin()) {
  await deleteDocument(collection, docId);
}
```

### Validate Data Before Saving

```dart
try {
  securityService.validateUserData(userData);
  securityService.validateStudentData(studentData);
  securityService.validateAssignmentData(assignmentData);
} catch (e) {
  showError(e.toString());
}
```

## Common Issues and Fixes

| Issue | Cause | Solution |
|-------|-------|----------|
| **PERMISSION_DENIED** error | Rules block access | Check rules + verify user is authenticated + verify role |
| Writes fail from unauthenticated users | Rules require authentication | Ensure user signs in before DB calls |
| Can read all documents | Rules too open | Replace test mode with production rules |
| Users can delete records | Delete rule too permissive | Change to `allow delete: if isAdmin()` only |
| Token expires silently | Session invalid | Call `securityService.isSessionValid()` periodically |
| Admin checks fail | Role not set in user document | Call `securityService.setUserRole()` after signup |
| Firebase exception on write | Invalid data | Use `validateUserData()` before saving |

## Security Checklist

Before deploying to production:

- [ ] Authentication is configured in Firebase Console
- [ ] Email/Password or other auth methods are enabled
- [ ] Firestore Rules are deployed and not in test mode
- [ ] All collections have explicit allow/deny rules
- [ ] Catch-all rule at the end denies all access
- [ ] Helper functions (isAuth, isAdmin, etc.) are defined
- [ ] Users can only access their own documents (unless admin)
- [ ] Delete operations are restricted to admins only
- [ ] Role-based access control is implemented
- [ ] Data validation happens before writes
- [ ] Audit logging is enabled for sensitive operations
- [ ] Tested rules with multiple user roles
- [ ] HTTPS is used for all API calls
- [ ] Sensitive data is not exposed in rules error messages

## Implementation Example: Complete User Signup Flow

```dart
class AuthViewModel {
  final authService = AuthService();
  final securityService = SecurityService();
  final firestoreService = FirestoreService();

  Future<void> signupNewUser(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      // Step 1: Create Firebase Auth account
      User? user = await authService.signUp(email, password);
      
      if (user != null) {
        // Step 2: Validate user data
        final userData = {
          'uid': user.uid,
          'email': email,
          'displayName': displayName,
          'role': 'student', // Default role
        };
        securityService.validateUserData(userData);
        
        // Step 3: Create Firestore user document
        await securityService.createUserDocument(
          uid: user.uid,
          email: email,
          displayName: displayName,
          role: UserRole.student,
        );
        
        // Step 4: Log the action
        await securityService.logAction(
          actionType: 'user_signup',
          description: 'New user account created',
        );
        
        print('✅ Signup successful');
      }
    } on FirebaseAuthException catch (e) {
      print('❌ Auth error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      rethrow;
    }
  }
}
```

## Next Steps

1. ✅ Deploy the provided `firestore.rules` to Firebase Console
2. ✅ Use `SecurityService` in your UI to check permissions before showing actions
3. ✅ Add role management to your admin dashboard
4. ✅ Implement audit logging for sensitive operations
5. ✅ Monitor access patterns in Firebase Analytics
6. ✅ Regularly review and update rules as your app evolves

## Additional Resources

- [Firebase Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Authentication Docs](https://firebase.google.com/docs/auth)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Security Rules Testing](https://firebase.google.com/docs/rules/unit-tests)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)

## Summary

Securing Firestore requires a multi-layered approach:

1. **Authentication**: Users must be signed in
2. **Authorization**: Rules determine what authenticated users can do
3. **Validation**: Data is validated before saving
4. **Role-Based Access**: Different users have different permissions
5. **Audit Logging**: All sensitive actions are logged

By implementing the rules and services provided in this lesson, you ensure that:

- ✅ Only authenticated users can access data
- ✅ Users cannot access data from other users
- ✅ Teachers can manage student data
- ✅ Admins have full control
- ✅ Sensitive operations are audited
- ✅ Your app is production-ready and secure
