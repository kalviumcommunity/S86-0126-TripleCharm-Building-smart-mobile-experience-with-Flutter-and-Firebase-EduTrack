import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/storage_service.dart';

/// Firebase Storage Code Examples
/// 
/// This file contains practical examples of Firebase Storage operations
/// including uploads, downloads, file management, and UI integration

// ==================== BASIC UPLOAD EXAMPLES ====================

/// Example 1: Simple image upload
Future<String> uploadProfilePicture(XFile imageFile) async {
  final storageService = StorageService();
  
  try {
    final downloadURL = await storageService.uploadImage(
      imageFile,
      folder: 'profile_pictures',
    );
    return downloadURL;
  } catch (e) {
    print('Error uploading profile picture: $e');
    rethrow;
  }
}

/// Example 2: Upload with progress tracking
Future<String> uploadImageWithProgress(
  XFile imageFile,
  Function(double) onProgress,
) async {
  final storageService = StorageService();
  
  return await storageService.uploadImage(
    imageFile,
    folder: 'uploads',
    onProgress: onProgress,
  );
}

/// Example 3: Upload multiple images at once
Future<List<String>> uploadMultipleProfileImages(
  List<XFile> images,
) async {
  final storageService = StorageService();
  
  return await storageService.uploadMultipleImages(
    images,
    folder: 'gallery',
  );
}

// ==================== DOWNLOAD & RETRIEVE ====================

/// Example 4: Get download URL for existing file
Future<String> getImageDownloadURL(String filePath) async {
  final storageService = StorageService();
  
  try {
    final url = await storageService.getDownloadURL(filePath);
    return url;
  } catch (e) {
    print('Error getting download URL: $e');
    rethrow;
  }
}

/// Example 5: Download file to device
Future<void> downloadImageToDevice(
  String remoteFilePath,
  String localSavePath,
) async {
  final storageService = StorageService();
  
  try {
    await storageService.downloadFile(
      remoteFilePath,
      localSavePath,
      onProgress: (progress) {
        print('Download progress: ${(progress * 100).toStringAsFixed(0)}%');
      },
    );
  } catch (e) {
    print('Error downloading file: $e');
    rethrow;
  }
}

/// Example 6: Get file metadata
Future<void> getFileInfo(String filePath) async {
  final storageService = StorageService();
  
  try {
    final metadata = await storageService.getFileMetadata(filePath);
    
    if (metadata != null) {
      print('File Size: ${metadata.size} bytes');
      print('Content Type: ${metadata.contentType}');
      print('Created: ${metadata.timeCreated}');
      print('Custom Metadata: ${metadata.customMetadata}');
    }
  } catch (e) {
    print('Error getting metadata: $e');
  }
}

// ==================== DELETE OPERATIONS ====================

/// Example 7: Delete single file
Future<void> deleteProfilePicture(String filePath) async {
  final storageService = StorageService();
  
  try {
    await storageService.deleteFile(filePath);
    print('File deleted successfully');
  } catch (e) {
    print('Error deleting file: $e');
    rethrow;
  }
}

/// Example 8: Delete multiple files
Future<void> deleteChatImages(List<String> filePaths) async {
  final storageService = StorageService();
  
  try {
    await storageService.deleteFiles(filePaths);
    print('All files deleted');
  } catch (e) {
    print('Error deleting files: $e');
    rethrow;
  }
}

// ==================== LIST & BROWSE ====================

/// Example 9: List all files in folder
Future<List<String>> getFilesInFolder(String folderPath) async {
  final storageService = StorageService();
  
  try {
    final files = await storageService.listFilesInFolder(folderPath);
    print('Found ${files.length} files');
    return files;
  } catch (e) {
    print('Error listing files: $e');
    rethrow;
  }
}

/// Example 10: Get detailed info for all files in folder
Future<List<Map<String, dynamic>>> getDetailedFileList(
  String folderPath,
) async {
  final storageService = StorageService();
  
  try {
    final fileInfo = await storageService.getFileInfoInFolder(folderPath);
    
    for (var file in fileInfo) {
      print('Name: ${file['name']}');
      print('Size: ${file['size']} bytes');
      print('URL: ${file['downloadURL']}');
      print('---');
    }
    
    return fileInfo;
  } catch (e) {
    print('Error getting file info: $e');
    rethrow;
  }
}

// ==================== UTILITY OPERATIONS ====================

/// Example 11: Check if file exists
Future<bool> doesFileExist(String filePath) async {
  final storageService = StorageService();
  
  try {
    return await storageService.fileExists(filePath);
  } catch (e) {
    print('Error checking file existence: $e');
    return false;
  }
}

/// Example 12: Get file size in KB
Future<double> getFileSizeKB(String filePath) async {
  final storageService = StorageService();
  
  try {
    return await storageService.getFileSizeInKB(filePath);
  } catch (e) {
    print('Error getting file size: $e');
    return 0;
  }
}

/// Example 13: Calculate total storage usage
Future<double> getTotalStorageUsage(String folderPath) async {
  final storageService = StorageService();
  
  try {
    final usageMB = await storageService.getTotalStorageUsageInMB(folderPath);
    print('Total storage: ${usageMB.toStringAsFixed(2)} MB');
    return usageMB;
  } catch (e) {
    print('Error calculating storage: $e');
    return 0;
  }
}

/// Example 14: Update file metadata
Future<void> updateFileMetadata(
  String filePath,
  Map<String, String> metadata,
) async {
  final storageService = StorageService();
  
  try {
    await storageService.updateFileMetadata(filePath, metadata);
    print('Metadata updated');
  } catch (e) {
    print('Error updating metadata: $e');
    rethrow;
  }
}

// ==================== UI WIDGET EXAMPLES ====================

/// Widget Example 1: Image Picker Button
class ImagePickerButton extends StatelessWidget {
  final Function(XFile) onImageSelected;
  
  const ImagePickerButton({
    Key? key,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();
    
    return PopupMenuButton<String>(
      onSelected: (choice) async {
        try {
          XFile? image;
          if (choice == 'camera') {
            image = await storageService.pickImageFromCamera();
          } else {
            image = await storageService.pickImageFromGallery();
          }
          
          if (image != null) {
            onImageSelected(image);
          }
        } catch (e) {
          print('Error picking image: $e');
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'camera',
          child: Row(
            children: [
              Icon(Icons.camera_alt),
              SizedBox(width: 8),
              Text('Take Photo'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'gallery',
          child: Row(
            children: [
              Icon(Icons.photo_library),
              SizedBox(width: 8),
              Text('Choose from Gallery'),
            ],
          ),
        ),
      ],
      child: FloatingActionButton(
        onPressed: null,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

/// Widget Example 2: Upload Progress Widget
class UploadProgressWidget extends StatefulWidget {
  final XFile imageFile;
  final String folder;
  final Function(String) onUploadComplete;
  
  const UploadProgressWidget({
    Key? key,
    required this.imageFile,
    required this.folder,
    required this.onUploadComplete,
  }) : super(key: key);

  @override
  State<UploadProgressWidget> createState() => _UploadProgressWidgetState();
}

class _UploadProgressWidgetState extends State<UploadProgressWidget> {
  double _progress = 0.0;
  bool _isUploading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _uploadImage();
  }

  Future<void> _uploadImage() async {
    try {
      final storageService = StorageService();
      
      final url = await storageService.uploadImage(
        widget.imageFile,
        folder: widget.folder,
        onProgress: (progress) {
          setState(() => _progress = progress);
        },
      );
      
      setState(() => _isUploading = false);
      widget.onUploadComplete(url);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Text('Upload failed: $_error'),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(value: _progress),
        const SizedBox(height: 16),
        Text('${(_progress * 100).toStringAsFixed(0)}% uploaded'),
      ],
    );
  }
}

/// Widget Example 3: Cached Network Image Display
class CachedImageDisplay extends StatelessWidget {
  final String downloadURL;
  final double width;
  final double height;
  
  const CachedImageDisplay({
    Key? key,
    required this.downloadURL,
    this.width = 200,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      downloadURL,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image),
        );
      },
    );
  }
}

/// Widget Example 4: File List with Actions
class StorageFileListWidget extends StatefulWidget {
  final String folderPath;
  
  const StorageFileListWidget({
    Key? key,
    required this.folderPath,
  }) : super(key: key);

  @override
  State<StorageFileListWidget> createState() => _StorageFileListWidgetState();
}

class _StorageFileListWidgetState extends State<StorageFileListWidget> {
  final StorageService _storageService = StorageService();
  List<Map<String, dynamic>> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      final files =
          await _storageService.getFileInfoInFolder(widget.folderPath);
      setState(() {
        _files = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading files: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_files.isEmpty) {
      return const Center(child: Text('No files found'));
    }

    return ListView.builder(
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final file = _files[index];
        return ListTile(
          leading: const Icon(Icons.image),
          title: Text(file['name']),
          subtitle: Text(
            '${((file['size'] ?? 0) / 1024).toStringAsFixed(2)} KB',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await _storageService.deleteFile(file['path']);
              await _loadFiles();
            },
          ),
        );
      },
    );
  }
}

/// Widget Example 5: Profile Picture Upload
class ProfilePictureUpload extends StatefulWidget {
  final Function(String) onUploadComplete;
  
  const ProfilePictureUpload({
    Key? key,
    required this.onUploadComplete,
  }) : super(key: key);

  @override
  State<ProfilePictureUpload> createState() => _ProfilePictureUploadState();
}

class _ProfilePictureUploadState extends State<ProfilePictureUpload> {
  final StorageService _storageService = StorageService();
  XFile? _selectedImage;
  bool _isUploading = false;
  String? _profileImageURL;

  Future<void> _pickAndUploadImage() async {
    try {
      final image = await _storageService.pickImageFromGallery();
      if (image == null) return;

      setState(() {
        _selectedImage = image;
        _isUploading = true;
      });

      final url = await _storageService.uploadImage(
        image,
        folder: 'profile_pictures',
      );

      setState(() {
        _profileImageURL = url;
        _isUploading = false;
      });

      widget.onUploadComplete(url);
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _profileImageURL != null
                  ? NetworkImage(_profileImageURL!)
                  : null,
              child: _profileImageURL == null
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
            if (!_isUploading)
              Positioned(
                bottom: 0,
                right: 0,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: _pickAndUploadImage,
                  child: const Icon(Icons.camera_alt),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isUploading)
          const CircularProgressIndicator()
        else if (_profileImageURL != null)
          const Text(
            'Profile picture updated',
            style: TextStyle(color: Colors.green),
          ),
      ],
    );
  }
}

// ==================== FIREBASE RULES EXAMPLE ====================

/// Firebase Storage Security Rules
/// 
/// Copy this to Firebase Console → Storage → Rules
/// 
/// ```
/// rules_version = '2';
/// service firebase.storage {
///   match /b/{bucket}/o {
///     // Allow authenticated users to read all files
///     match /{allPaths=**} {
///       allow read: if request.auth != null;
///     }
///
///     // Allow authenticated users to upload images
///     match /uploads/{userId}/{fileName} {
///       allow write: if request.auth != null &&
///                       request.auth.uid == userId &&
///                       request.resource.size < 10 * 1024 * 1024 && // 10MB max
///                       request.resource.contentType.matches('image/.*');
///     }
///
///     // Profile pictures - allow user to upload their own
///     match /profile_pictures/{userId}/{fileName} {
///       allow read: if request.auth != null;
///       allow write: if request.auth != null &&
///                       request.auth.uid == userId &&
///                       request.resource.size < 5 * 1024 * 1024; // 5MB max
///     }
///
///     // Chat images - allow only authenticated users
///     match /chat_images/{chatId}/{fileName} {
///       allow read: if request.auth != null;
///       allow write: if request.auth != null &&
///                       request.resource.size < 20 * 1024 * 1024; // 20MB max
///     }
///   }
/// }
/// ```
