import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_model.dart';
import '../common/main_navigation.dart';
import '../../utils/image_picker_helper.dart';
import '../../services/image_storage_service.dart';
import '../../widgets/common/image_picker_widget.dart';
import '../../services/database_service.dart';

class RiderProfile extends StatefulWidget {
  const RiderProfile({super.key});

  @override
  State<RiderProfile> createState() => _RiderProfileState();
}

class _RiderProfileState extends State<RiderProfile> {
  File? _selectedImageFile;


  Future<void> _pickProfileImage() async {
    final imageFile = await ImagePickerHelper.pickImageWithOptions(context);
    if (imageFile != null) {
      setState(() {
        _selectedImageFile = imageFile;
      });

      // Save the image and update user profile
      if (!mounted) return;
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final user = authModel.currentUser;
      if (user != null && user.id != null) {
        final savedImagePath = await ImageStorageService.instance.saveProfileImage(
          imageFile,
          user.id!,
        );

        if (savedImagePath != null) {
          // Update user profile in database
          final updatedUser = user.copyWith(profileImage: savedImagePath);
          await DatabaseService.instance.updateUser(updatedUser);
          await authModel.updateCurrentUser(updatedUser);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile image updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context);
    final user = authModel.currentUser;
    final userName = user?.fullName ?? 'Rider';
    final riderId = user?.id?.toString() ?? '123456';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Profile Avatar with Initials
              ProfileImagePicker(
                imageFile: _selectedImageFile,
                imageUrl: user?.profileImage,
                userName: userName,
                onTap: _pickProfileImage,
                size: 80,
              ),
              const SizedBox(height: 16),

              // User Name
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),

              // Rider ID
              Text(
                'Rider ID: $riderId',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Account Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Personal Details
              _buildMenuItem(
                icon: Icons.person_outline,
                iconColor: Colors.pink,
                iconBgColor: Colors.pink[50]!,
                title: 'Personal Details',
                subtitle: 'Your name & contact info',
                onTap: () {
                  // Navigate to personal details
                },
              ),
              const SizedBox(height: 12),

              // Vehicle Information
              _buildMenuItem(
                icon: Icons.motorcycle,
                iconColor: Colors.pink,
                iconBgColor: Colors.pink[50]!,
                title: 'Vehicle Information',
                subtitle: 'Motorcycle - Honda Wave',
                onTap: () {
                  // Navigate to vehicle info
                },
              ),
              const SizedBox(height: 12),

              // Payment Methods
              _buildMenuItem(
                icon: Icons.credit_card,
                iconColor: Colors.pink,
                iconBgColor: Colors.pink[50]!,
                title: 'Payment Methods',
                subtitle: 'Visa **** 1234',
                onTap: () {
                  // Navigate to payment methods
                },
              ),
              const SizedBox(height: 24),

              // More Options Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'More Options',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Performance
              _buildMenuItem(
                icon: Icons.trending_up,
                iconColor: Colors.pink,
                iconBgColor: Colors.pink[50]!,
                title: 'Performance',
                subtitle: null,
                onTap: () {
                  // Navigate to performance
                },
              ),
              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await authModel.logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainNavigation()),
                        (route) => false,
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

}
