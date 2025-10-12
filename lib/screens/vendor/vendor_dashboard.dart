import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_model.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
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
  List<Order> _orders = [];
  List<Product> _products = [];
  bool _isLoading = true;
  int _newOrdersCount = 0;
  int _lowStockCount = 0;
  int _outOfStockCount = 0;
  int _totalProducts = 0;
  int _activeProducts = 0;
  double _todayRevenue = 0.0;
  double _weekRevenue = 0.0;
  double _monthRevenue = 0.0;
  int _todayOrders = 0;
  int _completedOrders = 0;
  Map<String, int> _topProducts = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

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
    final ordersRaw = await db.getOrdersByVendor(vendorId);
    final orders = ordersRaw.cast<Order>();
    final products = await db.getProductsByVendor(vendorId);

    // Calculate date ranges
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthStart = DateTime(now.year, now.month, 1);

    // Filter orders by time period
    final todayOrdersList = orders.where((order) {
      final orderDate = order.createdAt;
      return orderDate.year == today.year &&
          orderDate.month == today.month &&
          orderDate.day == today.day;
    }).toList();

    final weekOrders = orders.where((order) {
      return order.createdAt.isAfter(weekAgo);
    }).toList();

    final monthOrders = orders.where((order) {
      return order.createdAt.isAfter(monthStart);
    }).toList();

    // Calculate revenue (only completed orders)
    final todayRev = todayOrdersList
        .where((o) => o.status == 'completed')
        .fold<double>(0.0, (sum, order) => sum + order.price);

    final weekRev = weekOrders
        .where((o) => o.status == 'completed')
        .fold<double>(0.0, (sum, order) => sum + order.price);

    final monthRev = monthOrders
        .where((o) => o.status == 'completed')
        .fold<double>(0.0, (sum, order) => sum + order.price);

    // Calculate order counts
    final newOrders = orders.where((o) => o.status == 'pending').length;
    final completed = orders.where((o) => o.status == 'completed').length;

    // Calculate product statistics
    final lowStock = products.where((p) => p.stockQuantity > 0 && p.stockQuantity < 10).length;
    final outOfStock = products.where((p) => p.stockQuantity == 0).length;
    final activeProds = products.where((p) => p.isActive).length;

    // Calculate top selling products
    final productSales = <String, int>{};
    for (var order in orders) {
      if (order.status == 'completed') {
        for (var item in order.items) {
          final productName = item['name'] as String? ?? 'Unknown';
          final quantity = item['quantity'] as int? ?? 0;
          productSales[productName] = (productSales[productName] ?? 0) + quantity;
        }
      }
    }

    // Sort and get top 3 products
    final sortedProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topProds = Map.fromEntries(sortedProducts.take(3));

    setState(() {
      _orders = orders;
      _products = products;
      _newOrdersCount = newOrders;
      _lowStockCount = lowStock;
      _outOfStockCount = outOfStock;
      _totalProducts = products.length;
      _activeProducts = activeProds;
      _todayRevenue = todayRev;
      _weekRevenue = weekRev;
      _monthRevenue = monthRev;
      _todayOrders = todayOrdersList.length;
      _completedOrders = completed;
      _topProducts = topProds;
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
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
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

            // Product Summary Section
            const Text(
              'Product Summary',
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildProductStatItem(
                          'Total Products',
                          '$_totalProducts',
                          Icons.inventory_2_outlined,
                          Colors.blue,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.grey[200],
                      ),
                      Expanded(
                        child: _buildProductStatItem(
                          'Active',
                          '$_activeProducts',
                          Icons.check_circle_outline,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: Colors.grey[200]),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildProductStatItem(
                          'Low Stock',
                          '$_lowStockCount',
                          Icons.warning_outlined,
                          Colors.orange,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.grey[200],
                      ),
                      Expanded(
                        child: _buildProductStatItem(
                          'Out of Stock',
                          '$_outOfStockCount',
                          Icons.remove_circle_outline,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Top Selling Products
            if (_topProducts.isNotEmpty) ...[
              const Text(
                'Top Selling Products',
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < _topProducts.entries.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i < _topProducts.entries.length - 1 ? 16 : 0,
                        ),
                        child: _buildTopProductItem(
                          i + 1,
                          _topProducts.entries.elementAt(i).key,
                          _topProducts.entries.elementAt(i).value,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

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

            // Revenue Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildRevenueCard(
                    'Today',
                    '\$${_todayRevenue.toStringAsFixed(2)}',
                    '$_todayOrders orders',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRevenueCard(
                    'This Week',
                    '\$${_weekRevenue.toStringAsFixed(2)}',
                    '',
                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Month revenue card
            _buildRevenueCard(
              'This Month',
              '\$${_monthRevenue.toStringAsFixed(2)}',
              '$_completedOrders completed orders',
              Colors.purple,
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

  Widget _buildProductStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTopProductItem(int rank, String productName, int quantity) {
    final rankColors = [Colors.amber, Colors.grey, Colors.brown];
    final rankColor = rank <= 3 ? rankColors[rank - 1] : Colors.grey;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: rankColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: rankColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            productName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.pink.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$quantity sold',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.pink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueCard(String period, String amount, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.8),
            color,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                period,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.trending_up,
                color: Colors.white.withValues(alpha: 0.9),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
