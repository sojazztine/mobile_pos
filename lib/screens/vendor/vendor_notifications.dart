import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_model.dart';
import '../../services/database_service.dart';

class VendorNotifications extends StatefulWidget {
  const VendorNotifications({super.key});

  @override
  State<VendorNotifications> createState() => _VendorNotificationsState();
}

class _VendorNotificationsState extends State<VendorNotifications> {
  List<_Notification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
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

    // Generate notifications from recent orders
    final notifications = <_Notification>[];

    // New orders
    final newOrders = orders.where((o) => o.status == 'pending').toList();
    for (var order in newOrders.take(5)) {
      notifications.add(_Notification(
        title: 'New Order #${order.id}',
        message: 'You have received a new order from ${order.customerName}',
        time: _getTimeAgo(order.createdAt),
        icon: Icons.shopping_bag,
        iconColor: Colors.orange,
        isRead: false,
      ));
    }

    // Ready orders
    final readyOrders = orders.where((o) => o.status == 'ready').toList();
    for (var order in readyOrders.take(3)) {
      notifications.add(_Notification(
        title: 'Order Ready #${order.id}',
        message: 'Order for ${order.customerName} is ready for pickup',
        time: _getTimeAgo(order.createdAt),
        icon: Icons.check_circle,
        iconColor: Colors.green,
        isRead: false,
      ));
    }

    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
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
  Widget build(BuildContext context) {
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
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
              });
            },
            child: const Text(
              'Mark all as read',
              style: TextStyle(
                color: Colors.pink,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationItem(notification);
                  },
                ),
    );
  }

  Widget _buildNotificationItem(_Notification notification) {
    return Container(
      color: notification.isRead ? Colors.white : Colors.pink.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: notification.iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              notification.icon,
              color: notification.iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.pink,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Notification {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool isRead;

  _Notification({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });

  _Notification copyWith({
    String? title,
    String? message,
    String? time,
    IconData? icon,
    Color? iconColor,
    bool? isRead,
  }) {
    return _Notification(
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      isRead: isRead ?? this.isRead,
    );
  }
}
