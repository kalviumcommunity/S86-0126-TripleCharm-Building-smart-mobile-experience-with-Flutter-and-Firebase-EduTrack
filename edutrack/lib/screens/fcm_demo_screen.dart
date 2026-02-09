import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';

/// Demo screen showing how to use Firebase Cloud Messaging (FCM)
class FCMDemoScreen extends StatefulWidget {
  const FCMDemoScreen({Key? key}) : super(key: key);

  @override
  State<FCMDemoScreen> createState() => _FCMDemoScreenState();
}

class _FCMDemoScreenState extends State<FCMDemoScreen> {
  late NotificationService _notificationService;
  String? _deviceToken;
  String _status = 'Initializing...';
  String _lastMessage = 'No messages received yet';
  bool _isSubscribedToTopic = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    _notificationService = NotificationService();

    // Set up callbacks for notification events
    _notificationService.onMessageReceived = (RemoteMessage message) {
      setState(() {
        _lastMessage =
            '${message.notification?.title}\n${message.notification?.body}';
        _status = 'Message received in foreground';
      });

      // Show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message: ${message.notification?.body}'),
          duration: const Duration(seconds: 5),
        ),
      );
    };

    _notificationService.onNotificationTap = (RemoteMessage message) {
      setState(() {
        _lastMessage = 'App opened from notification:\n${message.data}';
        _status = 'Notification tapped';
      });
    };

    // Get device token
    String? token = await _notificationService.getDeviceToken();
    if (token != null) {
      setState(() {
        _deviceToken = token;
        _status = '✅ FCM Ready';
      });
    }

    // Listen to token refresh
    _notificationService.listenToTokenRefresh((newToken) {
      print('Token refreshed: $newToken');
      setState(() {
        _deviceToken = newToken;
      });
    });
  }

  void _subscribeToDemoTopic() async {
    await _notificationService.subscribeToTopic('edutrack_updates');
    setState(() {
      _isSubscribedToTopic = true;
      _status = '✅ Subscribed to "edutrack_updates" topic';
    });
  }

  void _unsubscribeFromDemoTopic() async {
    await _notificationService.unsubscribeFromTopic('edutrack_updates');
    setState(() {
      _isSubscribedToTopic = false;
      _status = '✅ Unsubscribed from "edutrack_updates" topic';
    });
  }

  void _copyTokenToClipboard() {
    if (_deviceToken != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token copied to clipboard (in real app)'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Cloud Messaging (FCM) Demo'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Section
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Device Token Section
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Device FCM Token',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_deviceToken != null)
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: _copyTokenToClipboard,
                            tooltip: 'Copy token',
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_deviceToken != null)
                      SelectableText(
                        _deviceToken!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      )
                    else
                      const Text(
                        'Loading token...',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Last Message Section
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last Message Received',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastMessage,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Topic Subscription Section
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Topic Subscription',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSubscribedToTopic
                          ? 'Subscribed to: edutrack_updates'
                          : 'Not subscribed to any topic',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isSubscribedToTopic ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: !_isSubscribedToTopic
                                ? _subscribeToDemoTopic
                                : null,
                            icon: const Icon(Icons.check),
                            label: const Text('Subscribe'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSubscribedToTopic
                                ? _unsubscribeFromDemoTopic
                                : null,
                            icon: const Icon(Icons.close),
                            label: const Text('Unsubscribe'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instructions Section
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to Test Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionItem(
                      '1',
                      'Copy your Device FCM Token',
                      'Use the copy button above to copy your unique device token',
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionItem(
                      '2',
                      'Send Test Notification',
                      'Go to Firebase Console > Cloud Messaging > Send your first message',
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionItem(
                      '3',
                      'Paste Token and Send',
                      'Paste your device token and send the test notification',
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionItem(
                      '4',
                      'Observe Behavior',
                      'Try in foreground, background, and after terminating the app',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Buttons
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'In a real app, this would trigger a local notification',
                    ),
                    action: SnackBarAction(
                      label: 'Got it',
                      onPressed: () {},
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.notifications),
              label: const Text('Test Foreground Notification'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
