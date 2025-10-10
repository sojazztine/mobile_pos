import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Helper class for handling image picking functionality
/// Provides consistent image picking across the app with proper error handling
class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Show a bottom sheet to let user choose between camera or gallery
  static Future<File?> pickImageWithOptions(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.pink),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.pink),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      return await pickImage(source);
    }
    return null;
  }

  /// Pick an image from the specified source
  static Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Pick an image from gallery directly
  static Future<File?> pickFromGallery() async {
    return await pickImage(ImageSource.gallery);
  }

  /// Pick an image from camera directly
  static Future<File?> pickFromCamera() async {
    return await pickImage(ImageSource.camera);
  }

  /// Pick multiple images from gallery
  static Future<List<File>?> pickMultipleImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        return pickedFiles.map((xFile) => File(xFile.path)).toList();
      }
      return null;
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return null;
    }
  }

  /// Show error dialog when image picking fails
  static void showImagePickerError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show a dialog to confirm image selection with preview
  static Future<bool> confirmImageSelection(
    BuildContext context,
    File imageFile,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                imageFile,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Use this image?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Use Image'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
