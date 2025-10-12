import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_model.dart';
import '../common/main_navigation.dart';

class RiderSettings extends StatelessWidget {
  const RiderSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preferences Section
              const Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Notifications
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                iconColor: Colors.pink,
                iconBgColor: Colors.pink[50]!,
                title: 'Notifications',
                subtitle: 'On',
                onTap: () {
                  // Navigate to notifications settings
                },
              ),
              const SizedBox(height: 12),

              // Sound
              _buildSettingItem(
                icon: Icons.volume_up_outlined,
                iconColor: Colors.pink,
                iconBgColor: Colors.pink[50]!,
                title: 'Sound',
                subtitle: 'Default',
                onTap: () {
                  // Navigate to sound settings
                },
              ),
              const SizedBox(height: 12),

              // Map
              _buildSettingItem(
                icon: Icons.map_outlined,
                iconColor: Colors.pink,
                iconBgColor: Colors.pink[50]!,
                title: 'Map',
                subtitle: 'Default Maps',
                onTap: () {
                  // Navigate to map settings
                },
              ),
              const SizedBox(height: 12),

              // Language
              _buildSettingItem(
                icon: Icons.language,
                iconColor: Colors.pink,
                iconBgColor: Colors.pink[50]!,
                title: 'Language',
                subtitle: 'English',
                onTap: () {
                  // Navigate to language settings
                },
              ),
              const SizedBox(height: 24),

              // General Section
              const Text(
                'General',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // App Version
              _buildInfoItem(
                title: 'App Version',
                trailing: 'v2.2.3',
              ),
              const SizedBox(height: 12),

              // Privacy Policy
              _buildSettingItem(
                icon: null,
                iconColor: Colors.black,
                iconBgColor: Colors.transparent,
                title: 'Privacy Policy',
                subtitle: null,
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
              const SizedBox(height: 12),

              // Support Center
              _buildSettingItem(
                icon: null,
                iconColor: Colors.black,
                iconBgColor: Colors.transparent,
                title: 'Support Center',
                subtitle: null,
                onTap: () {
                  // Navigate to support center
                },
              ),
              const SizedBox(height: 32),

              // Log Out Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[50],
                    foregroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
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

  Widget _buildSettingItem({
    required IconData? icon,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon (if provided)
            if (icon != null) ...[
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
            ],
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

  Widget _buildInfoItem({
    required String title,
    required String trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            trailing,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

}
