import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_model.dart';
import '../../models/order_model.dart';
import '../../services/database_service.dart';
import 'vendor_order_details.dart';

class VendorOrders extends StatefulWidget {
  const VendorOrders({super.key});

  @override
  State<VendorOrders> createState() => _VendorOrdersState();
}

class _VendorOrdersState extends State<VendorOrders> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Order> _allOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
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

    setState(() {
      _allOrders = orders;
      _isLoading = false;
    });
  }

  List<Order> _getOrdersByStatus(String status) {
    if (status == 'new') {
      return _allOrders.where((o) => o.status == 'pending').toList();
    } else if (status == 'in_progress') {
      return _allOrders.where((o) => o.status == 'accepted' || o.status == 'preparing').toList();
    } else if (status == 'ready') {
      return _allOrders.where((o) => o.status == 'ready').toList();
    } else {
      return _allOrders.where((o) => o.status == 'completed' || o.status == 'cancelled').toList();
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newOrders = _getOrdersByStatus('new');
    final inProgressOrders = _getOrdersByStatus('in_progress');
    final readyOrders = _getOrdersByStatus('ready');
    final completedOrders = _getOrdersByStatus('completed');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Orders',
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
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Tabs
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black54,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('New'),
                            if (newOrders.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.pink,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${newOrders.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Tab(text: 'Preparing (${inProgressOrders.length})'),
                      Tab(text: 'Ready (${readyOrders.length})'),
                      Tab(text: 'Completed (${completedOrders.length})'),
                    ],
                  ),
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrderList(newOrders),
                      _buildOrderList(inProgressOrders),
                      _buildOrderList(readyOrders),
                      _buildOrderList(completedOrders),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    final itemCount = order.items.fold<int>(0, (sum, item) => sum + (item['quantity'] as int? ?? 0));
    final avatar = order.customerName.isNotEmpty ? order.customerName[0].toUpperCase() : 'C';

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorOrderDetails(order: order),
          ),
        );

        // Reload orders if status was updated
        if (result == true) {
          _loadOrders();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Customer Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.orange[100],
                  child: Text(
                    avatar,
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Order Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer: ${order.customerName}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Order #${order.id} • ${order.items.length} items • \$${order.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTimeAgo(order.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }

}
