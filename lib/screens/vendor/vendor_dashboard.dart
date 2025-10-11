import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_model.dart';
import '../../services/database_service.dart';
import 'vendor_menu_management.dart';
import 'vendor_orders.dart';
import 'vendor_reports.dart';
import 'vendor_profile.dart';
import 'vendor_notifications.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  int _selectedIndex = 0;
  String _selectedPeriod = 'Today';
  List<dynamic> _orders = [];
  List<dynamic> _products = [];
  bool _isLoading = true;
  int _newOrdersCount = 0;
  int _lowStockCount = 0;
  double _todayRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    final vendorId = authModel.currentUser?.id;

    if (vendorId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final db = DatabaseService.instance;

    // Load orders and products
    final orders = await db.getOrdersByVendor(vendorId);
    final products = await db.getProductsByVendor(vendorId);

    // Calculate statistics
    final today = DateTime.now();
    final todayOrders = orders.where((order) {
      final orderDate = DateTime.parse(order.createdAt.toString());
      return orderDate.year == today.year &&
          orderDate.month == today.month &&
          orderDate.day == today.day;
    }).toList();

    final newOrders = orders.where((o) => o.status == 'pending').length;
    final lowStock = products.where((p) => p.stockQuantity < 10).length;
    final revenue = todayOrders.fold<double>(0.0, (sum, order) => sum + order.price);

    setState(() {
      _orders = orders;
      _products = products;
      _newOrdersCount = newOrders;
      _lowStockCount = lowStock;
      _todayRevenue = revenue;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context);
    final user = authModel.currentUser;
    final vendorName = user?.fullName ?? 'The Burger House';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VendorNotifications(),
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardContent(vendorName),
          const VendorMenuManagement(),
          const VendorOrders(),
          const VendorReports(),
          const VendorProfile(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDashboardContent(String vendorName) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final preparingCount = _orders.where((o) => o.status == 'accepted' || o.status == 'preparing').length;
    final readyCount = _orders.where((o) => o.status == 'ready').length;

    return SingleChildScrollView(
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
                    value: '$_newOrdersCount',
                    label: 'New Orders',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTopStatCard(
                    icon: Icons.inventory_outlined,
                    iconColor: Colors.red[700]!,
                    iconBgColor: Colors.red[50]!,
                    value: '$_lowStockCount',
                    label: 'Low Stock',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTopStatCard(
                    icon: Icons.attach_money,
                    iconColor: Colors.green[700]!,
                    iconBgColor: Colors.green[50]!,
                    value: '\$${_todayRevenue.toStringAsFixed(0)}',
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
                      _buildOrderStatusItem('$_newOrdersCount', 'New'),
                      _buildOrderStatusItem('$preparingCount', 'Preparing'),
                      _buildOrderStatusItem('$readyCount', 'Ready'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // View All Orders Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 2; // Navigate to orders tab
                        });
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
      );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Reload dashboard data when returning to dashboard
          if (index == 0) {
            _loadDashboardData();
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        backgroundColor: Colors.white,
        elevation: 8,
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
}
