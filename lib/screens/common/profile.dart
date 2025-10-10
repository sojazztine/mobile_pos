import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../widgets/auth/login_modal.dart';
import '../../models/auth_model.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _getInitials(String name) {
    if (name.isEmpty) return 'G';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  void _navigateToManageAccount(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context, listen: false);

    if (!authModel.isLoggedIn) {
      // Show login modal if not logged in
      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LoginModal(),
      );
      return;
    }

    // Navigate to edit profile screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoginModal(),
    );
  }

  void _navigateToPayment(BuildContext context) {
    // TODO: Navigate to payment methods screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Payment Methods')),
    );
  }

  void _navigateToAddress(BuildContext context) {
    // TODO: Navigate to address screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Address')),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    // TODO: Navigate to notifications settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Notifications')),
    );
  }

  void _getHelp(BuildContext context) {
    // TODO: Navigate to help screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Help Center')),
    );
  }

  void _giftCard(BuildContext context) {
    // TODO: Navigate to gift card screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Gift Cards')),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final authModel = Provider.of<AuthModel>(context, listen: false);
              await authModel.logout();

              if (!context.mounted) return;

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(
      builder: (context, authModel, child) {
        final user = authModel.currentUser;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20.0,
              MediaQuery.of(context).padding.top + 20.0,
              20.0,
              20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Avatar and Name with Edit/Login Button
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.pink[100],
                      backgroundImage: user?.profileImage != null
                          ? FileImage(File(user!.profileImage!))
                          : null,
                      child: user?.profileImage == null
                          ? Text(
                              _getInitials(user?.fullName ?? 'Guest User'),
                              style: TextStyle(
                                color: Colors.pink[700],
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Guest User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'Not logged in',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (authModel.isLoggedIn)
                      IconButton(
                        onPressed: () => _navigateToManageAccount(context),
                        icon: const Icon(Icons.edit, color: Colors.pink),
                      )
                    else
                      ElevatedButton(
                        onPressed: () => _showLoginPrompt(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // Profile Title
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Get Help and Gift Card Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.chat_bubble_outline,
                        label: 'Get Help',
                        onTap: () => _getHelp(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.card_giftcard,
                        label: 'Gift Card',
                        onTap: () => _giftCard(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Account Settings Section
                const Text(
                  'Account Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Settings Menu Items
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        title: 'Manage Account',
                        subtitle: 'Update information and manage your account',
                        onTap: () => _navigateToManageAccount(context),
                      ),
                      const Divider(height: 1),
                      _buildMenuItem(
                        title: 'Payment',
                        subtitle: 'Manage payment methods and credits',
                        onTap: () => _navigateToPayment(context),
                      ),
                      const Divider(height: 1),
                      _buildMenuItem(
                        title: 'Address',
                        subtitle: 'Add or remove a delivery address',
                        onTap: () => _navigateToAddress(context),
                      ),
                      const Divider(height: 1),
                      _buildMenuItem(
                        title: 'Notifications',
                        subtitle: 'Manage delivery and promotional notifications',
                        onTap: () => _navigateToNotifications(context),
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Log Out Button (only show if logged in)
                if (authModel.isLoggedIn)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _logout(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.pink,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: title == 'Manage Account' ? const Radius.circular(12) : Radius.zero,
        bottom: isLast ? const Radius.circular(12) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
