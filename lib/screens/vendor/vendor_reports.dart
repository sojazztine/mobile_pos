import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_model.dart';
import '../../services/database_service.dart';
import 'vendor_menu_management.dart';
import 'vendor_orders.dart';
import 'vendor_profile.dart';

class VendorReports extends StatefulWidget {
  const VendorReports({super.key});

  @override
  State<VendorReports> createState() => _VendorReportsState();
}

class _VendorReportsState extends State<VendorReports> {
  String _selectedPeriod = 'Daily';
  bool _isLoading = true;
  double _totalRevenue = 0.0;
  double _avgOrderValue = 0.0;
  List<dynamic> _recentTransactions = [];
  List<dynamic> _allOrders = [];

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  Future<void> _loadReportsData() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    final vendorId = authModel.currentUser?.id;

    if (vendorId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final db = DatabaseService.instance;
    final orders = await db.getOrdersByVendor(vendorId);

    // Filter based on selected period
    final filteredOrders = _filterOrdersByPeriod(orders);

    final revenue = filteredOrders.fold<double>(0.0, (sum, order) => sum + order.price);
    final avgValue = filteredOrders.isNotEmpty ? revenue / filteredOrders.length : 0.0;
    final recent = filteredOrders.take(3).toList();

    setState(() {
      _allOrders = orders;
      _totalRevenue = revenue;
      _avgOrderValue = avgValue;
      _recentTransactions = recent;
      _isLoading = false;
    });
  }

  List<dynamic> _filterOrdersByPeriod(List<dynamic> orders) {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'Daily':
        return orders.where((order) {
          final orderDate = DateTime.parse(order.createdAt.toString());
          return orderDate.year == now.year &&
              orderDate.month == now.month &&
              orderDate.day == now.day;
        }).toList();
      case 'Weekly':
        final weekAgo = now.subtract(const Duration(days: 7));
        return orders.where((order) {
          final orderDate = DateTime.parse(order.createdAt.toString());
          return orderDate.isAfter(weekAgo);
        }).toList();
      case 'Monthly':
        return orders.where((order) {
          final orderDate = DateTime.parse(order.createdAt.toString());
          return orderDate.year == now.year && orderDate.month == now.month;
        }).toList();
      default:
        return orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Sales & Analytics',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadReportsData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Period Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildPeriodTab('Daily'),
                  const SizedBox(width: 12),
                  _buildPeriodTab('Weekly'),
                  const SizedBox(width: 12),
                  _buildPeriodTab('Monthly'),
                  const SizedBox(width: 12),
                  _buildPeriodTab('Custom'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Total Revenue Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Revenue',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_totalRevenue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _selectedPeriod,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Revenue Chart
            Container(
              height: 180,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: CustomPaint(
                      painter: _ChartPainter(),
                      child: Container(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('10AM', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      Text('12PM', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      Text('2PM', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      Text('4PM', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      Text('6PM', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Average Order Value Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Avg. Order Value',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_avgOrderValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _selectedPeriod,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Small Chart for Avg Order Value
            Container(
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: CustomPaint(
                painter: _SmallChartPainter(),
                child: Container(),
              ),
            ),

            const SizedBox(height: 12),

            // Time labels for small chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('10AM', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  Text('12PM', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  Text('2PM', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  Text('4PM', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  Text('6PM', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recent Transactions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.pink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Transaction List
            if (_recentTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              )
            else
              ..._recentTransactions.map((order) {
                return Column(
                  children: [
                    _buildTransaction(
                      order.customerName,
                      '#${order.id}',
                      '\$${order.price.toStringAsFixed(2)}',
                    ),
                    if (order != _recentTransactions.last) const Divider(height: 1),
                  ],
                );
              }).toList(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(String label) {
    final isSelected = _selectedPeriod == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = label;
          _loadReportsData(); // Reload data when period changes
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.pink : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTransaction(String customer, String orderId, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer: $customer',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Order $orderId',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

}

// Chart Painter for Revenue
class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pink.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Sample data points
    final points = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.4, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.1),
      Offset(size.width, size.height * 0.7),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Fill area under curve
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.pink.withOpacity(0.3),
          Colors.pink.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Small Chart Painter for Avg Order Value
class _SmallChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pink.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();

    final points = [
      Offset(0, size.height * 0.5),
      Offset(size.width * 0.25, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.4),
      Offset(size.width * 0.75, size.height * 0.7),
      Offset(size.width, size.height * 0.5),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
