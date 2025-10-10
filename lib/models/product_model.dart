import 'dish_model.dart';

class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String category; // 'Popular', 'Appetizers', 'Main Courses', 'Desserts'
  final int colorValue; // Color for product card background
  final int vendorId; // ID of the vendor who created this product
  final int stockQuantity; // Available stock
  final String? imagePath; // Path to product image
  final DateTime createdAt;
  final bool isActive; // Admin can approve/deactivate products

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.colorValue,
    required this.vendorId,
    this.stockQuantity = 0,
    this.imagePath,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Product to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'colorValue': colorValue,
      'vendorId': vendorId,
      'stockQuantity': stockQuantity,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  // Create Product from Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      price: map['price'] as double,
      category: map['category'] as String,
      colorValue: map['colorValue'] as int,
      vendorId: map['vendorId'] as int,
      stockQuantity: map['stockQuantity'] as int? ?? 0,
      imagePath: map['imagePath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isActive: (map['isActive'] as int) == 1,
    );
  }

  // Create a copy with updated fields
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? category,
    int? colorValue,
    int? vendorId,
    int? stockQuantity,
    String? imagePath,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      colorValue: colorValue ?? this.colorValue,
      vendorId: vendorId ?? this.vendorId,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Convert to Dish for compatibility with existing UI
  Dish toDish() {
    return Dish(
      id: id.toString(),
      name: name,
      description: description,
      price: price,
      category: category,
      imageType: 'food', // Default image type
      colorValue: colorValue,
    );
  }
}
