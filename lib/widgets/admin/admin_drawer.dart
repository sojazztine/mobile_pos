import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../models/auth_model.dart';
import '../../screens/admin/admin_dashboard.dart';
import '../../screens/admin/admin_sales.dart';
import '../../screens/admin/admin_products.dart';
import '../../screens/admin/admin_vendor_users.dart';
import '../../screens/admin/admin_riders.dart';
import '../../screens/admin/admin_settings.dart';
import '../../screens/common/home.dart';

class AdminDrawer extends StatelessWidget {
  final String currentPage;

  const AdminDrawer({
    super.key,
    required this.currentPage,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return 'A';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(
      builder: (context, authModel, child) {
        final user = authModel.currentUser;

        return Drawer(
          backgroundColor: const Color(0xFFF5F5F5),
          child: SafeArea(
            child: Column(
              children: [
                // Profile Section
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.pink[100],
                        backgroundImage: user?.profileImage != null
                            ? FileImage(File(user!.profileImage!))
                            : null,
                        child: user?.profileImage == null
                            ? Text(
                                _getInitials(user?.fullName ?? 'Admin'),
                                style: TextStyle(
                                  color: Colors.pink[700],
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.fullName ?? 'Admin',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'admin@codecrave.com',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pink[700],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'ADMIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(
                        context,
                        icon: Icons.home,
                        label: 'Dashboard',
                        isSelected: currentPage == 'Dashboard',
                        onTap: () {
                          Navigator.pop(context);
                          if (currentPage != 'Dashboard') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminDashboard(),
                              ),
                            );
                          }
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.bar_chart_outlined,
                        label: 'Sales',
                        isSelected: currentPage == 'Sales',
                        onTap: () {
                          Navigator.pop(context);
                          if (currentPage != 'Sales') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminSales(),
                              ),
                            );
                          }
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.inventory_2_outlined,
                        label: 'Products',
                        isSelected: currentPage == 'Products',
                        onTap: () {
                          Navigator.pop(context);
                          if (currentPage != 'Products') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminProducts(),
                              ),
                            );
                          }
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.people_outline,
                        label: 'Vendors',
                        isSelected: currentPage == 'Vendors',
                        onTap: () {
                          Navigator.pop(context);
                          if (currentPage != 'Vendors') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminVendorUsers(),
                              ),
                            );
                          }
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.delivery_dining_outlined,
                        label: 'Riders',
                        isSelected: currentPage == 'Riders',
                        onTap: () {
                          Navigator.pop(context);
                          if (currentPage != 'Riders') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminRiders(),
                              ),
                            );
                          }
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        isSelected: currentPage == 'Settings',
                        onTap: () {
                          Navigator.pop(context);
                          if (currentPage != 'Settings') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminSettings(),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: () async {
                      // Store the navigator before showing dialog
                      final navigator = Navigator.of(context);

                      // Close drawer first
                      navigator.pop();

                      // Show confirmation dialog
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, false);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, true);
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      // If user confirmed logout
                      if (shouldLogout == true) {
                        await authModel.logout();

                        // Navigate to home and clear all routes
                        navigator.pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const Home(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.pink[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.pink : Colors.grey[700],
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.pink : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
