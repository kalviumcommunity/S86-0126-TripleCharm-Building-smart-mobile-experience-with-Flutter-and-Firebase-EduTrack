# Firebase Cloud Messaging (FCM) - Quick Start Guide

A step-by-step checklist to get push notifications working in your EduTrack Flutter app.

## ✅ Pre-Implementation Checklist

- [ ] Firebase project created in Firebase Console
- [ ] Firebase Core initialized in your Flutter app
- [ ] Android and iOS projects properly set up
- [ ] Google Services JSON file added to Android project
- [ ] GoogleService-Info.plist added to iOS project

## ✅ Implementation Steps

### Phase 1: Dependencies & Configuration (5 minutes)

- [ ] Run `flutter pub get` to fetch dependencies
- [ ] Verify `firebase_messaging: ^15.1.0` in `pubspec.yaml`
- [ ] Confirm `NotificationService` exists at `lib/services/notification_service.dart`
- [ ] Check `main.dart` imports `NotificationService`

### Phase 2: Android Setup (10 minutes)

- [ ] Add POST_NOTIFICATIONS permission to `android/app/src/main/AndroidManifest.xml`
- [ ] Verify minimum SDK is at least API 31 in `android/app/build.gradle.kts`
- [ ] Ensure `firebase-messaging` plugin is registered (auto-handled by Flutter)
- [ ] Test on Android 13+ (API 33+) to verify notification permission request

### Phase 3: iOS Setup (15 minutes)

- [ ] Open Firebase Console > Project Settings > Cloud Messaging
- [ ] Download APNs certificate from Apple Developer Account
- [ ] Upload APNs certificate to Firebase Console
- [ ] Verify iOS deployment target is 11.0 or higher
- [ ] Build and run on iOS device or simulator

### Phase 4: Test Notifications (10 minutes)

1. **Start your app**
   ```bash
   flutter run
   ```

2. **Get your device FCM token**
   - The token is logged in console output
   - You'll see: `🔑 Device FCM Token: <your_token_here>`
   - Keep this token handy for testing

3. **Send test notification from Firebase Console**
   ```
   1. Go to Firebase Console (https://console.firebase.google.com)
   2. Select your project
   3. Go to Cloud Messaging section
   4. Click "Send your first message"
   5. Enter notification title and body
   6. Click "Send test message"
   7. Paste your device token
   8. Click "Test"
   ```

4. **Expected behaviors**
   - **App in foreground**: Message appears in console logs
   - **App in background**: Notification appears in system tray
   - **App terminated**: Notification appears, tap to launch app
   - **While running**: Check console for: `✅ Notification Service initialized`

## 📱 Testing Scenarios

| Scenario | Expected Result | How to Test |
|----------|----------------|------------|
| Foreground notification | Logged to console | App running, send message |
| Background notification | System notification | Minimize app, send message |
| Terminated notification | System notification | Close app, send message |
| Tap notification | onNotificationTap callback fires | Tap notification in system tray |
| Token refresh | New token logged | Let app run for extended period |

## 🐛 Troubleshooting

### "Notification Service not initialized"
- ✅ Check `main.dart` calls `NotificationService().initialize()`
- ✅ Ensure `await` is used for initialization
- ✅ Check console for error messages

### "No notifications received on Android"
- ✅ Verify POST_NOTIFICATIONS permission in AndroidManifest.xml
- ✅ Grant notification permission when app requests it
- ✅ Ensure FCM is enabled in Firebase Console
- ✅ Check device token is correct

### "No notifications received on iOS"
- ✅ Upload APNs certificate to Firebase Console
- ✅ Certificate must be valid and not expired
- ✅ Ensure bundle identifier matches Firebase app
- ✅ Use physical iOS device (simulator has limitations)

### "Token keeps changing"
- ✅ Normal behavior - tokens refresh periodically
- ✅ Always store latest token in backend
- ✅ Listen to `onTokenRefresh` events

### "Background handler not called"
- ✅ Ensure handler is top-level function (not inside class)
- ✅ Don't expect UI updates in background handler
- ✅ Use local database to store background messages

## 🔗 Integration with Your App

### In Dashboard Screen
```dart
@override
void initState() {
  super.initState();
  _setupNotifications();
}

void _setupNotifications() {
  final notificationService = NotificationService();
  
  notificationService.onNotificationTap = (message) {
    // Navigate based on message data
    if (message.data['type'] == 'assignment') {
      Navigator.pushNamed(context, '/assignments');
    }
  };
}
```

### Store Device Token in Firestore
```dart
final notificationService = NotificationService();
String? token = await notificationService.getDeviceToken();

if (token != null) {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'fcmToken': token});
}
```

### Subscribe to User-Specific Topics
```dart
// When user logs in
await notificationService.subscribeToTopic('user_${userId}');

// Send notifications to user_12345:
// Topic: user_12345
```

## 📊 Monitoring

### View Messages in Firebase Console
1. Go to Cloud Messaging
2. Click "Reporting" tab
3. See message delivery stats
4. Monitor errors and reasons

### Check Device Token Validity
```bash
# Token format should be:
# Long alphanumeric string (150+ characters)
# Example: eNzAUe...aBq (truncated)
```

## 🔐 Security Best Practices

1. **Never commit tokens**: Don't hardcode tokens in code
2. **Rotate tokens**: Update backend when token refreshes
3. **Validate data**: Check notification payload before processing
4. **Rate limit**: Don't send more than 1 notification per minute
5. **User choice**: Let users enable/disable notifications
6. **Test thoroughly**: Test on multiple devices and OS versions

## 📚 Next Steps

1. ✅ Implement backend to send notifications programmatically
2. ✅ Create notification categories for different message types
3. ✅ Add sound and vibration customization
4. ✅ Implement notification history in app
5. ✅ Track notification engagement analytics

## 🔗 Useful Links

- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging Package](https://pub.dev/packages/firebase_messaging)
- [FCM Console](https://console.firebase.google.com)
- [Android Notification Guide](https://developer.android.com/guide/topics/ui/notifiers/notifications)
- [iOS Push Notifications](https://developer.apple.com/notification/)

## 📝 Checkbox: Setup Complete!

- [ ] Dependencies added
- [ ] NotificationService created
- [ ] Main.dart updated
- [ ] Android permissions configured
- [ ] iOS APNs certificate uploaded
- [ ] Test notification sent successfully
- [ ] Foreground notification received ✅
- [ ] Background notification received ✅
- [ ] Terminated state notification received ✅
- [ ] Device token obtained ✅
- [ ] Ready for production! 🎉

---

**Note**: For each notification, save the device FCM token to your Firestore database along with the user profile. This allows your backend to send targeted notifications to specific users.
