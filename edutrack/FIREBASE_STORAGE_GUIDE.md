# Firebase Storage: Upload & Manage Media Files

## Overview

Firebase Storage provides secure, scalable cloud storage for your app's files. Whether you're uploading profile pictures, chat images, or documents, Firebase Storage handles the complexity of uploads, downloads, and file management.

---

## 📦 Dependencies

Your `pubspec.yaml` includes:

```yaml
firebase_storage: ^12.0.0
image_picker: ^1.0.0
```

Install:
```bash
flutter pub get
```

---

## 🎯 What You'll Learn

By completing this lesson, you can:

✅ Pick images from camera or gallery
✅ Upload files to Firebase Storage
✅ Retrieve download URLs
✅ Display images in your UI
✅ Manage stored files
✅ Delete files when needed
✅ Track upload progress
✅ Handle permissions and errors

---

## 📚 Lesson Outline

### 1. Pick Images from Device

#### Gallery Picker
```dart
final StorageService storageService = StorageService();
final XFile? image = await storageService.pickImageFromGallery();
```

#### Camera Capture
```dart
final XFile? image = await storageService.pickImageFromCamera();
```

#### Multiple Images
```dart
final List<XFile> images = await storageService.pickMultipleImages();
```

#### Video Selection
```dart
final XFile? video = await storageService.pickVideo();
```

---

### 2. Upload Files to Storage

#### Simple Image Upload
```dart
final downloadURL = await storageService.uploadImage(
  imageFile,
  folder: 'uploads',
);
```

#### Upload with Progress Tracking
```dart
final downloadURL = await storageService.uploadImage(
  imageFile,
  folder: 'uploads',
  onProgress: (progress) {
    print('Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
  },
);
```

#### Upload Multiple Images
```dart
final downloadURLs = await storageService.uploadMultipleImages(
  imageFiles,
  folder: 'gallery',
  onProgress: (index, progress) {
    print('Image $index: ${(progress * 100).toStringAsFixed(0)}%');
  },
);
```

#### Upload Any File Type
```dart
final downloadURL = await storageService.uploadFile(
  File('/path/to/document.pdf'),
  folder: 'documents',
  fileName: 'my_document.pdf',
);
```

---

### 3. Get Download URLs

#### Get URL After Upload
```dart
final url = await storageService.uploadImage(imageFile, folder: 'uploads');
// url is ready to use
```

#### Get URL for Existing File
```dart
final url = await storageService.getDownloadURL('uploads/image123.jpg');
```

#### Get File Metadata
```dart
final metadata = await storageService.getFileMetadata('uploads/image123.jpg');
print('Size: ${metadata?.size} bytes');
print('Created: ${metadata?.timeCreated}');
```

---

### 4. Display Images in UI

#### Network Image
```dart
Image.network(
  downloadURL,
  width: 200,
  height: 200,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return CircularProgressIndicator(
      value: loadingProgress.expectedTotalBytes != null
          ? loadingProgress.cumulativeBytesLoaded /
              loadingProgress.expectedTotalBytes!
          : null,
    );
  },
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.broken_image);
  },
)
```

#### In CircleAvatar
```dart
CircleAvatar(
  radius: 50,
  backgroundImage: NetworkImage(downloadURL),
)
```

#### In ListView
```dart
ListView.builder(
  itemCount: imageUrls.length,
  itemBuilder: (context, index) {
    return Image.network(imageUrls[index]);
  },
)
```

---

### 5. Manage Files

#### Delete File
```dart
await storageService.deleteFile('uploads/image123.jpg');
```

#### Delete Multiple Files
```dart
await storageService.deleteFiles([
  'uploads/image1.jpg',
  'uploads/image2.jpg',
]);
```

#### Delete Entire Folder
```dart
await storageService.deleteFolder('uploads');
```

#### List Files in Folder
```dart
final files = await storageService.listFilesInFolder('uploads');
```

#### Get File Info
```dart
final fileInfo = await storageService.getFileInfoInFolder('uploads');

for (var file in fileInfo) {
  print('Name: ${file['name']}');
  print('Size: ${file['size']} bytes');
  print('URL: ${file['downloadURL']}');
}
```

---

### 6. File Operations

#### Check If File Exists
```dart
final exists = await storageService.fileExists('uploads/image.jpg');
```

#### Get File Size
```dart
final sizeKB = await storageService.getFileSizeInKB('uploads/image.jpg');
```

#### Calculate Storage Usage
```dart
final usageMB = await storageService.getTotalStorageUsageInMB('uploads');
print('Total storage: ${usageMB.toStringAsFixed(2)} MB');
```

#### Update Metadata
```dart
await storageService.updateFileMetadata(
  'uploads/image.jpg',
  {
    'description': 'Profile picture',
    'user_id': '12345',
  },
);
```

#### Download File to Device
```dart
await storageService.downloadFile(
  'uploads/image.jpg',
  '/local/path/image.jpg',
  onProgress: (progress) {
    print('Download: ${(progress * 100).toStringAsFixed(0)}%');
  },
);
```

---

## 🔐 Security Rules

### Basic Authentication Required
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

### Restrict by User
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile pictures - users can only upload their own
    match /profile_pictures/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                      request.auth.uid == userId;
    }
    
    // Chat images - authenticated users only
    match /chat_images/{fileName} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### File Size & Type Restrictions
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Images only, max 10MB
    match /uploads/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                      request.resource.size < 10 * 1024 * 1024 &&
                      request.resource.contentType.matches('image/.*');
    }
  }
}
```

### Allow Public Read, Authenticated Write
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /public/{fileName} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 🛠️ Common Patterns

### Pattern 1: Profile Picture Upload
```dart
final image = await storageService.pickImageFromGallery();
if (image != null) {
  final url = await storageService.uploadImage(
    image,
    folder: 'profile_pictures/$userId',
  );
  // Save url to Firestore user document
}
```

### Pattern 2: Chat Image Sharing
```dart
final image = await storageService.pickImageFromCamera();
if (image != null) {
  final url = await storageService.uploadImage(
    image,
    folder: 'chat_images/$conversationId',
  );
  // Create message with image URL
}
```

### Pattern 3: Document Management
```dart
final file = File('/path/to/document.pdf');
final url = await storageService.uploadFile(
  file,
  folder: 'documents/$userId',
  fileName: file.path.split('/').last,
);
// Store url in database
```

### Pattern 4: Image Gallery
```dart
final urls = await storageService.getFileInfoInFolder('gallery/$userId');
for (var file in urls) {
  // Display file['downloadURL'] in gallery
}
```

### Pattern 5: Upload with Progress UI
```dart
double _uploadProgress = 0.0;

final url = await storageService.uploadImage(
  imageFile,
  folder: 'uploads',
  onProgress: (progress) {
    setState(() => _uploadProgress = progress);
  },
);

// Show progress bar in UI
LinearProgressIndicator(value: _uploadProgress)
```

---

## ⚠️ Common Mistakes to Avoid

### 1. Not Handling Permissions
**Problem:** App crashes on Android/iOS
**Solution:** Add permissions in `AndroidManifest.xml` and `Info.plist`:

**Android (AndroidManifest.xml):**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

**iOS (Info.plist):**
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photos</string>
```

### 2. Not Catching Exceptions
**Problem:** App crashes on upload failure
**Solution:**
```dart
try {
  final url = await storageService.uploadImage(image, folder: 'uploads');
} catch (e) {
  print('Upload failed: $e');
  // Show error to user
}
```

### 3. Large Files Without Progress
**Problem:** UI appears frozen during upload
**Solution:**
```dart
// Track progress
final url = await storageService.uploadImage(
  image,
  folder: 'uploads',
  onProgress: (progress) {
    setState(() => _uploadProgress = progress);
  },
);
```

### 4. Insecure Storage Rules
**Problem:** Anyone can upload/delete files
**Solution:** Set proper security rules:
```
allow write: if request.auth != null;  // Require authentication
```

### 5. Not Deleting Old Files
**Problem:** Storage costs increase unnecessarily
**Solution:**
```dart
// Delete old profile picture before uploading new one
if (oldProfilePictureURL != null) {
  await storageService.deleteFile(oldProfilePictureURL);
}
const newURL = await storageService.uploadImage(image, folder: '...');
```

### 6. Displaying Images Without Error Handling
**Problem:** Broken images crash layout
**Solution:**
```dart
Image.network(
  url,
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.broken_image);
  },
)
```

---

## 🧪 Testing Your Implementation

### Test 1: Image Upload
1. Tap "Gallery" button
2. Select an image
3. Tap "Upload"
4. Verify download URL appears
5. Check Firebase Console → Storage

### Test 2: Progress Tracking
1. Upload a large image
2. Verify progress bar updates
3. Wait for completion

### Test 3: Image Display
1. Upload image
2. Verify it displays in UI
3. Test with different image sizes

### Test 4: File Management
1. Upload multiple images
2. View list in "Uploaded Files"
3. Delete a file
4. Verify deletion in Firebase Console

### Test 5: Error Handling
1. Upload without selecting image
2. Cancel upload
3. Disconnect internet and try upload
4. Verify error messages display

---

## 📊 Best Practices

### ✅ DO

1. **Always add permissions**
   ```xml
   <!-- AndroidManifest.xml -->
   <uses-permission android:name="android.permission.CAMERA" />
   ```

2. **Set proper security rules**
   ```
   allow write: if request.auth != null;
   ```

3. **Limit file sizes**
   ```
   request.resource.size < 10 * 1024 * 1024  // 10MB max
   ```

4. **Handle progress tracking**
   ```dart
   onProgress: (progress) => setState(() => _progress = progress)
   ```

5. **Use unique filenames**
   ```dart
   final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
   ```

6. **Organize files in folders**
   ```
   uploads/
   ├── profile_pictures/
   ├── chat_images/
   └── documents/
   ```

7. **Delete old files when replacing**
   ```dart
   await storageService.deleteFile(oldPath);
   ```

8. **Handle network errors**
   ```dart
   try { ... } catch (e) { showErrorDialog(); }
   ```

### ❌ DON'T

1. **Don't upload without checking authentication**
   - Always require `request.auth != null`

2. **Don't allow unlimited file sizes**
   - Set `request.resource.size < limit`

3. **Don't allow public writes**
   - Restrict to authenticated users

4. **Don't ignore upload errors**
   - Always wrap in try-catch

5. **Don't display images without error handling**
   - Use `errorBuilder` in Image.network

6. **Don't leave old files in storage**
   - Clean up when updating files

7. **Don't show raw URLs in UI**
   - Use `SelectableText` if displaying URL

8. **Don't assume upload succeeded**
   - Check for exceptions

---

## 🚀 Real-World Example

### Complete Profile Picture Upload Flow

```dart
class ProfilePictureUpdate {
  final StorageService _storageService = StorageService();
  
  Future<void> updateProfilePicture(
    String userId,
    String? oldPictureURL,
  ) async {
    try {
      // 1. Pick image
      final image = await _storageService.pickImageFromGallery();
      if (image == null) return;
      
      // 2. Delete old picture
      if (oldPictureURL != null) {
        try {
          await _storageService.deleteFile(oldPictureURL);
        } catch (e) {
          print('Failed to delete old picture: $e');
        }
      }
      
      // 3. Upload new picture
      final newURL = await _storageService.uploadImage(
        image,
        folder: 'profile_pictures/$userId',
        onProgress: (progress) {
          // Update UI progress
        },
      );
      
      // 4. Save URL to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'profilePictureURL': newURL});
      
      print('Profile picture updated successfully');
    } catch (e) {
      print('Error updating profile picture: $e');
      rethrow;
    }
  }
}
```

---

## 📱 Integration Steps

### Step 1: Add Permissions
Add to `AndroidManifest.xml` and `Info.plist`

### Step 2: Create StorageService
Use the provided `StorageService` class

### Step 3: Create UI Screen
Use the provided `FirebaseStorageUploadDemo` screen

### Step 4: Configure Security Rules
Set up Firebase Storage Rules in console

### Step 5: Test Upload Flow
Follow the testing guide above

### Step 6: Integrate into Your App
Copy patterns to your screens

---

## 💡 Pro Tips

1. **Compress images before upload**
   - Use `imageQuality: 80` in picker

2. **Show progress during upload**
   - Use `LinearProgressIndicator` with progress value

3. **Organize files by user**
   - Use `folder: 'uploads/$userId'`

4. **Cache download URLs**
   - Store in Firestore or local cache

5. **Test with various image sizes**
   - Small, medium, and large images

6. **Monitor storage costs**
   - Check Firebase Console regularly

7. **Implement retry logic**
   - For failed uploads

8. **Clean up test files**
   - Delete unused uploads

---

## 📸 Screenshots to Take

For your documentation:
1. App with "Pick Image" button
2. Image picker dialog
3. Upload in progress (with progress bar)
4. Success message with download URL
5. Firebase Console → Storage → Files
6. Image displayed in UI
7. Files list view
8. Delete confirmation

---

## ✅ Completion Checklist

- [ ] Firebase Storage dependency added
- [ ] Image picker dependency added
- [ ] StorageService created and working
- [ ] Firebase Storage upload demo running
- [ ] Can pick image from gallery
- [ ] Can pick image from camera
- [ ] Image uploads successfully
- [ ] Download URL displays correctly
- [ ] Image displays in UI
- [ ] Can delete files
- [ ] Progress tracking works
- [ ] Error handling implemented
- [ ] Security rules configured
- [ ] Tested on Android device
- [ ] Tested on iOS device
- [ ] Documentation complete
- [ ] Screenshots taken

---

## 🎓 Summary

You've learned how to:
- ✅ Pick images from device
- ✅ Upload to Firebase Storage
- ✅ Get download URLs
- ✅ Display images in UI
- ✅ Manage files
- ✅ Handle errors
- ✅ Configure security
- ✅ Track progress

**Next Step:** Check QUICK_START_STORAGE.md for interactive demo walkthrough!

---

*Last Updated: February 5, 2026*
