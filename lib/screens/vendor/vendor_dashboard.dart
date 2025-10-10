import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_model.dart';
import '../common/home.dart';
import 'vendor_add_product.dart';
import 'vendor_menu_management.dart';
import 'vendor_orders.dart';
import 'vendor_reports.dart';
import 'vendor_profile.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  int _selectedIndex = 0;
  String _selectedPeriod = 'Today';

  String _getInitials(String fullName) {
    final names = fullName.trim().split(' ');
    if (names.isEmpty) return 'V';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context);
    final user = authModel.currentUser;
    final vendorName = user?.fullName ?? 'The Burger House';
    final userInitials = _getInitials(vendorName);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back,',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              vendorName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context, authModel, vendorName, userInitials),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildTopStatCard(
                    icon: Icons.shopping_bag_outlined,
                    iconColor: Colors.orange[700]!,
                    iconBgColor: Colors.orange[50]!,
                    value: '5',
                    label: 'New Orders',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTopStatCard(
                    icon: Icons.inventory_outlined,
                    iconColor: Colors.red[700]!,
                    iconBgColor: Colors.red[50]!,
                    value: '2',
                    label: 'Low Stock',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTopStatCard(
                    icon: Icons.attach_money,
                    iconColor: Colors.green[700]!,
                    iconBgColor: Colors.green[50]!,
                    value: '\$1.2K',
                    label: 'Revenue',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Order Summary
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Order Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildOrderStatusItem('5', 'New'),
                      _buildOrderStatusItem('8', 'Preparing'),
                      _buildOrderStatusItem('3', 'Ready'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // View All Orders Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to all orders
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'View All Orders',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sales Performance
            const Text(
              'Sales Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Hourly Sales Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hourly Sales',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    _buildPeriodChip('Today', _selectedPeriod == 'Today'),
                    const SizedBox(width: 8),
                    _buildPeriodChip('Week', _selectedPeriod == 'Week'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sales Chart Placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Sales chart would be displayed here',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Peak Times Info
            Center(
              child: Text(
                'Peak times are 12-1pm and 6-7pm.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (_selectedIndex == index) return;

          Widget destination;
          switch (index) {
            case 0:
              destination = const VendorDashboard();
              break;
            case 1:
              destination = const VendorMenuManagement();
              break;
            case 2:
              destination = const VendorOrders();
              break;
            case 3:
              destination = const VendorReports();
              break;
            case 4:
              destination = const VendorProfile();
              break;
            default:
              return;
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => destination),
            (route) => false,
          );
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.pink : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthModel authModel, String vendorName, String userInitials) {
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
                    child: Text(
                      userInitials,
                      style: TextStyle(
                        color: Colors.pink[700],
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vendorName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VendorProfile(),
                        ),
                      );
                    },
                    child: Text(
                      authModel.currentUser?.email ?? 'View Profile',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
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
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    isSelected: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.restaurant_menu,
                    title: 'Menu',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VendorMenuManagement(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.shopping_cart_outlined,
                    title: 'Orders',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VendorOrders(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Reports',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VendorReports(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VendorProfile(),
                        ),
                      );
                    },
                  ),
                
                ],
              ),
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  await authModel.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                      (route) => false,
                    );
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.black54, size: 22),
                    const SizedBox(width: 16),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {
    required IconData icon,
    required String title,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFCE4EC) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.pink : Colors.black54,
            size: 22,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              color: isSelected ? Colors.pink : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
