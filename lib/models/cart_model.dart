import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String imageType;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    required this.imageType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': imageType,
    };
  }
}

class CartModel extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return _items.values.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get deliveryFee => 2.00;
  double get taxes => subtotal * 0.08; // 8% tax
  double _discount = 0.0;

  double get discount => _discount;

  double get total {
    return subtotal + deliveryFee + taxes - _discount;
  }

  void addItem(String id, String name, double price, String imageType) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity++;
    } else {
      _items[id] = CartItem(
        id: id,
        name: name,
        price: price,
        imageType: imageType,
      );
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void incrementQuantity(String id) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String id) {
    if (_items.containsKey(id)) {
      if (_items[id]!.quantity > 1) {
        _items[id]!.quantity--;
      } else {
        _items.remove(id);
      }
      notifyListeners();
    }
  }

  void applyDiscount(String code) {
    if (code.toUpperCase() == 'SAVE10') {
      _discount = subtotal * 0.1;
      notifyListeners();
    } else {
      _discount = 0.0;
    }
  }

  List<Map<String, dynamic>> getCartItems() {
    return _items.values.map((item) => item.toMap()).toList();
  }

  void clearCart() {
    _items.clear();
    _discount = 0.0;
    notifyListeners();
  }
}
