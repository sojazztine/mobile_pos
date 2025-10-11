import 'package:flutter/foundation.dart';
import 'dart:convert';

class Order {
  final int? id;
  final int userId;
  final int vendorId;
  final int? riderId;
  final String restaurant;
  final String date;
  final String description;
  final double price;
  final String status; // 'pending', 'accepted', 'preparing', 'ready', 'delivering', 'completed', 'cancelled'
  final List<Map<String, dynamic>> items; // [{productId, name, quantity, price}]
  final String customerName;
  final String deliveryAddress;
  final String phoneNumber;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  Order({
    this.id,
    required this.userId,
    required this.vendorId,
    this.riderId,
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
    DateTime? createdAt,
    this.acceptedAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Order to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'vendorId': vendorId,
      'riderId': riderId,
      'restaurant': restaurant,
      'date': date,
      'description': description,
      'price': price,
      'status': status,
      'items': items.toString(), // Store as string representation for now
      'customerName': customerName,
      'deliveryAddress': deliveryAddress,
      'phoneNumber': phoneNumber,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // Create Order from Map
  factory Order.fromMap(Map<String, dynamic> map) {
    // Parse items string back to List<Map<String, dynamic>>
    List<Map<String, dynamic>> parseItems(String itemsStr) {
      try {
        // Try JSON decode first
        final List<dynamic> itemsList = jsonDecode(itemsStr);
        return itemsList.cast<Map<String, dynamic>>();
      } catch (e) {
        // If JSON decode fails, return empty list for now
        print('Error parsing items JSON: $e');
        return [];
      }
    }

    return Order(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      vendorId: map['vendorId'] as int,
      riderId: map['riderId'] as int?,
      restaurant: map['restaurant'] as String,
      date: map['date'] as String,
      description: map['description'] as String? ?? '',
      price: map['price'] as double,
      status: map['status'] as String,
      items: parseItems(map['items'] as String),
      customerName: map['customerName'] as String? ?? 'John Doe',
      deliveryAddress: map['deliveryAddress'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      paymentMethod: map['paymentMethod'] as String? ?? 'Credit Card',
      createdAt: DateTime.parse(map['createdAt'] as String),
      acceptedAt: map['acceptedAt'] != null ? DateTime.parse(map['acceptedAt'] as String) : null,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt'] as String) : null,
    );
  }

  // Create a copy with updated fields
  Order copyWith({
    int? id,
    int? userId,
    int? vendorId,
    int? riderId,
    String? restaurant,
    String? date,
    String? description,
    double? price,
    String? status,
    List<Map<String, dynamic>>? items,
    String? customerName,
    String? deliveryAddress,
    String? phoneNumber,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vendorId: vendorId ?? this.vendorId,
      riderId: riderId ?? this.riderId,
      restaurant: restaurant ?? this.restaurant,
      date: date ?? this.date,
      description: description ?? this.description,
      price: price ?? this.price,
      status: status ?? this.status,
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class OrdersModel extends ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get activeOrders {
    return _orders.where((order) => order.status != 'completed' && order.status != 'cancelled').toList();
  }

  List<Order> get pastOrders {
    return _orders.where((order) => order.status == 'completed' || order.status == 'cancelled').toList();
  }

  List<Order> get allOrders => _orders;

  void setOrders(List<Order> orders) {
    _orders = orders;
    notifyListeners();
  }

  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void updateOrder(Order updatedOrder) {
    final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
      notifyListeners();
    }
  }

  void removeOrder(int orderId) {
    _orders.removeWhere((order) => order.id == orderId);
    notifyListeners();
  }

}
