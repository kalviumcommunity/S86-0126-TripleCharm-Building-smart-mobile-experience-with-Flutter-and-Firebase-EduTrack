# Handling Push Notifications Using Firebase Cloud Messaging (FCM)

## Overview

Push notifications are a core feature of modern mobile applications, enabling real-time communication with users. Firebase Cloud Messaging (FCM) provides a reliable, scalable solution for sending notifications to Android, iOS, and web applications.

In this lesson, you will learn how to integrate FCM into your Flutter app so that it can receive notifications when the app is in the foreground, background, or terminated state.

### How FCM Works

FCM works by assigning each device a unique **registration token**. When you send a notification, FCM delivers it to the device using this token. Flutter, combined with Firebase, makes it straightforward to:

- Register permissions
- Listen to incoming messages
- Handle user interactions when a notification is tapped
- Process messages in different app states

## Why Push Notifications Are Important

1. **Real-time Communication**: Enables alerts, updates, and reminders
2. **Improved User Engagement**: Keeps users informed and engaged with your app
3. **Critical Functionality**: Supports chat messages, order tracking, and workflow updates
4. **Works Offline**: Functions even when the app is not actively running
5. **Scalability**: Firebase handles distribution at scale

## Implementation Steps

### Step 1: Add Dependencies

First, add Firebase Cloud Messaging to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_storage: ^12.0.0
  firebase_messaging: ^15.1.0  # Add this line
```

Then run:

```bash
flutter pub get
```

### Step 2: Initialize Firebase

Update your `main.dart` to initialize Firebase and the notification service:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "YOUR_API_KEY",
      authDomain: "YOUR_AUTH_DOMAIN",
      projectId: "YOUR_PROJECT_ID",
      storageBucket: "YOUR_STORAGE_BUCKET",
      messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
      appId: "YOUR_APP_ID",
      measurementId: "YOUR_MEASUREMENT_ID",
    ),
  );

  // Initialize Firebase Cloud Messaging
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.checkInitialMessage();

  runApp(const MyApp());
}
```

### Step 3: Create NotificationService

Create a dedicated service to manage all notification-related functionality:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Callback for handling notification taps
  Function(RemoteMessage)? onNotificationTap;

  // Callback for receiving messages in foreground
  Function(RemoteMessage)? onMessageReceived;

  /// Initialize FCM and set up message handlers
  Future<void> initialize() async {
    try {
      // Request notification permissions
      await _requestNotificationPermissions();

      // Handle foreground messages
      _setupForegroundMessageHandler();

      // Handle messages when app is opened from notification
      _setupMessageOpenedAppHandler();

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

      print('✅ Notification Service initialized');
    } catch (e) {
      print('❌ Error initializing Notification Service: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
    );

    print('📱 Permission Status: ${settings.authorizationStatus}');
  }

  /// Handle messages received in foreground
  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message received:');
      print('   Title: ${message.notification?.title}');
      print('   Body: ${message.notification?.body}');

      if (onMessageReceived != null) {
        onMessageReceived!(message);
      }
    });
  }

  /// Handle app being opened from a notification
  void _setupMessageOpenedAppHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('👆 App opened from notification');
      
      if (onNotificationTap != null) {
        onNotificationTap!(message);
      }

      _handleNotificationNavigation(message);
    });
  }

  /// Handle messages when app is terminated
  Future<void> checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print('🔄 App launched from terminated state');
      _handleNotificationNavigation(initialMessage);
    }
  }

  /// Background message handler (static function)
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print('🔔 Background message received');
  }

  /// Get the device FCM token
  Future<String?> getDeviceToken() async {
    String? token = await _messaging.getToken();
    print('🔑 Device FCM Token: $token');
    return token;
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    print('✅ Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    print('✅ Unsubscribed from topic: $topic');
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    // Implement your navigation logic here based on notification data
    final String? screen = message.data['screen'];
    print('📍 Navigate to: $screen');
  }
}
```

## Message States and Handlers

### 1. Foreground Notifications

When your app is actively running (in foreground), you can handle notifications:

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print("Foreground message: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  
  // Update UI, show dialog, or trigger action
});
```

### 2. Background Notifications

When your app is running in background but not actively used:

```dart
// This is automatically handled by the FirebaseMessaging.onBackgroundMessage
// You can safely ignore or process the message here
```

### 3. App-Opened from Notification

When user taps on a notification:

```dart
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  print("Opened app from notification");
  // Navigate to relevant screen
});
```

### 4. Terminated State Notifications

When app is completely closed and launched by tapping notification:

```dart
RemoteMessage? initialMsg =
    await FirebaseMessaging.instance.getInitialMessage();

if (initialMsg != null) {
  print("Opened from terminated state");
  // Handle initial navigation
}
```

## Getting the Device Token

Every device gets a unique FCM token:

```dart
final notificationService = NotificationService();
String? token = await notificationService.getDeviceToken();
print("FCM Token: $token");

// Listen for token refresh (tokens can expire)
notificationService.listenToTokenRefresh((newToken) {
  print("Token refreshed: $newToken");
  // Save new token to your backend
});
```

## Topic-Based Messaging

Topic-based messaging allows you to send notifications to devices based on subscriptions:

```dart
// Subscribe user to a topic
await notificationService.subscribeToTopic('weather_alerts');

// Unsubscribe from a topic
await notificationService.unsubscribeFromTopic('weather_alerts');
```

## Platform-Specific Setup

### Android Configuration

1. **Permissions** (in `android/app/src/main/AndroidManifest.xml`):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Required permissions for FCM -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <!-- Required for Android 13+ -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <application>
        <!-- Your app configuration -->
    </application>
</manifest>
```

2. **Minimum SDK**: Ensure your Android project targets at least API 21

### iOS Configuration

1. **APNs Certificate Setup**:
   - Go to Firebase Console > Project Settings > Cloud Messaging
   - Upload your APNs certificate and key
   - This enables Firebase to send notifications to iOS devices

2. **Minimum iOS Version**: iOS 11.0 or higher

3. **Pod Dependencies** (handled automatically by Flutter):
   - Firebase/Messaging
   - FirebaseCore
   - FirebaseMessaging

## Testing Notifications

### Using Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to Cloud Messaging tab
4. Click "Send your first message"
5. Create a test notification:
   - **Title**: "Test Notification"
   - **Body**: "This is a test message"
6. Select your app and choose target devices
7. Click "Send"

### Expected Behavior

- **Foreground**: Message appears in console logs (no notification banner on Android)
- **Background**: Notification appears in system notification center
- **Terminated**: Notification appears, tapping opens the app
- **App Opened**: Original message handler is triggered

## Common Issues and Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| Notifications not received | FCM not enabled | Enable FCM in Firebase Console |
| Android notifications not showing | Missing POST_NOTIFICATIONS permission | Add permission to AndroidManifest.xml and request at runtime |
| iOS notifications not working | APNs certificate not uploaded | Go to Firebase Console > Project Settings > Cloud Messaging and upload APNs certificate |
| Token not obtained | Permissions denied | Request notification permissions explicitly |
| Background handler not called | Handler not top-level function | Keep background handler as static top-level function |

## Best Practices

1. **Request Permissions Early**: Request notification permissions when app starts
2. **Handle Token Refresh**: Listen to token refresh and update backend
3. **Validate Data**: Always validate data in notification payload
4. **Secure Communication**: Use HTTPS for all notification-related endpoints
5. **Test Thoroughly**: Test notifications in all app states
6. **User Control**: Allow users to enable/disable notifications
7. **Rate Limiting**: Don't send too many notifications (avoid user fatigue)
8. **Meaningful Data**: Include relevant data in notification payload for navigation

## Code Examples

### Example 1: Basic Notification Setup

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(const MyApp());
}
```

### Example 2: Handle Notification Tap Navigation

```dart
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupNotificationHandlers();
  }

  void _setupNotificationHandlers() {
    final notificationService = NotificationService();
    
    // Handle notification tap
    notificationService.onNotificationTap = (RemoteMessage message) {
      final screen = message.data['screen'];
      if (screen == 'orders') {
        // Navigate to orders screen
      }
    };
    
    // Handle foreground message
    notificationService.onMessageReceived = (RemoteMessage message) {
      // Show dialog or snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.notification?.body ?? '')),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduTrack',
      home: const HomeScreen(),
    );
  }
}
```

### Example 3: Topic-Based Messaging

```dart
// Subscribe to notifications for a specific course
await notificationService.subscribeToTopic('course_updates_101');

// Unsubscribe when course access ends
await notificationService.unsubscribeFromTopic('course_updates_101');
```

## Summary

Firebase Cloud Messaging provides a robust solution for sending notifications to Flutter applications. By following this implementation:

1. ✅ Users receive real-time notifications
2. ✅ You can communicate in all app states
3. ✅ Device tokens enable targeted messaging
4. ✅ Topic subscriptions enable broad campaigns
5. ✅ Analytics track notification engagement

## Next Steps

1. Implement FCM in your app following this guide
2. Test notifications in all app states
3. Set up backend to send notifications programmatically
4. Monitor notification delivery and user engagement
5. Optimize notification content based on user feedback

## References

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging Package](https://pub.dev/packages/firebase_messaging)
- [Firebase Console](https://console.firebase.google.com)
- [Android Notification Permissions](https://developer.android.com/training/notify-user/build-notification)
- [iOS Push Notifications](https://developer.apple.com/notification/)
