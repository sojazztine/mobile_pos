import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Service for handling image storage in the app
/// Manages saving, loading, and deleting images
class ImageStorageService {
  static final ImageStorageService instance = ImageStorageService._init();

  ImageStorageService._init();

  /// Get the app's images directory
  Future<Directory> _getImagesDirectory() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory imagesDir = Directory('${appDocDir.path}/images');

    // Create directory if it doesn't exist
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    return imagesDir;
  }

  /// Save an image file and return the saved file path
  /// [imageFile] - The image file to save
  /// [fileName] - Optional custom file name (without extension)
  /// [category] - Optional category folder (e.g., 'profiles', 'products')
  Future<String?> saveImage(
    File imageFile, {
    String? fileName,
    String? category,
  }) async {
    try {
      final Directory imagesDir = await _getImagesDirectory();

      // Create category subdirectory if specified
      Directory targetDir = imagesDir;
      if (category != null && category.isNotEmpty) {
        targetDir = Directory('${imagesDir.path}/$category');
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
      }

      // Generate file name
      final String extension = path.extension(imageFile.path);
      final String finalFileName = fileName ??
          '${DateTime.now().millisecondsSinceEpoch}$extension';

      // Copy file to app directory
      final String newPath = '${targetDir.path}/$finalFileName';
      final File newImage = await imageFile.copy(newPath);

      debugPrint('Image saved to: ${newImage.path}');
      return newImage.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  /// Save a profile image
  Future<String?> saveProfileImage(File imageFile, int userId) async {
    return await saveImage(
      imageFile,
      fileName: 'profile_$userId${path.extension(imageFile.path)}',
      category: 'profiles',
    );
  }

  /// Save a product image
  Future<String?> saveProductImage(File imageFile, int productId) async {
    return await saveImage(
      imageFile,
      fileName: 'product_$productId${path.extension(imageFile.path)}',
      category: 'products',
    );
  }

  /// Get an image file from path
  Future<File?> getImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        return imageFile;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting image: $e');
      return null;
    }
  }

  /// Delete an image file
  Future<bool> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        debugPrint('Image deleted: $imagePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Delete old profile image when updating
  Future<void> deleteOldProfileImage(String? oldImagePath) async {
    if (oldImagePath != null && oldImagePath.isNotEmpty) {
      await deleteImage(oldImagePath);
    }
  }

  /// Delete old product image when updating
  Future<void> deleteOldProductImage(String? oldImagePath) async {
    if (oldImagePath != null && oldImagePath.isNotEmpty) {
      await deleteImage(oldImagePath);
    }
  }

  /// Get the total size of all images
  Future<int> getTotalImagesSize() async {
    try {
      final Directory imagesDir = await _getImagesDirectory();
      int totalSize = 0;

      if (await imagesDir.exists()) {
        await for (var entity in imagesDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('Error calculating images size: $e');
      return 0;
    }
  }

  /// Clear all images (use with caution!)
  Future<bool> clearAllImages() async {
    try {
      final Directory imagesDir = await _getImagesDirectory();
      if (await imagesDir.exists()) {
        await imagesDir.delete(recursive: true);
        await imagesDir.create(recursive: true);
        debugPrint('All images cleared');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error clearing images: $e');
      return false;
    }
  }

  /// Format bytes to human-readable string
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
