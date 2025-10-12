import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_model.dart';
import '../../models/order_model.dart';
import '../../services/database_service.dart';

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
  int _totalOrders = 0;
  int _completedOrders = 0;
  List<Order> _recentTransactions = [];
  Map<String, dynamic> _productSales = {};

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  Future<void> _loadReportsData() async {
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
    final ordersRaw = await db.getOrdersByVendor(vendorId);
    final orders = ordersRaw.cast<Order>();

    // Filter based on selected period
    final filteredOrders = _filterOrdersByPeriod(orders);

    // Calculate revenue and metrics
    final revenue = filteredOrders.fold<double>(
      0.0,
      (sum, order) => sum + (order.status == 'completed' ? order.price : 0.0)
    );
    final completed = filteredOrders.where((o) => o.status == 'completed').length;
    final avgValue = completed > 0 ? revenue / completed : 0.0;
    final recent = filteredOrders.take(10).toList();

    // Calculate product-level sales
    final productSales = <String, Map<String, dynamic>>{};
    for (var order in filteredOrders) {
      if (order.status == 'completed') {
        for (var item in order.items) {
          final productName = item['name'] as String? ?? 'Unknown';
          final quantity = item['quantity'] as int? ?? 0;
          final price = item['price'] as double? ?? 0.0;
          final totalPrice = price * quantity;

          if (productSales.containsKey(productName)) {
            productSales[productName]!['quantity'] += quantity;
            productSales[productName]!['revenue'] += totalPrice;
          } else {
            productSales[productName] = {
              'quantity': quantity,
              'revenue': totalPrice,
              'price': price,
            };
          }
        }
      }
    }

    // Sort by revenue
    final sortedProducts = productSales.entries.toList()
      ..sort((a, b) => (b.value['revenue'] as double).compareTo(a.value['revenue'] as double));

    setState(() {
      _totalRevenue = revenue;
      _avgOrderValue = avgValue;
      _totalOrders = filteredOrders.length;
      _completedOrders = completed;
      _recentTransactions = recent;
      _productSales = Map.fromEntries(sortedProducts.take(5));
      _isLoading = false;
    });
  }

  List<Order> _filterOrdersByPeriod(List<Order> orders) {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'Daily':
        return orders.where((order) {
          final orderDate = order.createdAt;
          return orderDate.year == now.year &&
              orderDate.month == now.month &&
              orderDate.day == now.day;
        }).toList();
      case 'Weekly':
        final weekAgo = now.subtract(const Duration(days: 7));
        return orders.where((order) {
          final orderDate = order.createdAt;
          return orderDate.isAfter(weekAgo);
        }).toList();
      case 'Monthly':
        return orders.where((order) {
          final orderDate = order.createdAt;
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

            // Stats Cards Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Revenue',
                      '\$${_totalRevenue.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Orders',
                      '$_totalOrders',
                      Icons.shopping_bag,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Completed',
                      '$_completedOrders',
                      Icons.check_circle,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Avg. Order',
                      '\$${_avgOrderValue.toStringAsFixed(2)}',
                      Icons.trending_up,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

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

            // Top Selling Products Section
            if (_productSales.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Top Selling Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _selectedPeriod,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (var entry in _productSales.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: _buildProductSalesCard(
                    entry.key,
                    entry.value['quantity'] as int,
                    entry.value['revenue'] as double,
                  ),
                ),
              const SizedBox(height: 24),
            ],

            // Recent Transactions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${_recentTransactions.length} orders',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Transaction List
            if (_recentTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Orders will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              for (var order in _recentTransactions)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: _buildTransactionCard(order),
                ),

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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSalesCard(String productName, int quantity, double revenue) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fastfood, color: Colors.pink, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$quantity sold',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${revenue.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Order order) {
    final statusColor = _getStatusColor(order.status);
    final timeAgo = _getTimeAgo(order.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.receipt, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '\$${order.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.customerName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusLabel(order.status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'delivering':
        return Colors.blue;
      case 'preparing':
      case 'ready':
        return Colors.orange;
      case 'pending':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

}

// Chart Painter for Revenue
class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pink.withValues(alpha: 0.3)
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
          Colors.pink.withValues(alpha: 0.3),
          Colors.pink.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
