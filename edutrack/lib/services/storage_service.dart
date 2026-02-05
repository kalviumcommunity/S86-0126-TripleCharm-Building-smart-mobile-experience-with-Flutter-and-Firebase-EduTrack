import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Firebase Storage Service
/// 
/// Handles all file upload, download, and deletion operations
/// with Firebase Storage. Provides methods for:
/// - Uploading images, documents, and media files
/// - Retrieving download URLs
/// - Managing file metadata
/// - Deleting files
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // ==================== IMAGE PICKER ====================

  /// Pick image from device gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      print('Error picking image: $e');
      rethrow;
    }
  }

  /// Capture image using device camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      print('Error capturing image: $e');
      rethrow;
    }
  }

  /// Pick multiple images from gallery
  Future<List<XFile>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );
      return images;
    } catch (e) {
      print('Error picking multiple images: $e');
      rethrow;
    }
  }

  /// Pick video from device
  Future<XFile?> pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      return video;
    } catch (e) {
      print('Error picking video: $e');
      rethrow;
    }
  }

  // ==================== UPLOAD OPERATIONS ====================

  /// Upload image to Firebase Storage
  /// 
  /// [imageFile] - The image file to upload
  /// [folder] - Optional folder path (e.g., 'profile_pictures', 'chat_images')
  /// [onProgress] - Callback for upload progress (0.0 to 1.0)
  Future<String> uploadImage(
    XFile imageFile, {
    String folder = 'uploads',
    Function(double)? onProgress,
  }) async {
    try {
      final fileName = _generateFileName(imageFile.name);
      final ref = _storage.ref('$folder/$fileName');

      final uploadTask = ref.putFile(
        File(imageFile.path),
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploadedAt': DateTime.now().toIso8601String()},
        ),
      );

      // Listen to progress
      uploadTask.snapshotEvents.listen((event) {
        if (onProgress != null) {
          double progress =
              event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
          onProgress(progress);
        }
      });

      // Wait for completion
      await uploadTask;

      // Get download URL
      final downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload file (any type) to Firebase Storage
  /// 
  /// [file] - The file to upload
  /// [folder] - Folder path in storage
  /// [fileName] - Optional custom filename
  /// [onProgress] - Callback for progress tracking
  Future<String> uploadFile(
    File file, {
    String folder = 'uploads',
    String? fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final name = fileName ?? _generateFileName(file.path.split('/').last);
      final ref = _storage.ref('$folder/$name');

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          customMetadata: {'uploadedAt': DateTime.now().toIso8601String()},
        ),
      );

      uploadTask.snapshotEvents.listen((event) {
        if (onProgress != null) {
          double progress =
              event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
          onProgress(progress);
        }
      });

      await uploadTask;
      final downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  /// Upload multiple images
  /// 
  /// Returns list of download URLs in same order
  Future<List<String>> uploadMultipleImages(
    List<XFile> images, {
    String folder = 'uploads',
    Function(int, double)? onProgress,
  }) async {
    try {
      final List<String> downloadURLs = [];

      for (int i = 0; i < images.length; i++) {
        final url = await uploadImage(
          images[i],
          folder: folder,
          onProgress: (progress) {
            if (onProgress != null) {
              onProgress(i, progress);
            }
          },
        );
        downloadURLs.add(url);
      }

      return downloadURLs;
    } catch (e) {
      print('Error uploading multiple images: $e');
      rethrow;
    }
  }

  // ==================== DOWNLOAD & RETRIEVE ====================

  /// Get download URL for a file by path
  Future<String> getDownloadURL(String filePath) async {
    try {
      final ref = _storage.ref(filePath);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error getting download URL: $e');
      rethrow;
    }
  }

  /// Get file metadata
  Future<FullMetadata?> getFileMetadata(String filePath) async {
    try {
      final ref = _storage.ref(filePath);
      final metadata = await ref.getMetadata();
      return metadata;
    } catch (e) {
      print('Error getting file metadata: $e');
      return null;
    }
  }

  /// Download file to device
  Future<void> downloadFile(
    String remoteFilePath,
    String localFilePath, {
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref(remoteFilePath);
      final file = File(localFilePath);

      final downloadTask = ref.writeToFile(file);

      downloadTask.snapshotEvents.listen((event) {
        if (onProgress != null) {
          double progress =
              event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
          onProgress(progress);
        }
      });

      await downloadTask;
    } catch (e) {
      print('Error downloading file: $e');
      rethrow;
    }
  }

  // ==================== DELETE OPERATIONS ====================

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String filePath) async {
    try {
      final ref = _storage.ref(filePath);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }

  /// Delete multiple files
  Future<void> deleteFiles(List<String> filePaths) async {
    try {
      for (String path in filePaths) {
        await deleteFile(path);
      }
    } catch (e) {
      print('Error deleting files: $e');
      rethrow;
    }
  }

  /// Delete entire folder (all files in folder)
  /// Warning: This deletes ALL files in the folder!
  Future<void> deleteFolder(String folderPath) async {
    try {
      final ref = _storage.ref(folderPath);
      final items = await ref.listAll();

      for (var item in items.items) {
        await item.delete();
      }
    } catch (e) {
      print('Error deleting folder: $e');
      rethrow;
    }
  }

  // ==================== LIST & BROWSE ====================

  /// List all files in a folder
  Future<List<String>> listFilesInFolder(String folderPath) async {
    try {
      final ref = _storage.ref(folderPath);
      final result = await ref.listAll();

      final filePaths =
          result.items.map((item) => item.fullPath).toList();
      return filePaths;
    } catch (e) {
      print('Error listing files: $e');
      rethrow;
    }
  }

  /// Get file info for all files in folder
  Future<List<Map<String, dynamic>>> getFileInfoInFolder(
    String folderPath,
  ) async {
    try {
      final ref = _storage.ref(folderPath);
      final result = await ref.listAll();

      final List<Map<String, dynamic>> fileInfo = [];

      for (var item in result.items) {
        final metadata = await item.getMetadata();
        final downloadUrl = await item.getDownloadURL();

        fileInfo.add({
          'name': item.name,
          'path': item.fullPath,
          'size': metadata.size,
          'contentType': metadata.contentType,
          'timeCreated': metadata.timeCreated,
          'downloadURL': downloadUrl,
          'customMetadata': metadata.customMetadata,
        });
      }

      return fileInfo;
    } catch (e) {
      print('Error getting file info: $e');
      rethrow;
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Generate unique filename
  String _generateFileName(String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final extension = originalFileName.split('.').last;
    return '${timestamp}_$originalFileName';
  }

  /// Check if file exists in storage
  Future<bool> fileExists(String filePath) async {
    try {
      final ref = _storage.ref(filePath);
      await ref.getMetadata();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return false;
      }
      rethrow;
    }
  }

  /// Get file size in KB
  Future<double> getFileSizeInKB(String filePath) async {
    try {
      final metadata = await getFileMetadata(filePath);
      if (metadata != null) {
        return metadata.size! / 1024;
      }
      return 0;
    } catch (e) {
      print('Error getting file size: $e');
      return 0;
    }
  }

  /// Get total storage usage in MB
  Future<double> getTotalStorageUsageInMB(String folderPath) async {
    try {
      final files = await getFileInfoInFolder(folderPath);
      double totalBytes = 0;

      for (var file in files) {
        totalBytes += file['size'] ?? 0;
      }

      return totalBytes / (1024 * 1024);
    } catch (e) {
      print('Error calculating storage: $e');
      return 0;
    }
  }

  /// Update file metadata
  Future<void> updateFileMetadata(
    String filePath,
    Map<String, String> customMetadata,
  ) async {
    try {
      final ref = _storage.ref(filePath);
      await ref.updateMetadata(
        SettableMetadata(customMetadata: customMetadata),
      );
    } catch (e) {
      print('Error updating metadata: $e');
      rethrow;
    }
  }
}
