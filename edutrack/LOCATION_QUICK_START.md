# 🚀 QUICK START GUIDE - Location & Map Markers

## ⚡ Get Started in 5 Steps

### Step 1: Install Dependencies
```bash
cd edutrack
flutter pub get
```
✅ This installs `google_maps_flutter` and `geolocator`

---

### Step 2: Add Google Maps API Key

#### For Android:
Edit `android/app/build.gradle` OR `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Add inside <application> tag -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

**Get API Key**: https://console.cloud.google.com/
- Create new project
- Enable Maps SDK for Android
- Create API key
- Restrict to Android apps

#### For iOS:
Edit `ios/Runner/Info.plist`:

```xml
<key>GOOGLE_MAPS_API_KEY</key>
<string>YOUR_GOOGLE_MAPS_API_KEY_HERE</string>
```

---

### Step 3: Build & Run
```bash
flutter run
```

---

### Step 4: Grant Location Permission
When app starts, **tap "Allow"** on location permission dialog

---

### Step 5: Navigate to Features

**From Demo Launcher Screen**:
1. Tap "Firebase & Location Demos"
2. Choose one:
   - **Map & Location** → Full interactive map
   - **Location Demo** → Feature demonstrations

---

## 📍 What You Can Do Now

### In Map Screen:
- ✅ See your current location marked on map
- ✅ See sample destinations (School, Library, Sports Ground)
- ✅ Enable "Real-time Tracking" to follow movement
- ✅ Tap destinations to see distance
- ✅ Watch route polyline draw as you move
- ✅ Use "Recenter" button to jump to your location
- ✅ Tap "Clear" to erase route

### In Location Demo:
- ✅ Fetch current GPS coordinates
- ✅ Create and visualize markers
- ✅ Calculate distance between points
- ✅ Calculate bearing/direction
- ✅ View location history
- ✅ Open device location settings

---

## 🔍 File Locations

| Feature | File | Lines |
|---------|------|-------|
| Location Service | `lib/services/location_service.dart` | 125 |
| Map Screen | `lib/screens/map_screen.dart` | 450+ |
| Demo Screen | `lib/screens/location_demo_screen.dart` | 310+ |
| Marker Models | `lib/models/location_marker.dart` | 91 |
| Full Docs | `LOCATION_INDEX.md` | 500+ |
| Implementation | `LOCATION_ASSIGNMENT_COMPLETE.md` | 350+ |

---

## 💡 Code Snippets for Your App

### Use Location Service Anywhere:
```dart
import 'package:edutrack/services/location_service.dart';

final locationService = LocationService();

// Get current position
final position = await locationService.getCurrentPosition();
if (position != null) {
  print('You are at: ${position.latitude}, ${position.longitude}');
}
```

### Stream Real-time Location:
```dart
locationService.getPositionStream().listen((position) {
  print('New location: ${position.latitude}, ${position.longitude}');
  // Update your app UI here
});
```

### Calculate Distance:
```dart
final distance = LocationService.calculateDistance(
  startLatitude: 0.0,
  startLongitude: 0.0,
  endLatitude: 0.001,
  endLongitude: 0.001,
);
print('Distance: ${distance / 1000} km');
```

---

## 🐛 Troubleshooting

**Problem: "GoogleMap' is not defined**  
→ Check `google_maps_flutter` in pubspec + `flutter pub get`

**Problem: Location not updating  
→ Check if GPS is enabled on device  
→ Check if you granted location permission  
→ May need to disable WiFi location services

**Problem: Map appears blank  
→ Google Maps API key not set correctly  
→ Check API key in AndroidManifest.xml or Info.plist

**Problem: Permission dialog won't show  
→ Delete and reinstall app  
→ Make sure AndroidManifest.xml has location permissions

**Problem: Marker doesn't appear  
→ Enable "Real-time Tracking" first  
→ Walk around to trigger marker updates  
→ Check logcat/console for errors

---

## 📊 Feature Testing

Test each feature:

```
Map Screen Features:
□ Map loads and shows your current location
□ Destination markers visible (green, blue, yellow)
□ Tap destination → shows distance dialog
□ Toggle tracking ON → marker follows you
□ Polyline route appears as you move
□ Recenter button works
□ Clear button removes route
□ Status shows current latitude/longitude

Location Demo Features:
□ Get Position → shows your coordinates
□ Show Markers → displays marker list
□ Calculate Distance → shows distance in km
□ Calculate Bearing → shows direction in degrees
□ History updates with each action
```

---

## ✅ Verification Checklist

- [ ] `flutter pub get` completes
- [ ] No compile errors
- [ ] App starts without crashing
- [ ] GPS permission request appears
- [ ] Map displays (should show your area)
- [ ] Your location marker visible
- [ ] Can enable tracking toggle
- [ ] Location updates work
- [ ] Distance calculation accurate
- [ ] Demo screen loads
- [ ] All buttons functional

---

## 📱 Testing on Different Platforms

### Android Emulator:
- Open Emulator Extended Controls (⋯)
- Navigate to "Location"
- Set coordinates and send
- Verify marker moves on map

### iOS Simulator:
- Features > Location > Custom Location
- Enter lat/lng coordinates
- Verify map updates

### Physical Device:
- Enable GPS
- Toggle "Real-time Tracking"
- Walk around
- Watch marker and polyline update in real-time

---

## 🎯 Next Steps After Quick Start

1. **Integrate into Your App Menu**
   ```dart
   // In your main navigation
   ElevatedButton(
     onPressed: () => Navigator.push(
       context,
       MaterialPageRoute(builder: (_) => const MapScreen()),
     ),
     child: const Text('View Map'),
   )
   ```

2. **Add Location History to Firestore**
   - Create `locations` collection
   - Store user location snapshots
   - Query movement history

3. **Create Geofence Alerts**
   - Define checkpoint boundaries
   - Alert when user enters/exits
   - Useful for delivery apps

4. **Share Live Location**
   - Store location in Firestore
   - Share with other users
   - Real-time team tracking

---

## 📚 Learn More

- Details: Read `LOCATION_INDEX.md`
- Implementation: Read `LOCATION_ASSIGNMENT_COMPLETE.md`
- Full Summary: Read `LOCATION_ASSIGNMENT_SUMMARY.md`

---

## 🎉 You're All Set!

Your EduTrack app now has **professional-grade location features**:
- ✅ Real GPS tracking
- ✅ Interactive maps
- ✅ Live location updates
- ✅ Distance calculations
- ✅ Full error handling

**Ready to test? Run `flutter run` now!**

---

**Questions?** Check the documentation files or review the source code!
