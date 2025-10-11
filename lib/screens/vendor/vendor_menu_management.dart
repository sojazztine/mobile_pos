import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'vendor_add_product.dart';
import 'vendor_edit_product.dart';
import 'vendor_dashboard.dart';
import 'vendor_orders.dart';
import 'vendor_reports.dart';
import 'vendor_profile.dart';
import '../../models/auth_model.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';

class VendorMenuManagement extends StatefulWidget {
  const VendorMenuManagement({super.key});

  @override
  State<VendorMenuManagement> createState() => _VendorMenuManagementState();
}

class _VendorMenuManagementState extends State<VendorMenuManagement> {
  List<Product> vendorProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVendorProducts();
  }

  Future<void> _loadVendorProducts() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    final vendorId = authModel.currentUser?.id;

    if (vendorId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final db = DatabaseService.instance;
    final products = await db.getProductsByVendor(vendorId);

    setState(() {
      vendorProducts = products;
      isLoading = false;
    });
  }

  Map<String, List<Product>> _groupProductsByCategory() {
    final Map<String, List<Product>> grouped = {};
    for (var product in vendorProducts) {
      if (!grouped.containsKey(product.category)) {
        grouped[product.category] = [];
      }
      grouped[product.category]!.add(product);
    }
    return grouped;
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
          'Menu Management',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Info
                  Consumer<AuthModel>(
                    builder: (context, authModel, child) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.store, color: Colors.pink, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authModel.currentUser?.fullName ?? 'My Store',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${vendorProducts.length} products',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Categories Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: _loadVendorProducts,
                        icon: const Icon(Icons.refresh, color: Colors.pink),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category Items from actual products
                  ..._groupProductsByCategory().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCategoryItem(
                        title: entry.key,
                        itemCount: '${entry.value.length} items',
                        products: entry.value,
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 32),

                  // Items Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Products',
                        style: TextStyle(
                          fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // View all items
                  },
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      color: Colors.pink,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Menu Items - Show actual products
            ...vendorProducts.map((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMenuItem(
                  product: product,
                ),
              );
            }).toList(),

            const SizedBox(height: 80), // Space for button
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VendorAddProduct(),
            ),
          );
        },
        backgroundColor: Colors.pink,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text(
          'Add Item',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem({
    required String title,
    required String itemCount,
    required List<Product> products,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Category Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.restaurant,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Category Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  itemCount,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // More Options
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            onPressed: () {
              // Show options
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required Product product,
  }) {
    final isAvailable = product.isActive && product.stockQuantity > 0;
    final statusColor = isAvailable ? Colors.green : Colors.red;
    final status = isAvailable ? 'Available' : (product.stockQuantity == 0 ? 'Out of Stock' : 'Unavailable');

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorEditProduct(product: product),
          ),
        );

        // Reload products if updated or deleted
        if (result == true) {
          _loadVendorProducts();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Item Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(product.colorValue).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                image: product.imagePath != null && product.imagePath!.isNotEmpty
                    ? DecorationImage(
                        image: FileImage(File(product.imagePath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: product.imagePath == null || product.imagePath!.isEmpty
                  ? const Icon(
                      Icons.fastfood,
                      color: Colors.white,
                      size: 24,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Item Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 13,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• \$${product.price.toStringAsFixed(2)}',
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
            // Arrow
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

}
