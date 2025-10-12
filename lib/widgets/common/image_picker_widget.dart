import 'dart:io';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';

/// Reusable widget for displaying and picking images
class ImagePickerWidget extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback onTap;
  final double size;
  final IconData? placeholderIcon;
  final String? placeholderText;
  final bool showEditIcon;
  final BoxShape shape;

  const ImagePickerWidget({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.onTap,
    this.size = 120,
    this.placeholderIcon = Icons.add_photo_alternate,
    this.placeholderText,
    this.showEditIcon = true,
    this.shape = BoxShape.circle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: shape,
              color: AppColors.border,
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
              image: _getDecorationImage(),
            ),
            child: _getDecorationImage() == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        placeholderIcon,
                        size: size * 0.4,
                        color: AppColors.textSecondary,
                      ),
                      if (placeholderText != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          placeholderText!,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppDimensions.fontSmall,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  )
                : null,
          ),
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  DecorationImage? _getDecorationImage() {
    if (imageFile != null) {
      return DecorationImage(
        image: FileImage(imageFile!),
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Check if it's a local file path
      if (File(imageUrl!).existsSync()) {
        return DecorationImage(
          image: FileImage(File(imageUrl!)),
          fit: BoxFit.cover,
        );
      }
      // Otherwise assume it's a network URL
      return DecorationImage(
        image: NetworkImage(imageUrl!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }
}

/// Circular profile image picker widget
class ProfileImagePicker extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final String? userName;
  final VoidCallback onTap;
  final double size;

  const ProfileImagePicker({
    super.key,
    this.imageFile,
    this.imageUrl,
    this.userName,
    required this.onTap,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    // If no image, show initials
    if (imageFile == null && (imageUrl == null || imageUrl!.isEmpty)) {
      return GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Center(
                child: Text(
                  _getInitials(userName ?? 'User'),
                  style: TextStyle(
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ImagePickerWidget(
      imageFile: imageFile,
      imageUrl: imageUrl,
      onTap: onTap,
      size: size,
      placeholderIcon: Icons.person,
      shape: BoxShape.circle,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'U';
  }
}

/// Product image picker widget
class ProductImagePicker extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback onTap;
  final double size;

  const ProductImagePicker({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.onTap,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return ImagePickerWidget(
      imageFile: imageFile,
      imageUrl: imageUrl,
      onTap: onTap,
      size: size,
      placeholderIcon: Icons.restaurant_menu,
      placeholderText: 'Add Product\nImage',
      shape: BoxShape.rectangle,
    );
  }
}
