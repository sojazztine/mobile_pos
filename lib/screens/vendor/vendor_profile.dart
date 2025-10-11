import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_model.dart';
import '../common/home.dart';
import 'vendor_menu_management.dart';
import 'vendor_orders.dart';
import 'vendor_reports.dart';
import 'vendor_store_settings.dart';
import '../../utils/image_picker_helper.dart';
import '../../services/image_storage_service.dart';
import '../../widgets/common/image_picker_widget.dart';
import '../../services/database_service.dart';

class VendorProfile extends StatefulWidget {
  const VendorProfile({super.key});

  @override
  State<VendorProfile> createState() => _VendorProfileState();
}

class _VendorProfileState extends State<VendorProfile> {
  File? _selectedImageFile;

  String _getInitials(String fullName) {
    final names = fullName.trim().split(' ');
    if (names.isEmpty) return 'V';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  Future<void> _pickProfileImage() async {
    final imageFile = await ImagePickerHelper.pickImageWithOptions(context);
    if (imageFile != null) {
      setState(() {
        _selectedImageFile = imageFile;
      });

      // Save the image and update user profile
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
    final vendorName = user?.fullName ?? 'Sophia Chen';
    final userInitials = _getInitials(vendorName);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile & Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Profile Avatar & Name
            ProfileImagePicker(
              imageFile: _selectedImageFile,
              imageUrl: user?.profileImage,
              userName: vendorName,
              onTap: _pickProfileImage,
              size: 100,
            ),
            const SizedBox(height: 16),
            Text(
              vendorName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Owner',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 32),

            // Store Information Section
            _buildSectionHeader('STORE INFORMATION'),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.store,
              title: 'Store Settings',
              subtitle: 'Edit store information',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VendorStoreSettings(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Banking Section
            _buildSectionHeader('BANKING'),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.account_balance,
              title: 'Bank Details',
              subtitle: 'Bank of America',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // App Settings Section
            _buildSectionHeader('APP SETTINGS'),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: null,
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.lock_outlined,
              title: 'Change Password',
              subtitle: null,
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // Support & Legal Section
            _buildSectionHeader('SUPPORT & LEGAL'),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Customer Support',
              subtitle: null,
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              subtitle: null,
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: null,
              onTap: () {},
            ),

            const SizedBox(height: 32),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await authModel.logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Home()),
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
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: Colors.white,
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
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
