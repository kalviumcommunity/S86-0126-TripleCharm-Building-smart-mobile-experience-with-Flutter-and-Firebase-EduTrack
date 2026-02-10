import 'package:firebase_messaging/firebase_messaging.dart';

/// Firebase Cloud Messaging (FCM) Service
/// Handles push notifications in foreground, background, and terminated states
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Callback function for handling notification taps
  Function(RemoteMessage)? onNotificationTap;

  /// Callback function for receiving messages in foreground
  Function(RemoteMessage)? onMessageReceived;

  /// Initialize FCM and set up message handlers
  Future<void> initialize() async {
    try {
      // Request notification permissions (especially important for iOS and newer Android versions)
      await _requestNotificationPermissions();

      // Handle messages received while the app is in foreground
      _setupForegroundMessageHandler();

      // Handle messages when the app is opened from a notification (from background/terminated state)
      _setupMessageOpenedAppHandler();

      // Handle messages received while the app is in background
      FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

      print('✅ Notification Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Notification Service: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      print('📱 Permission Status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('⚠️  Notifications disabled by user');
      } else if (settings.authorizationStatus == AuthorizationStatus.granted) {
        print('✅ Notifications enabled');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('⚠️  Provisional notifications enabled (iOS 12+)');
      }
    } catch (e) {
      print('❌ Error requesting notification permissions: $e');
    }
  }

  /// Handle messages received in foreground
  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message received:');
      print('   Title: ${message.notification?.title}');
      print('   Body: ${message.notification?.body}');
      print('   Data: ${message.data}');

      // Call the custom callback if provided
      if (onMessageReceived != null) {
        onMessageReceived!(message);
      }

      // Optional: Show a custom notification/dialog when app is in foreground
      _showForegroundNotification(message);
    });
  }

  /// Handle app being opened from a notification
  void _setupMessageOpenedAppHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('👆 App opened from notification:');
      print('   Title: ${message.notification?.title}');
      print('   Body: ${message.notification?.body}');
      print('   Data: ${message.data}');

      // Call the custom callback if provided
      if (onNotificationTap != null) {
        onNotificationTap!(message);
      }

      // Handle navigation or other actions based on notification data
      _handleNotificationNavigation(message);
    });
  }

  /// Handle messages received when app is terminated
  Future<void> checkInitialMessage() async {
    try {
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        print('🔄 App launched from terminated state by notification:');
        print('   Title: ${initialMessage.notification?.title}');
        print('   Body: ${initialMessage.notification?.body}');
        print('   Data: ${initialMessage.data}');

        // Call the custom callback if provided
        if (onNotificationTap != null) {
          onNotificationTap!(initialMessage);
        }

        _handleNotificationNavigation(initialMessage);
      }
    } catch (e) {
      print('❌ Error checking initial message: $e');
    }
  }

  /// Background message handler (static function required by FCM)
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print('🔔 Background message received:');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');

    // You can process the message here (e.g., save to database)
    // Note: You cannot show UI elements in background handler
  }

  /// Get the device FCM token
  Future<String?> getDeviceToken() async {
    try {
      String? token = await _messaging.getToken();
      print('🔑 Device FCM Token: $token');
      return token;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Listen to token refresh events
  void listenToTokenRefresh(Function(String) onTokenRefresh) {
    _messaging.onTokenRefresh.listen((newToken) {
      print('🔄 FCM Token refreshed: $newToken');
      onTokenRefresh(newToken);
    });
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Show a notification dialog when app is in foreground
  void _showForegroundNotification(RemoteMessage message) {
    // This can be customized with a custom dialog or snackbar
    // For now, we just log it. You can integrate with local notifications here
    print('📢 Foreground notification should be displayed to user');
  }

  /// Handle navigation based on notification data
  void _handleNotificationNavigation(RemoteMessage message) {
    final String? screen = message.data['screen'];
    final String? action = message.data['action'];

    print('📍 Navigating based on notification:');
    print('   Screen: $screen');
    print('   Action: $action');

    // Implement your navigation logic here
    // Example:
    // if (screen == 'chat') {
    //   navigatorKey.currentState?.pushNamed('/chat');
    // }
  }

  /// Enable or disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      if (enabled) {
        await _messaging.setAutoInitEnabled(true);
        print('✅ Notifications enabled');
      } else {
        await _messaging.setAutoInitEnabled(false);
        print('✅ Notifications disabled');
      }
    } catch (e) {
      print('❌ Error changing notification state: $e');
    }
  }

  /// Delete the device token (sign out)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      print('✅ Device token deleted');
    } catch (e) {
      print('❌ Error deleting token: $e');
    }
  }
}
