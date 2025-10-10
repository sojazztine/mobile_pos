import 'package:flutter/material.dart';
import '../../screens/admin/admin_dashboard.dart';
import '../../screens/admin/admin_sales.dart';
import '../../screens/admin/admin_products.dart';
import '../../screens/admin/admin_vendor_users.dart';
import '../../screens/admin/admin_riders.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                Icons.home,
                'Dashboard',
                0,
                () {
                  if (currentIndex != 0) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminDashboard(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
              _buildNavItem(
                context,
                Icons.bar_chart_outlined,
                'Sales',
                1,
                () {
                  if (currentIndex != 1) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminSales(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
              _buildNavItem(
                context,
                Icons.inventory_2_outlined,
                'Products',
                2,
                () {
                  if (currentIndex != 2) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminProducts(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
              _buildNavItem(
                context,
                Icons.people_outline,
                'Vendors',
                3,
                () {
                  if (currentIndex != 3) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminVendorUsers(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
              _buildNavItem(
                context,
                Icons.delivery_dining,
                'Riders',
                4,
                () {
                  if (currentIndex != 4) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminRiders(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    VoidCallback onTap,
  ) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.pink : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.pink : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
