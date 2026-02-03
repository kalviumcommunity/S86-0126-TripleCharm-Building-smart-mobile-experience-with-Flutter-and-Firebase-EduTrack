# Firebase Authentication Architecture

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter App (UI Layer)                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │ AuthScreen   │  │ LoginScreen  │  │ SignupScreen │       │
│  │ (Demo)       │  │ (Prod)       │  │ (Prod)       │       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘       │
│         │                 │                 │                │
│         └─────────────────┼─────────────────┘                │
│                           │                                   │
│              ┌────────────▼─────────────┐                    │
│              │   Authentication Layer   │                    │
│              └────────────┬─────────────┘                    │
│                           │                                   │
│         ┌─────────────────┼─────────────────┐                │
│         │                 │                 │                │
│    ┌────▼────┐   ┌────────▼──────┐   ┌──────▼─────┐        │
│    │AuthService   │AuthStateManager   │ErrorHandler         │
│    │─signup()     │─isLoggedIn()      │─getMsg()   │        │
│    │─login()      │─getCurrentUser()  │─isNetwork()│        │
│    │─logout()     │─stream...         │─isWeak...()│        │
│    │─resetPass()  │                   │            │        │
│    └────┬────┘    └────────┬──────┘   └──────┬─────┘        │
│         │                  │                 │               │
│         └──────────────────┼─────────────────┘               │
│                            │                                 │
└────────────────────────────┼─────────────────────────────────┘
                             │
              ┌──────────────▼──────────────┐
              │   Firebase Authentication   │
              │        (Backend)            │
              ├──────────────────────────────┤
              │                              │
              │  • User Database             │
              │  • Password Hashing          │
              │  • Token Management          │
              │  • Session Management        │
              │  • Error Handling            │
              │                              │
              └──────────────────────────────┘
```

## Authentication Flow Diagrams

### Signup Flow
```
User Opens App
       │
       ▼
┌─────────────────┐
│ AuthScreen      │  ◄─── User enters email & password
│ (or SignupUI)   │
└────────┬────────┘
         │
         ▼
    Validate Input
    ├─ Check email format
    ├─ Check password length
    └─ Check passwords match
         │
         ▼ (Valid)
    Firebase Auth
    .createUserWithEmailAndPassword()
         │
         ├─── Email already in use ──────┐
         │                               │
         ├─── Weak password ─────────────┼──► Show Error
         │                               │
         ├─── Invalid email ─────────────┤
         │                               │
         └─── Success ──────┐            │
                           │            │
                           ▼            ▼
                    ┌──────────────┐  Error Dialog
                    │ User Created │  Show Message
                    │ in Firebase  │  (User sees error)
                    └────────┬─────┘
                             │
                             ▼
                    Success Dialog
                    Shows user email
                             │
                             ▼
                    User navigates to
                    Dashboard/Home
```

### Login Flow
```
User Clicks Login
       │
       ▼
┌─────────────────┐
│ AuthScreen      │  ◄─── User enters email & password
│ (or LoginUI)    │
└────────┬────────┘
         │
         ▼
    Validate Input
    ├─ Check email format
    └─ Check password not empty
         │
         ▼ (Valid)
    Firebase Auth
    .signInWithEmailAndPassword()
         │
         ├─── User not found ────────────┐
         │                               │
         ├─── Wrong password ────────────┼──► Show Error
         │                               │
         ├─── User disabled ─────────────┤
         │                               │
         ├─── Network error ────────────┤
         │                               │
         └─── Success ──────┐            │
                           │            │
                           ▼            ▼
                    ┌──────────────┐  Error Dialog
                    │ User Logged  │  Show Message
                    │ In           │  (User sees error)
                    └────────┬─────┘
                             │
                             ▼
                    Auth Stream emits
                    User object
                             │
                             ▼
                    StreamBuilder rebuilds
                    (if at app root)
                             │
                             ▼
                    Navigate to Home
                    Screen automatically
```

### Session Persistence Flow
```
App Start
  │
  ▼
Firebase.initializeApp()
  │
  ▼
authStateChanges().listen()
  │
  ├─ No previous login
  │  └─ Emit: null
  │     └─ Show: LoginScreen
  │
  └─ Previous login exists
     └─ Emit: User object
        └─ Check: Firebase token valid?
           ├─ Yes
           │  └─ Show: HomeScreen
           └─ No (expired)
              └─ Refresh token
                 └─ If valid: Show HomeScreen
                    else: Show LoginScreen
```

## Data Flow

### Sign Up Data Flow
```
User Input:
  Email: test@example.com
  Password: password123

       │
       ▼

AuthService.signUp()
       │
       ├─ Validate inputs
       ├─ Trim email
       └─ Call Firebase API

       │
       ▼

Firebase Server
       │
       ├─ Hash password with bcrypt
       ├─ Check email uniqueness
       ├─ Create user document
       ├─ Generate auth token
       └─ Return User object

       │
       ▼

App receives:
  - User UID
  - Email
  - Auth token (stored locally)
  - Creation timestamp
       │
       ▼

App State:
  FirebaseAuth.instance.currentUser → User object
  authStateChanges() → emits User
       │
       ▼

UI Updates:
  StreamBuilder rebuilds
  Shows HomeScreen or navigates
```

### Login Data Flow
```
User Input:
  Email: test@example.com
  Password: password123

       │
       ▼

AuthService.login()
       │
       ├─ Validate inputs
       ├─ Trim email
       └─ Call Firebase API

       │
       ▼

Firebase Server
       │
       ├─ Find user by email
       ├─ Verify password hash
       ├─ Generate new auth token
       ├─ Update last sign-in time
       └─ Return User object

       │
       ▼

App receives:
  - User UID
  - Email
  - Auth token (stored securely)
  - Last sign-in time
       │
       ▼

Local Storage (Secure):
  Auth token stored by native platform
  iOS: Keychain
  Android: Keystore
       │
       ▼

App State Updates:
  FirebaseAuth.instance.currentUser → User object
  authStateChanges() → emits User
       │
       ▼

UI Updates:
  StreamBuilder rebuilds
  Shows HomeScreen
```

## Error Handling Flow

```
Auth Operation
       │
       ▼
Try-Catch Block
       │
       ├─ No exception
       │  └─ Success
       │
       └─ FirebaseAuthException
          │
          ▼
       Get Error Code
          │
          ├─ invalid-email
          │  └─ Show: "Invalid email format"
          │
          ├─ weak-password
          │  └─ Show: "Password too weak"
          │
          ├─ email-already-in-use
          │  └─ Show: "Email already registered"
          │
          ├─ user-not-found
          │  └─ Show: "No account found"
          │
          ├─ wrong-password
          │  └─ Show: "Wrong password"
          │
          ├─ network-request-failed
          │  └─ Show: "Check internet connection"
          │
          ├─ too-many-requests
          │  └─ Show: "Try again later"
          │
          └─ other
             └─ Show: "Authentication error"
                  │
                  ▼
             Log error code
             Show user-friendly message
```

## Component Interaction Diagram

```
┌──────────────────────────────────────────────────────────┐
│                    UI Components                          │
│                                                           │
│  AuthScreen ◄─────► Login/SignupUI                       │
│      │                   │                                │
│      └─────────┬─────────┘                               │
│               │                                           │
│               ▼ (User interactions)                       │
└──────────────────────────────────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────────────────┐
│              Business Logic Layer                        │
│                                                           │
│  ┌──────────────┬──────────────┬──────────────┐         │
│  │ AuthService  │ AuthState    │ ErrorHandler │         │
│  │              │ Manager      │              │         │
│  └──────┬───────┴──────┬───────┴──────┬───────┘         │
│         │              │              │                  │
│         └──────────────┼──────────────┘                  │
│                        │                                  │
│  ┌──────────────────────▼──────────────────────┐        │
│  │      FirebaseAuth Instance                  │        │
│  │  - currentUser                              │        │
│  │  - authStateChanges()                       │        │
│  │  - signInWithEmailAndPassword()             │        │
│  │  - createUserWithEmailAndPassword()         │        │
│  │  - signOut()                                │        │
│  └──────────────┬───────────────────────────────┘       │
│                 │                                        │
└─────────────────┼────────────────────────────────────────┘
                  │
                  ▼
         Firebase Backend
         (Cloud Services)
```

## State Management Flow

```
Application State
       │
       ├─ Logged Out
       │  ├─ currentUser = null
       │  ├─ authStateChanges() emits null
       │  └─ UI shows LoginScreen
       │
       ├─ Logging In/Out (Loading)
       │  ├─ currentUser = null or User
       │  ├─ isLoading = true
       │  └─ UI shows loading indicator
       │
       └─ Logged In
          ├─ currentUser = User object
          ├─ authStateChanges() emits User
          ├─ token stored securely
          └─ UI shows HomeScreen
```

## Message Flow - Signup Success

```
User Interface              AuthService              FirebaseAuth              Firebase Backend
       │                         │                        │                           │
       │ submitForm()            │                        │                           │
       ├────────────────────────►│                        │                           │
       │                         │                        │                           │
       │                         │ signUp(email, pass)    │                           │
       │                         ├───────────────────────►│                           │
       │                         │                        │ createUserWithEmail()     │
       │                         │                        ├──────────────────────────►│
       │                         │                        │                           │
       │                         │                        │ Hash password             │
       │                         │                        │ Validate email            │
       │                         │                        │ Create user doc           │
       │                         │                        │ Generate token            │
       │                         │                        │◄──────────────────────────┤
       │                         │                        │ Return User object        │
       │                         │◄───────────────────────┤                           │
       │◄────────────────────────┤                        │                           │
       │ User object              │                        │                           │
       │                          │                        │                           │
       │ (local listener)         │                        │                           │
       │ Show success dialog      │                        │                           │
       │ Navigate to home         │                        │                           │
       │                          │                        │                           │
```

## Message Flow - Login Failure

```
User Interface              AuthService              FirebaseAuth              Firebase Backend
       │                         │                        │                           │
       │ submitForm()            │                        │                           │
       ├────────────────────────►│                        │                           │
       │                         │                        │                           │
       │                         │ login(email, pass)     │                           │
       │                         ├───────────────────────►│                           │
       │                         │                        │ signInWithEmailPassword() │
       │                         │                        ├──────────────────────────►│
       │                         │                        │                           │
       │                         │                        │ Find user by email        │
       │                         │                        │ Compare password hash     │
       │                         │                        │ (FAILS)                   │
       │                         │                        │◄──────────────────────────┤
       │                         │                        │ FirebaseAuthException     │
       │                         │                        │ code: wrong-password      │
       │                         │◄───────────────────────┤                           │
       │                         │ throw Exception         │                           │
       │◄────────────────────────┤                        │                           │
       │ catch FirebaseException │                        │                           │
       │ getErrorMessage()       │                        │                           │
       │ Show error: "Wrong..."  │                        │                           │
       │                         │                        │                           │
```

## Security Architecture

```
┌──────────────────────────────────────────────────┐
│            Frontend (Flutter App)                │
├──────────────────────────────────────────────────┤
│                                                  │
│  Input Validation                               │
│  ├─ Email format check                         │
│  ├─ Password length check                      │
│  └─ Sanitization                               │
│                                                  │
│  ◆ Password NOT stored                         │
│  ◆ Token stored securely by native code        │
│                                                  │
└────────────────┬─────────────────────────────────┘
                 │ HTTPS Only
                 │ (Encrypted)
                 ▼
┌──────────────────────────────────────────────────┐
│        Firebase Authentication (Backend)         │
├──────────────────────────────────────────────────┤
│                                                  │
│  Password Processing                            │
│  ├─ Hash with bcrypt/scrypt                    │
│  ├─ Salt generation                            │
│  └─ Never store plaintext                      │
│                                                  │
│  Token Management                               │
│  ├─ JWT tokens with 1-hour expiry             │
│  ├─ Refresh tokens stored securely            │
│  └─ Token rotation                             │
│                                                  │
│  Security Features                              │
│  ├─ Rate limiting                              │
│  ├─ IP validation                              │
│  ├─ Device fingerprinting                      │
│  └─ Suspicious activity detection              │
│                                                  │
└──────────────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────┐
│          Google Cloud Platform (GCP)             │
├──────────────────────────────────────────────────┤
│                                                  │
│  User Database (Encrypted at rest)              │
│  ├─ Email                                       │
│  ├─ Password hash                               │
│  ├─ User metadata                               │
│  └─ Audit logs                                  │
│                                                  │
└──────────────────────────────────────────────────┘
```

## Complete Authentication Lifecycle

```
App Launch
    │
    ▼
Firebase.initializeApp()
    │
    ├─ Load cached credentials
    │  from secure storage
    │
    ▼
Listen to authStateChanges()
    │
    ├─ Stream emits current User
    │  (or null if not logged in)
    │
    ▼
StreamBuilder rebuilds UI
    │
    ├─ User != null
    │  └─ Show: HomeScreen
    │     (User logged in)
    │
    └─ User == null
       └─ Show: LoginScreen
          (User not logged in)
                │
                ▼
         User clicks Login
                │
                ▼
         Enter credentials
                │
                ▼
         Firebase validates
                │
                ├─ Valid ──┐
                │          │
                └─ Invalid─┼─► Show error
                           │
                           ▼
                    Success:
                    - Generate token
                    - Update user session
                    - Store token locally
                           │
                           ▼
                    Emit User object
                           │
                           ▼
                    StreamBuilder catches
                    and rebuilds
                           │
                           ▼
                    Show HomeScreen
                           │
                           ▼
                    User navigates app
                           │
                           ├─ Token expires
                           │  └─ Auto refresh
                           │
                           └─ User clicks Logout
                              └─ Clear token
                              └─ signOut()
                              └─ Emit null
                              └─ Show LoginScreen
                                 (Cycle repeats)
```

---

This architecture diagram illustrates:
- **Layered design** - Separation of concerns
- **One-way data flow** - Clear direction of data movement
- **Error handling** - Multiple fallback paths
- **Security** - Secure token storage and transmission
- **State management** - Reactive updates with Streams

All components work together to provide a secure, reliable authentication system.
