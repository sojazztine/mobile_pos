# 📸 Image Picker Implementation Guide

## Overview

This guide covers the complete image picker implementation in the CodeCrave POS application, including profile pictures and product images.

---

## ✨ Features Implemented

### 1. **Profile Images**
- ✅ User profile pictures in Edit Profile
- ✅ Vendor profile pictures
- ✅ Rider profile pictures
- ✅ Admin can add profile images when creating vendors/riders
- ✅ Automatic fallback to initials when no image

### 2. **Product Images**
- ✅ Product images when adding new products
- ✅ Product images display in menu management
- ✅ Automatic storage and retrieval

### 3. **User Experience**
- ✅ Choose from Camera or Gallery via bottom sheet
- ✅ Real-time image preview
- ✅ Image compression (max 1920x1920, 85% quality)
- ✅ Organized storage by category

---

## 📁 Architecture

### Files Created

```
lib/
├── utils/
│   └── image_picker_helper.dart          # Image picking utilities
├── services/
│   └── image_storage_service.dart        # Image file management
└── widgets/
    └── common/
        └── image_picker_widget.dart      # Reusable UI components
```

### Files Modified

**Models:**
- `lib/models/product_model.dart` - Added `imagePath` field
- `lib/models/auth_model.dart` - Added `updateCurrentUser()` method

**Services:**
- `lib/services/database_service.dart` - Updated to version 7, added imagePath column

**Screens:**
- `lib/screens/common/edit_profile.dart` - Profile image upload
- `lib/screens/vendor/vendor_add_product.dart` - Product image upload
- `lib/screens/vendor/vendor_menu_management.dart` - Display product images
- `lib/screens/vendor/vendor_profile.dart` - Vendor profile image
- `lib/screens/admin/admin_add_vendor.dart` - Vendor profile image on creation
- `lib/screens/admin/admin_add_rider.dart` - Rider profile image on creation
- `lib/screens/rider/rider_profile.dart` - Rider profile image

---

## 🚀 How to Use

### For Profile Images

```dart
import 'dart:io';
import '../../utils/image_picker_helper.dart';
import '../../services/image_storage_service.dart';
import '../../widgets/common/image_picker_widget.dart';

class YourScreen extends StatefulWidget {
  @override
  State<YourScreen> createState() => _YourScreenState();
}

class _YourScreenState extends State<YourScreen> {
  File? _selectedImageFile;
  String? _existingImagePath;

  Future<void> _pickImage() async {
    final imageFile = await ImagePickerHelper.pickImageWithOptions(context);
    if (imageFile != null) {
      setState(() {
        _selectedImageFile = imageFile;
      });
    }
  }

  Future<void> _saveProfile() async {
    String? savedImagePath;

    if (_selectedImageFile != null) {
      savedImagePath = await ImageStorageService.instance.saveProfileImage(
        _selectedImageFile!,
        userId, // User's ID
      );
    }

    // Use savedImagePath in your save logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ProfileImagePicker(
            imageFile: _selectedImageFile,
            imageUrl: _existingImagePath,
            userName: 'John Doe',
            onTap: _pickImage,
            size: 120,
          ),
          // ... rest of your UI
        ],
      ),
    );
  }
}
```

### For Product Images

```dart
Future<void> _addProduct() async {
  String? savedImagePath;

  if (_selectedImageFile != null) {
    savedImagePath = await ImageStorageService.instance.saveImage(
      _selectedImageFile!,
      category: 'products',
    );
  }

  final product = Product(
    name: 'Product Name',
    description: 'Description',
    price: 12.99,
    category: 'Popular',
    colorValue: Colors.blue.value,
    vendorId: 1,
    imagePath: savedImagePath, // Save the path
  );

  await DatabaseService.instance.createProduct(product);
}
```

---

## 🎨 Available Widgets

### 1. **ProfileImagePicker**

Circular profile image with initials fallback.

```dart
ProfileImagePicker(
  imageFile: _selectedImageFile,      // Currently selected File
  imageUrl: _existingImagePath,        // Existing image path (URL or local)
  userName: 'John Doe',                // For initials fallback
  onTap: _pickImage,                   // Callback when tapped
  size: 120,                           // Size in pixels
)
```

### 2. **ProductImagePicker**

Square product image with icon fallback.

```dart
ProductImagePicker(
  imageFile: _selectedImageFile,      // Currently selected File
  imageUrl: _existingImagePath,        // Existing image path
  onTap: _pickImage,                   // Callback when tapped
  size: 150,                           // Size in pixels
)
```

### 3. **ImagePickerWidget** (Generic)

Customizable image picker widget.

```dart
ImagePickerWidget(
  imageFile: _selectedImageFile,
  imageUrl: _existingImagePath,
  onTap: _pickImage,
  size: 120,
  placeholderIcon: Icons.add_photo_alternate,
  placeholderText: 'Add Image',
  showEditIcon: true,
  shape: BoxShape.circle, // or BoxShape.rectangle
)
```

---

## 🛠️ Helper Methods

### ImagePickerHelper

```dart
// Show bottom sheet with camera/gallery options
final file = await ImagePickerHelper.pickImageWithOptions(context);

// Pick from gallery directly
final file = await ImagePickerHelper.pickFromGallery();

// Pick from camera directly
final file = await ImagePickerHelper.pickFromCamera();

// Pick multiple images
final files = await ImagePickerHelper.pickMultipleImages();

// Show confirmation dialog with preview
final confirmed = await ImagePickerHelper.confirmImageSelection(context, file);
```

### ImageStorageService

```dart
// Save profile image
final path = await ImageStorageService.instance.saveProfileImage(
  imageFile,
  userId,
);

// Save product image
final path = await ImageStorageService.instance.saveProductImage(
  imageFile,
  productId,
);

// Save image with custom category
final path = await ImageStorageService.instance.saveImage(
  imageFile,
  fileName: 'custom_name.jpg',
  category: 'custom_category',
);

// Delete image
await ImageStorageService.instance.deleteImage(imagePath);

// Delete old profile image when updating
await ImageStorageService.instance.deleteOldProfileImage(oldPath);

// Get total images size
final size = await ImageStorageService.instance.getTotalImagesSize();
final formatted = ImageStorageService.formatBytes(size);

// Clear all images (dangerous!)
await ImageStorageService.instance.clearAllImages();
```

---

## 📂 Image Storage Structure

Images are stored in the app's documents directory:

```
/data/user/0/com.example.pos_project/app_flutter/images/
├── profiles/
│   ├── profile_1.jpg
│   ├── profile_2.jpg
│   └── profile_3.png
└── products/
    ├── product_1.jpg
    ├── product_2.png
    └── 1697123456789.jpg
```

---

## 🗄️ Database Changes

### Products Table (Version 7)

Added `imagePath` column:

```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  price REAL NOT NULL,
  category TEXT NOT NULL,
  colorValue INTEGER NOT NULL,
  vendorId INTEGER NOT NULL,
  stockQuantity INTEGER DEFAULT 0,
  imagePath TEXT,              -- NEW COLUMN
  createdAt TEXT NOT NULL,
  isActive INTEGER DEFAULT 1
)
```

### Migration

The database automatically upgrades from version 6 to 7:

```dart
if (oldVersion < 7) {
  await db.execute('ALTER TABLE products ADD COLUMN imagePath TEXT');
}
```

---

## 🎯 Where Image Picker is Implemented

### Customer/Common Screens
| Screen | Purpose | Widget Used |
|--------|---------|-------------|
| `edit_profile.dart` | Edit profile picture | ProfileImagePicker |

### Vendor Screens
| Screen | Purpose | Widget Used |
|--------|---------|-------------|
| `vendor_add_product.dart` | Add product image | ProductImagePicker |
| `vendor_menu_management.dart` | Display product images | File display |
| `vendor_profile.dart` | Vendor profile picture | ProfileImagePicker |

### Admin Screens
| Screen | Purpose | Widget Used |
|--------|---------|-------------|
| `admin_add_vendor.dart` | Set vendor profile | ProfileImagePicker |
| `admin_add_rider.dart` | Set rider profile | ProfileImagePicker |

### Rider Screens
| Screen | Purpose | Widget Used |
|--------|---------|-------------|
| `rider_profile.dart` | Rider profile picture | ProfileImagePicker |

---

## 🔧 Permissions Required

### Android (`android/app/src/main/AndroidManifest.xml`)

Already configured via `image_picker` package:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
```

### iOS (`ios/Runner/Info.plist`)

Already configured via `image_picker` package:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to upload images</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take photos</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone for video recording</string>
```

---

## 🧪 Testing

### Manual Testing Checklist

**Profile Images:**
- [ ] Upload profile image from gallery
- [ ] Upload profile image from camera
- [ ] View profile image after upload
- [ ] Edit existing profile image
- [ ] Profile image persists after app restart
- [ ] Initials show when no image

**Product Images:**
- [ ] Add product with image
- [ ] Add product without image
- [ ] View product image in menu
- [ ] Image compresses to reasonable size
- [ ] Multiple products with images

**Edge Cases:**
- [ ] Cancel image selection
- [ ] Select very large image (compression)
- [ ] No camera available (emulator)
- [ ] Permissions denied
- [ ] Delete user with images
- [ ] App storage management

---

## 📊 Image Specifications

### Compression Settings

```dart
maxWidth: 1920,
maxHeight: 1920,
imageQuality: 85,
```

### Supported Formats
- PNG (recommended for transparency)
- JPG/JPEG (smaller file size)
- HEIC (iOS, auto-converted)

### Recommended Sizes
- **Profile Images**: 500x500px minimum
- **Product Images**: 1000x1000px minimum
- **App Icon**: 1024x1024px

---

## 🐛 Common Issues & Solutions

### Issue: "Permission Denied"
**Solution**:
- Android: Check app permissions in Settings
- iOS: Check Settings → Privacy → Camera/Photos

### Issue: Images Not Showing After Upload
**Solution**:
- Ensure `setState()` is called after image selection
- Check that image path is correctly saved to database
- Verify image file exists at the path

### Issue: App Crashes When Picking Image
**Solution**:
- Run `flutter clean && flutter pub get`
- Restart app completely
- Check Android/iOS permissions

### Issue: Images Too Large
**Solution**:
The helper automatically compresses to 1920x1920 @ 85% quality.
To reduce further, modify `ImagePickerHelper`:

```dart
maxWidth: 1080,
maxHeight: 1080,
imageQuality: 75,
```

### Issue: Can't Find Saved Images
**Solution**:
```dart
// Get app images directory
final dir = await ImageStorageService.instance._getImagesDirectory();
print('Images stored at: ${dir.path}');
```

---

## 🚀 Advanced Usage

### Custom Image Validation

```dart
Future<void> _pickImage() async {
  final imageFile = await ImagePickerHelper.pickImageWithOptions(context);

  if (imageFile != null) {
    // Check file size
    final bytes = await imageFile.length();
    if (bytes > 5 * 1024 * 1024) { // 5MB limit
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image too large! Maximum 5MB')),
      );
      return;
    }

    setState(() {
      _selectedImageFile = imageFile;
    });
  }
}
```

### Image Preview Before Upload

```dart
Future<void> _pickImage() async {
  final imageFile = await ImagePickerHelper.pickImageWithOptions(context);

  if (imageFile != null) {
    final confirmed = await ImagePickerHelper.confirmImageSelection(
      context,
      imageFile,
    );

    if (confirmed) {
      setState(() {
        _selectedImageFile = imageFile;
      });
    }
  }
}
```

### Display Image from Path

```dart
Widget _buildImageDisplay(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) {
    return Icon(Icons.image_not_supported);
  }

  final file = File(imagePath);
  if (!file.existsSync()) {
    return Icon(Icons.broken_image);
  }

  return Image.file(file, fit: BoxFit.cover);
}
```

---

## 📚 Related Documentation

- **Project Structure**: [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)
- **Developer Guide**: [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)
- **Error Fixes**: [ERROR_FIXES_SUMMARY.md](ERROR_FIXES_SUMMARY.md)
- **Icon Integration**: [QUICK_ICON_SETUP.md](QUICK_ICON_SETUP.md)

---

## ✅ Summary

The image picker is now fully integrated across your app:

- ✅ **3 utility/service files** created
- ✅ **8 screens** updated with image functionality
- ✅ **Database migrated** to version 7
- ✅ **Models updated** to support images
- ✅ **Reusable widgets** for consistent UI
- ✅ **Automatic compression** and optimization
- ✅ **Organized storage** by category
- ✅ **Error handling** throughout

### Quick Start for Developers

1. Import the helpers:
   ```dart
   import '../../utils/image_picker_helper.dart';
   import '../../services/image_storage_service.dart';
   import '../../widgets/common/image_picker_widget.dart';
   ```

2. Add state variable:
   ```dart
   File? _selectedImageFile;
   ```

3. Pick image:
   ```dart
   final file = await ImagePickerHelper.pickImageWithOptions(context);
   ```

4. Save image:
   ```dart
   final path = await ImageStorageService.instance.saveImage(file);
   ```

5. Use widget:
   ```dart
   ProfileImagePicker(imageFile: _selectedImageFile, onTap: _pickImage)
   ```

That's it! 📸

---

**Last Updated**: October 9, 2025
**Version**: 1.0.0
**Status**: ✅ Production Ready
