# Firebase Storage: Quick Start Guide

## 🚀 Get Started in 5 Steps

### Step 1: Run the App
```bash
flutter run -d chrome
```

### Step 2: Navigate to Demo
```dart
Navigator.pushNamed(context, '/firebase-storage-upload');
```

### Step 3: Pick an Image
Click **"Gallery"** or **"Camera"** button

### Step 4: Upload Image
Click **"Upload Image"** button
Watch the progress bar

### Step 5: See the Download URL
✅ Success! Copy the URL and test it in your browser

---

## 📂 File Organization

```
lib/
├── screens/
│   └── firebase_storage_upload_demo.dart    # Interactive demo
├── services/
│   └── storage_service.dart                 # Storage operations
└── examples/
    └── firebase_storage_examples.dart       # Code patterns
```

---

## 💻 Basic Code Patterns

### Pick Image & Upload
```dart
final image = await StorageService().pickImageFromGallery();
final url = await StorageService().uploadImage(image, folder: 'uploads');
```

### Display Image
```dart
Image.network(downloadURL)
```

### Delete File
```dart
await StorageService().deleteFile(filePath);
```

---

## 🧪 Interactive Demo Features

### UI Elements
- 📸 Image preview (gallery/camera)
- ⬆️ Upload button with progress
- 📊 Progress bar (0-100%)
- 🔗 Download URL display
- 📁 Folder selector dropdown
- 📋 Uploaded files list
- 🗑️ Delete buttons

### Folders Available
- uploads (default)
- profile_pictures
- chat_images
- documents

### What You Can Do
1. ✅ Pick and preview images
2. ✅ Upload with progress tracking
3. ✅ View download URLs
4. ✅ Switch folders
5. ✅ List all uploaded files
6. ✅ Delete files
7. ✅ Refresh file list

---

## 🎯 Testing Checklist

- [ ] Pick image from gallery
- [ ] Take photo with camera
- [ ] Upload image successfully
- [ ] See progress bar update
- [ ] View download URL
- [ ] Open URL in browser (image loads)
- [ ] Switch to different folder
- [ ] Upload to different folder
- [ ] See files in list
- [ ] Delete a file
- [ ] File removed from list
- [ ] Check Firebase Console

---

## 🔍 Firebase Console Check

After uploading:
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Storage → Browser
4. Look for `uploads/` folder
5. Should see your uploaded image file

---

## ⚠️ Troubleshooting

### Problem: "No permission to access"
**Solution:** Check Firestore Security Rules
```
allow read, write: if request.auth != null;
```

### Problem: Image won't display
**Solution:** Check download URL in browser
**OR** Use error handler:
```dart
Image.network(url, errorBuilder: (context, error, stack) => Icon(Icons.broken_image))
```

### Problem: Can't pick image
**Solution:** Grant permissions in settings
- Android: Settings → Apps → Permissions
- iOS: Settings → Privacy → Photos

### Problem: Upload doesn't start
**Solution:**
1. Check internet connection
2. Try smaller image
3. Check Firebase project is active

---

## 📱 Add to Your App

### Option 1: Add Button to Dashboard
```dart
ElevatedButton.icon(
  onPressed: () => Navigator.pushNamed(context, '/firebase-storage-upload'),
  icon: Icon(Icons.cloud_upload),
  label: Text('Storage Demo'),
)
```

### Option 2: Use StorageService in Any Screen
```dart
import 'services/storage_service.dart';

final service = StorageService();
final image = await service.pickImageFromGallery();
final url = await service.uploadImage(image, folder: 'my_folder');
```

### Option 3: Use Example Widgets
Copy widgets from `firebase_storage_examples.dart`:
- `ImagePickerButton`
- `UploadProgressWidget`
- `ProfilePictureUpload`
- `StorageFileListWidget`

---

## 🔐 Set Security Rules

Go to Firebase Console → Storage → Rules

### Public Reading, Auth Writing (Recommended)
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /uploads/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Auth Only
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 💾 Common Folders

```
uploads/                    # General uploads
├── user_123/              # User-specific
│   └── image1.jpg
├── profile_pictures/      # Profile photos
│   └── user_456.jpg
├── chat_images/           # Chat attachments
│   └── conversation_789/
└── documents/             # Files, PDFs
    └── user_001/
```

---

## 🎨 Full Upload Flow Example

```dart
Future<void> uploadProfilePhoto() async {
  try {
    // 1. Pick
    final image = await StorageService().pickImageFromGallery();
    if (image == null) return;
    
    // 2. Upload
    final url = await StorageService().uploadImage(
      image,
      folder: 'profile_pictures',
      onProgress: (progress) {
        setState(() => uploadProgress = progress);
      },
    );
    
    // 3. Display
    setState(() => profileImageURL = url);
    
    // 4. Save to database
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'photo': url});
    
    // 5. Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Photo updated!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
    );
  }
}
```

---

## 📚 Learn More

- [Firebase Storage Docs](https://firebase.google.com/docs/storage)
- [Flutter Image Picker](https://pub.dev/packages/image_picker)
- [Security Rules Guide](https://firebase.google.com/docs/storage/security)

---

## 🚀 Next Steps

1. ✅ Run the demo
2. ✅ Upload a test image
3. ✅ View in Firebase Console
4. ✅ Read `FIREBASE_STORAGE_GUIDE.md`
5. ✅ Study code examples
6. ✅ Integrate into your app
7. ✅ Set security rules
8. ✅ Test thoroughly

---

**Ready? Start with the demo!** 🎉
