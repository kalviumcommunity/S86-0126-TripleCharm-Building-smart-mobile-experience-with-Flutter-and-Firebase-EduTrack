# Firebase Storage Media Upload System - Assignment

## 📋 Project Overview

This project implements a **complete Firebase Storage media upload system** for the EduTrack Flutter application. It demonstrates how to securely upload, manage, and display media files (images, videos, documents) using Google's Firebase Storage service.

### Key Features
- 📸 Image selection from gallery or camera
- ⬆️ File upload with progress tracking
- 🔗 Download URL generation and management
- 📋 Uploaded files list and browsing
- 🗑️ File deletion and cleanup
- 🔐 Security rules implementation
- 📊 Real-time file information display

---

## 🔄 Media Upload Flow

### Complete Upload Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    USER INITIATES UPLOAD                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              1. SELECT MEDIA SOURCE                          │
│   ┌──────────────────┐         ┌──────────────────┐        │
│   │   GALLERY        │  OR     │    CAMERA        │        │
│   │  (pickImage)     │         │  (captureImage)  │        │
│   └──────────────────┘         └──────────────────┘        │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│           2. PREVIEW SELECTED MEDIA                         │
│        Display thumbnail before proceeding                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              3. CHOOSE UPLOAD FOLDER                         │
│   uploads / profile_pictures / chat_images / documents       │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│            4. UPLOAD FILE TO FIREBASE STORAGE               │
│              With progress tracking (0-100%)                 │
│                                                              │
│  StorageService.uploadImage(                                │
│    imageFile,                                               │
│    folder: 'uploads',                                       │
│    onProgress: (progress) { /* update UI */ }               │
│  )                                                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│         5. GENERATE DOWNLOAD URL                            │
│     Make file publicly accessible (if rules allow)          │
│                                                              │
│  final url = await storageRef.getDownloadURL();            │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│        6. DISPLAY DOWNLOAD URL TO USER                      │
│   ✅ Show in text field (selectable + copyable)             │
│   ✅ Allow opening URL to view uploaded file                │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│        7. ADD FILE TO UPLOADED FILES LIST                   │
│      Real-time list shows:                                  │
│      • File name                                            │
│      • File size (KB)                                       │
│      • View/Delete options                                  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│            8. OPTIONAL: MANAGE FILE                         │
│   ┌──────────────┐        ┌──────────────────┐             │
│   │   VIEW URL   │   OR   │   DELETE FILE    │             │
│   └──────────────┘        └──────────────────┘             │
└─────────────────────────────────────────────────────────────┘
```

### Upload Flow Explanation

**Phase 1: Selection & Preview**
1. User clicks **Gallery** or **Camera** button
2. Image picker opens and user selects/captures image
3. Selected image displays as preview in UI
4. File status shows "Ready to upload"

**Phase 2: Upload Preparation**
5. User selects destination folder (uploads, profile_pictures, etc.)
6. User clicks **Upload Image** button
7. Upload button changes to loading spinner
8. Progress bar appears and begins tracking

**Phase 3: Transmission**
9. File sends to Firebase Storage via HTTP PUT request
10. Progress callback fires continuously during upload
11. Progress bar fills (0% → 100%) as file uploads
12. Percentage text updates in real-time

**Phase 4: Completion & Retrieval**
13. After upload completes, getDownloadURL() is called
14. Firebase returns public URL if file is readable per security rules
15. URL displays in green success card
16. User can copy URL or click to view uploaded file

**Phase 5: Management**
17. File list automatically refreshes
18. Newly uploaded file appears with name, size, timestamps
19. User can view individual file URLs
20. User can delete files (triggers deleteFile() → list refresh)

---

## 💻 Code Snippets

### 1. File Picker Implementation

**Gallery Selection:**
```dart
Future<void> _pickImageFromGallery() async {
  try {
    final image = await StorageService().pickImageFromGallery();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  } catch (e) {
    _showErrorSnackBar('Error picking image: $e');
  }
}
```

**Camera Capture:**
```dart
Future<void> _pickImageFromCamera() async {
  try {
    final image = await StorageService().pickImageFromCamera();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  } catch (e) {
    _showErrorSnackBar('Error capturing image: $e');
  }
}
```

### 2. Upload Logic with Progress Tracking

```dart
Future<void> _uploadImage() async {
  if (_selectedImage == null) {
    _showErrorSnackBar('Please select an image first');
    return;
  }

  setState(() {
    _isUploading = true;
    _uploadProgress = 0.0;
  });

  try {
    final downloadURL = await StorageService().uploadImage(
      _selectedImage!,
      folder: _selectedFolder,
      // Listen to progress updates
      onProgress: (progress) {
        setState(() {
          _uploadProgress = progress; // 0.0 to 1.0
        });
      },
    );

    setState(() {
      _downloadURL = downloadURL;
      _uploadProgress = 0.0;
      _isUploading = false;
    });

    _showSuccessSnackBar('Image uploaded successfully!');
    await _loadUploadedFiles(); // Refresh file list
  } catch (e) {
    _showErrorSnackBar('Upload failed: $e');
  } finally {
    setState(() {
      _isUploading = false;
      _uploadProgress = 0.0;
    });
  }
}
```

### 3. Download URL Retrieval

```dart
Future<String> getDownloadURL(String filePath) async {
  try {
    final ref = FirebaseStorage.instance.ref(filePath);
    final url = await ref.getDownloadURL();
    return url;
  } catch (e) {
    throw Exception('Failed to get download URL: $e');
  }
}
```

### 4. Image Display in UI

**Simple Network Image:**
```dart
if (_downloadURL != null)
  Image.network(
    _downloadURL!,
    height: 250,
    width: double.infinity,
    fit: BoxFit.cover,
  )
```

**With Error Handling:**
```dart
Image.network(
  url,
  height: 250,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Container(
      color: Colors.grey[300],
      child: Icon(Icons.broken_image),
    );
  },
)
```

**As Profile Picture (Circular):**
```dart
CircleAvatar(
  backgroundImage: NetworkImage(url),
  radius: 60,
  onBackgroundImageError: (exception, stackTrace) {
    // Handle error
  },
)
```

**In ListView (File List):**
```dart
ListView.builder(
  itemCount: _uploadedFiles.length,
  itemBuilder: (context, index) {
    final file = _uploadedFiles[index];
    return ListTile(
      leading: Icon(Icons.image),
      title: Text(file.name),
      subtitle: Text('${file.sizeKB.toStringAsFixed(2)} KB'),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Text('View URL'),
            onTap: () => _showURLDialog(file.url),
          ),
          PopupMenuItem(
            child: Text('Delete'),
            onTap: () => _deleteFile(file.path),
          ),
        ],
      ),
    );
  },
)
```

### 5. File Management

**Delete File:**
```dart
Future<void> _deleteFile(String filePath) async {
  try {
    await StorageService().deleteFile(filePath);
    _showSuccessSnackBar('File deleted successfully');
    await _loadUploadedFiles(); // Refresh list
  } catch (e) {
    _showErrorSnackBar('Delete failed: $e');
  }
}
```

**List Files in Folder:**
```dart
Future<void> _loadUploadedFiles() async {
  try {
    setState(() => _isLoadingFiles = true);
    
    final files = await StorageService()
        .getFileInfoInFolder(_selectedFolder);
    
    setState(() {
      _uploadedFiles = files;
      _isLoadingFiles = false;
    });
  } catch (e) {
    _showErrorSnackBar('Failed to load files: $e');
    setState(() => _isLoadingFiles = false);
  }
}
```

---

## 📸 Screenshots & UI Components

### App UI During Upload

**Image Selection Screen:**
```
┌─────────────────────────────────────┐
│     Firebase Storage Upload         │
├─────────────────────────────────────┤
│                                      │
│   ┌─────────────────────────────┐  │
│   │   [Selected Image Preview]  │  │
│   │         (250 x 250)         │  │
│   └─────────────────────────────┘  │
│                                      │
│        [Gallery] [Camera]            │
│                                      │
│     📁 Folder: uploads ▼             │
│                                      │
│        [Upload Image]                │
│                                      │
└─────────────────────────────────────┘
```

**During Upload:**
```
┌─────────────────────────────────────┐
│     Firebase Storage Upload         │
├─────────────────────────────────────┤
│  ⏳ Uploading...                     │
│                                      │
│  ████████░░░░░░░░░░ 45%            │
│                                      │
│  Size: 2.5 MB                       │
│  Speed: 500 KB/s                    │
│                                      │
│        [Cancel]                      │
│                                      │
└─────────────────────────────────────┘
```

**After Upload Success:**
```
┌─────────────────────────────────────┐
│     Firebase Storage Upload         │
├─────────────────────────────────────┤
│                                      │
│  ✅ Upload Complete                  │
│                                      │
│  📎 Download URL:                   │
│  ┌────────────────────────────────┐ │
│  │https://firebasestorage.        │ │
│  │googleapis.com/b/edutrack...    │ │
│  └────────────────────────────────┘ │
│        [Copy URL] [Open]            │
│                                      │
│  📋 Uploaded Files:                 │
│  • image1.jpg (1.2 MB)              │
│  • image2.jpg (2.5 MB)              │
│  • image3.jpg (892 KB)              │
│                                      │
└─────────────────────────────────────┘
```

### Firebase Console Storage View

After uploading to Firebase, you'll see:

**Console Path:**
```
Firebase Console 
  → Select Project: edutrack-49094
  → Storage
  → Browser tab
  → Folder: uploads/
      ├── image_12345.jpg (Size: 2.5 MB)
      ├── image_67890.jpg (Size: 1.2 MB)
      └── ...
```

**File Properties in Console:**
```
File: image_12345.jpg
├── Size: 2,548,576 bytes
├── Content-Type: image/jpeg
├── Created: 2024-01-15 10:30:45 UTC
├── Modified: 2024-01-15 10:30:45 UTC
├── Download URL: https://firebasestorage.googleapis.com/b/edutrack...
└── Metadata:
    ├── ___ Custom metadata (if set)
```

---

## 🎯 Success Metrics & Acceptance Criteria

Your implementation is successful when:

- [ ] **Image Selection Works**
  - Gallery button opens photo picker
  - Camera button opens camera app
  - Selected image displays in preview
  - Image preview updates when new selection made

- [ ] **Upload Functionality**
  - Upload button triggers upload process
  - Upload button shows loading spinner during upload
  - Progress bar appears and updates (0-100%)
  - Percentage text displays current progress
  - Upload completes without errors

- [ ] **Download URL Display**
  - Success message shows after upload
  - Download URL displays in text field
  - URL is selectable (can be copied)
  - URL is valid and image loads when opened

- [ ] **Folder Management**
  - Folder dropdown shows all available options
  - Files upload to selected folder
  - Switching folders changes file list
  - File list updates when folder selected

- [ ] **File Management**
  - Uploaded files appear in list
  - File list shows: name, size, timestamp
  - "View URL" button displays file URL
  - "Delete" button removes file
  - File list refreshes after delete
  - Empty state shows when no files

- [ ] **Error Handling**
  - Red error message displays on failures
  - Error message includes helpful details
  - App doesn't crash on errors
  - User can retry after error

- [ ] **Firebase Console**
  - Navigate to Firebase Console → Storage
  - View uploaded files in "uploads" folder
  - Files show correct names and sizes
  - Download URLs work correctly

---

## 🔐 Security Rules Configuration

### Step 1: Navigate to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **edutrack-49094**
3. Click **Storage** in left sidebar
4. Click **Rules** tab

### Step 2: Update Security Rules

**Recommended Rules (Authenticated Users Only):**

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload to their folder
    match /uploads/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
    
    // Allow profile pictures access
    match /profile_pictures/{allPaths=**} {
      allow read: if true; // Public read
      allow write: if request.auth != null; // Auth write
    }
    
    // Allow chat images access
    match /chat_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Allow documents with auth only
    match /documents/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Step 3: Publish Rules

1. Click **Publish** button
2. Wait for "✅ Rules updated successfully" message
3. Test permissions are working

### Step 4: Verify by Testing Upload

1. Use the demo app to upload an image
2. Check Firebase Console to see uploaded file
3. Verify you can download the file

---

## 🧪 Testing Checklist

Complete these tests to verify your implementation:

### Basic Upload Test
- [ ] Launch the app
- [ ] Navigate to Storage demo
- [ ] Click **Gallery** button
- [ ] Select an image from device
- [ ] Image preview displays
- [ ] Click **Upload Image** button
- [ ] Progress bar appears and updates
- [ ] Upload completes (100%)
- [ ] Download URL displays
- [ ] URL is correct (starts with https://firebasestorage)

### Multiple Folder Test
- [ ] Upload image to **uploads** folder
- [ ] Switch to **profile_pictures** folder
- [ ] Upload another image
- [ ] Files appear in correct folders
- [ ] Switching back shows correct files

### File Management Test
- [ ] Upload 2-3 images
- [ ] See them appear in files list
- [ ] Click **View URL** for each file
- [ ] URLs open in browser and display images
- [ ] Click **Delete** for one file
- [ ] File removes from list
- [ ] Refresh list (should still be gone)

### Camera Test
- [ ] Click **Camera** button
- [ ] Capture a photo
- [ ] Upload the photo
- [ ] Verify upload succeeds
- [ ] Photo appears in files list

### Error Handling Test
- [ ] Select image but logout before uploading
- [ ] Try to upload
- [ ] Error message displays (red)
- [ ] Can login again and retry successfully

### Firebase Console Test
- [ ] Open [Firebase Console](https://console.firebase.google.com)
- [ ] Go to Storage → Browser
- [ ] Click **uploads** folder
- [ ] See your uploaded image files
- [ ] Verify file names and sizes match app
- [ ] Check file dates are recent

---

## 📋 Implementation Summary

### What Was Created

1. **StorageService** (`lib/services/storage_service.dart`)
   - 30+ methods for file operations
   - Image picking, uploading, downloading
   - File listing and deletion
   - Progress tracking support
   - Complete error handling

2. **Upload Demo Screen** (`lib/screens/firebase_storage_upload_demo.dart`)
   - Interactive user interface
   - Image selection with preview
   - Real-time upload progress
   - Download URL display
   - Folder management
   - File browsing
   - Delete functionality

3. **Code Examples** (`lib/examples/firebase_storage_examples.dart`)
   - 14 operation examples
   - 5 UI widget templates
   - Security rules samples
   - Ready to copy-paste

4. **Documentation**
   - Comprehensive guide with tutorials
   - Quick reference cheatsheet
   - Quick start guide
   - Package README

### Integration Points

- Routes added to `main.dart`
- Demo added to launcher screen
- Dependencies in `pubspec.yaml`
- Ready for Firebase project

---

## 🚀 Next Steps for Integration

### Step 1: Add to Your Dashboard
```dart
// In any screen, add a button:
ElevatedButton.icon(
  onPressed: () => Navigator.pushNamed(context, '/firebase-storage-upload'),
  icon: Icon(Icons.cloud_upload),
  label: Text('Upload Media'),
)
```

### Step 2: Use in Assignment Upload Feature
```dart
// In assignment submission screen:
final image = await StorageService().pickImageFromGallery();
final url = await StorageService().uploadImage(image, folder: 'assignments');

// Save URL to Firestore:
await FirebaseFirestore.instance
    .collection('assignments')
    .doc(assignmentId)
    .update({'attachment_url': url});
```

### Step 3: Display in Lists
```dart
// In assignment list:
Image.network(assignment['attachment_url'])
```

---

## 🔗 Resource Links

- [Firebase Storage Docs](https://firebase.google.com/docs/storage)
- [Flutter Image Picker Package](https://pub.dev/packages/image_picker)
- [Security Rules Guide](https://firebase.google.com/docs/storage/security)
- [Firebase Console](https://console.firebase.google.com)

---

## 📝 Reflection Questions

After completing this assignment, reflect on:

1. **Why is media upload important?**
   - Answer: Enables users to share photos, documents, and files within the app. Essential for social apps, document management, and collaborative tools.

2. **Where might you use this in the EduTrack app?**
   - Answer: 
     - Upload assignment attachments
     - Share profile pictures
     - Store class photos
     - Document submission
     - Chat attachments

3. **What permissions were needed?**
   - Answer:
     - Camera permission (iOS/Android)
     - Photo library permission (iOS)
     - Read/write storage (Android)

4. **What challenges did you face?**
   - Answer: Describe any issues with:
     - Permission handling
     - Image compression
     - Upload timeouts
     - File size limits
     - Error handling

5. **How would you improve this for production?**
   - Answer:
     - Image compression before upload
     - Batch upload support
     - Offline upload queue
     - Resume interrupted uploads
     - Thumbnail generation
     - CDN caching

---

## ✅ Submission Checklist

Before submitting, verify:

- [ ] All code files created and in correct directories
- [ ] Firebase Storage demo screen working
- [ ] Can pick and upload images
- [ ] Progress tracking displays correctly
- [ ] Download URLs work in browser
- [ ] Files appear in Firebase Console
- [ ] File deletion works
- [ ] Error handling in place
- [ ] Security rules configured
- [ ] Routes added to main.dart
- [ ] Demo integrated into launcher
- [ ] Documentation reviewed
- [ ] All tests passing

---

## 📞 Troubleshooting

### Image won't upload
**Check:**
- User is logged in
- Firebase project is active
- Internet connection working
- Image file isn't corrupted

### Can't pick image
**Check:**
- Permissions granted in device settings
- Phone has storage and photo app

### Upload shows 0%
**Check:**
- Image isn't too large
- Firebase Storage enabled
- Rules allow write permission

### Download URL doesn't work
**Check:**
- Copy exact URL (no spaces)
- File still exists in storage
- Security rules allow read

### Files don't appear in console
**Check:**
- Logged into correct Firebase project
- Storage enabled in project
- Looking in correct folder (uploads)

---

**Assignment Complete! You now have a production-ready Firebase Storage implementation.** 🎉

For questions, review the comprehensive guide or study the code examples provided.
