# Firebase Storage: Quick Reference

## 📌 Import Statement
```dart
import 'services/storage_service.dart';
```

---

## 🎯 Quick Operations (Copy-Paste)

### Pick Image
```dart
final image = await StorageService().pickImageFromGallery();
final image = await StorageService().pickImageFromCamera();
final images = await StorageService().pickMultipleImages();
```

### Upload Image
```dart
final url = await StorageService().uploadImage(
  image,
  folder: 'uploads',
  onProgress: (progress) => print('${(progress * 100).toInt()}%'),
);
```

### Get Download URL
```dart
final url = await StorageService().getDownloadURL('uploads/image.jpg');
```

### Display Image
```dart
Image.network(url)
CachedNetworkImage(imageUrl: url) // Better with caching
CircleAvatar(backgroundImage: NetworkImage(url)) // Profile pic
```

### Delete File
```dart
await StorageService().deleteFile('uploads/image.jpg');
await StorageService().deleteFiles(['path1', 'path2']);
```

### List Files in Folder
```dart
final files = await StorageService().listFilesInFolder('uploads');
final info = await StorageService().getFileInfoInFolder('uploads');
```

### Check File Exists
```dart
final exists = await StorageService().fileExists('uploads/image.jpg');
```

### Get File Size
```dart
final sizeKB = await StorageService().getFileSizeInKB('uploads/image.jpg');
```

---

## 📂 StorageService Methods

| Method | Purpose | Returns |
|--------|---------|---------|
| `pickImageFromGallery()` | Select from device | `XFile?` |
| `pickImageFromCamera()` | Take photo | `XFile?` |
| `pickMultipleImages()` | Select many | `List<XFile>` |
| `pickVideo()` | Select video | `XFile?` |
| `uploadImage(XFile, folder)` | Upload image | `String` (URL) |
| `uploadFile(File, folder)` | Upload any file | `String` (URL) |
| `uploadMultipleImages(List, folder)` | Batch upload | `List<String>` |
| `getDownloadURL(path)` | Get public URL | `String` |
| `getFileMetadata(path)` | Get file info | `FullMetadata` |
| `downloadFile(remote, local)` | Download to device | `void` |
| `deleteFile(path)` | Delete single file | `void` |
| `deleteFiles(List)` | Delete multiple | `void` |
| `deleteFolder(path)` | Clear folder | `void` |
| `listFilesInFolder(path)` | List file paths | `List<String>` |
| `getFileInfoInFolder(path)` | List with URLs | `List<FileInfo>` |
| `fileExists(path)` | Check existence | `bool` |
| `getFileSizeInKB(path)` | File size | `double` |
| `getTotalStorageUsageInMB(path)` | Folder size | `double` |
| `updateFileMetadata(path, data)` | Modify metadata | `void` |

---

## 🔐 Security Rules (One-Liners)

### Auth Required
```
allow read, write: if request.auth != null;
```

### User-Specific
```
allow read, write: if request.auth.uid == resource.metadata['uid'];
```

### Authenticated Read, User Write
```
allow read: if request.auth != null;
allow write: if request.auth.uid == resource.metadata['uid'];
```

### Public Read, Auth Write
```
allow read: if true;
allow write: if request.auth != null;
```

---

## 🎨 Common Folder Paths

```
uploads/              # General uploads
profile_pictures/     # User photos
chat_images/          # Chat attachments
documents/            # PDFs, files
videos/               # Video files
thumbnails/           # Small previews
```

---

## ⚡ Example: Complete Profile Picture Flow

```dart
// 1. Pick
final image = await StorageService().pickImageFromGallery();

// 2. Upload
final url = await StorageService().uploadImage(
  image,
  folder: 'profile_pictures',
  onProgress: (p) => setState(() => progress = p),
);

// 3. Save to database
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .update({'photoURL': url});

// 4. Display
setState(() => photoURL = url);
```

---

## 🖼️ Display Methods

### Basic
```dart
Image.network(url)
```

### With Error Handling
```dart
Image.network(
  url,
  errorBuilder: (c, e, s) => Icon(Icons.broken_image),
)
```

### Circular Profile Picture
```dart
CircleAvatar(
  backgroundImage: NetworkImage(url),
  radius: 50,
)
```

### With Loading Indicator
```dart
Image.network(
  url,
  loadingBuilder: (c, w, p) => CircularProgressIndicator(),
)
```

### Cached (Better Performance)
```dart
CachedNetworkImage(
  imageUrl: url,
  placeholder: (c, url) => CircularProgressIndicator(),
)
```

---

## 💾 Storage Paths Reference

| Folder | Use Case | Access |
|--------|----------|--------|
| `uploads/` | General user uploads | Public |
| `profile_pictures/` | User avatars | Public read |
| `chat_images/` | Conversation attachments | Group access |
| `documents/` | PDFs, forms, files | Auth only |
| `videos/` | Media content | Public |
| `thumbnails/` | Small previews | Public |
| `temp/` | Temporary files | Anyone |
| `backups/` | User backups | Auth only |

---

## 🧩 Common Error Codes

| Error | Cause | Solution |
|-------|-------|----------|
| `Permission denied` | Security rules | Check Firebase rules |
| `Cannot access file` | File doesn't exist | Check path spelling |
| `Network timeout` | Connection issue | Check internet |
| `401 Unauthorized` | Not authenticated | Login first |
| `File too large` | Exceeds quota | Use smaller file |

---

## ⚙️ Configuration

### AndroidManifest.xml Permissions
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### Info.plist Permissions (iOS)
```xml
<key>NSCameraUsageDescription</key>
<string>Camera permission needed</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photos permission needed</string>
```

---

## 🧪 Test Cases

```dart
// Test 1: Pick and upload
final img = await storage.pickImageFromGallery();
final url = await storage.uploadImage(img);
expect(url.isNotEmpty, true);

// Test 2: File exists
final exists = await storage.fileExists(filePath);
expect(exists, true);

// Test 3: Get size
final size = await storage.getFileSizeInKB(filePath);
expect(size > 0, true);

// Test 4: List folder
final files = await storage.listFilesInFolder('uploads');
expect(files.isNotEmpty, true);

// Test 5: Delete
await storage.deleteFile(filePath);
final stillExists = await storage.fileExists(filePath);
expect(stillExists, false);
```

---

## 🎯 Progress Tracking Pattern

```dart
final url = await storageService.uploadImage(
  image,
  folder: 'uploads',
  onProgress: (progress) {
    setState(() {
      uploadProgress = progress;
      percentageText = '${(progress * 100).toInt()}%';
    });
  },
);
```

## 📊 UI Progress Widget

```dart
LinearProgressIndicator(value: uploadProgress)
// Shows 0.0 to 1.0

Text('${(uploadProgress * 100).toInt()}%')
// Shows percentage text

if (uploadProgress > 0 && uploadProgress < 1)
  CircularProgressIndicator(value: uploadProgress)
// Shows circular progress during upload
```

---

## 🚀 Firebase Console URLs

- [Firebase Console](https://console.firebase.google.com)
- Select Project → Storage
- Browse uploaded files
- Check security rules
- Monitor usage

---

## 📱 Widget Examples

### Image Picker Button
```dart
FloatingActionButton(
  onPressed: () async {
    final img = await StorageService().pickImageFromGallery();
  },
  child: Icon(Icons.photo),
)
```

### Upload Button
```dart
ElevatedButton(
  onPressed: _uploadImage,
  child: Text('Upload'),
)
```

### Display Uploaded Image
```dart
if (downloadURL != null)
  Image.network(downloadURL, height: 200)
else
  Container(child: Text('No image'))
```

---

## 🔗 Useful Links

- [Firebase Storage Docs](https://firebase.google.com/docs/storage)
- [Flutter Image Picker](https://pub.dev/packages/image_picker)
- [Security Rules Guide](https://firebase.google.com/docs/storage/security/start)
- [Storage Metadata](https://firebase.google.com/docs/storage/files/metadata)

---

**Keep this page open while coding!** 📌
