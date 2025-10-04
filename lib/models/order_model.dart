import 'package:flutter/foundation.dart';

class Order {
  final String id;
  final String restaurant;
  final String date;
  final String description;
  final double price;
  final String status;
  final List<Map<String, dynamic>> items;
  final String customerName;
  final String deliveryAddress;
  final String phoneNumber;
  final String paymentMethod;

  Order({
    required this.id,
    required this.restaurant,
    required this.date,
    this.description = '',
    required this.price,
    required this.status,
    required this.items,
    this.customerName = 'John Doe',
    this.deliveryAddress = '123 Main Street, Apt 4B\nSan Francisco, CA 94105',
    this.phoneNumber = '+1 (555) 123-4567',
    this.paymentMethod = 'Credit Card',
  });
}

class OrdersModel extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get activeOrders {
    return _orders.where((order) => order.status != 'Delivered').toList();
  }

  List<Order> get pastOrders {
    return _orders.where((order) => order.status == 'Delivered').toList();
  }

  void addOrder({
    required List<Map<String, dynamic>> items,
    required double total,
    required String customerName,
    required String deliveryAddress,
    required String phoneNumber,
    required String paymentMethod,
  }) {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final orderDate = _formatDate(DateTime.now());

    // Get restaurant name from first item (in real app, this would be more sophisticated)
    final restaurant = 'Food Palace';

    final order = Order(
      id: orderId.substring(orderId.length - 5),
      restaurant: restaurant,
      date: orderDate,
      description: items.map((item) => item['name']).join(', '),
      price: total,
      status: 'Preparing',
      items: items,
      customerName: customerName,
      deliveryAddress: deliveryAddress,
      phoneNumber: phoneNumber,
      paymentMethod: paymentMethod,
    );

    _orders.insert(0, order);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final oldOrder = _orders[index];
      _orders[index] = Order(
        id: oldOrder.id,
        restaurant: oldOrder.restaurant,
        date: oldOrder.date,
        description: oldOrder.description,
        price: oldOrder.price,
        status: newStatus,
        items: oldOrder.items,
        customerName: oldOrder.customerName,
        deliveryAddress: oldOrder.deliveryAddress,
        phoneNumber: oldOrder.phoneNumber,
        paymentMethod: oldOrder.paymentMethod,
      );
      notifyListeners();
    }
  }

  String _formatDate(DateTime date) {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return '${days[date.weekday % 7]} ${months[date.month - 1]} ${date.day}';
  }
}
