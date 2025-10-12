import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'vendor_add_product.dart';
import 'vendor_edit_product.dart';
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
                          color: Colors.pink.withValues(alpha: 0.1),
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
                  for (var entry in _groupProductsByCategory().entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCategoryItem(
                        title: entry.key,
                        itemCount: '${entry.value.length} items',
                        products: entry.value,
                      ),
                    ),

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
            for (var product in vendorProducts)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMenuItem(
                  product: product,
                ),
              ),

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
      onTap: () => _showProductOptions(product),
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
                color: Color(product.colorValue).withValues(alpha: 0.3),
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
                        '• Stock: ${product.stockQuantity}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // More options icon
            Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  void _showProductOptions(Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Product name
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Options
            _buildOptionTile(
              icon: Icons.visibility_outlined,
              title: 'View Details',
              subtitle: 'See product information',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                _showProductDetails(product);
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              icon: Icons.inventory_outlined,
              title: 'Edit Stock',
              subtitle: 'Update stock quantity (Current: ${product.stockQuantity})',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                _showEditStockDialog(product);
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              icon: Icons.edit_outlined,
              title: 'Edit Product',
              subtitle: 'Modify product details',
              color: Colors.green,
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VendorEditProduct(product: product),
                  ),
                );
                if (result == true) {
                  _loadVendorProducts();
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showEditStockDialog(Product product) {
    final stockController = TextEditingController(text: product.stockQuantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Stock Quantity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Stock Quantity',
                hintText: 'Enter stock quantity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.inventory),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newStock = int.tryParse(stockController.text);
              if (newStock != null && newStock >= 0) {
                final updatedProduct = product.copyWith(stockQuantity: newStock);
                await DatabaseService.instance.updateProduct(updatedProduct);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Stock updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadVendorProducts();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid stock quantity'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Product image
                    if (product.imagePath != null && product.imagePath!.isNotEmpty)
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: FileImage(File(product.imagePath!)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Color(product.colorValue).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.fastfood, size: 80, color: Colors.white),
                      ),
                    const SizedBox(height: 24),
                    // Product name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.pink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.category,
                        style: const TextStyle(
                          color: Colors.pink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Details
                    _buildDetailRow('Price', '\$${product.price.toStringAsFixed(2)}'),
                    _buildDetailRow('Stock Quantity', '${product.stockQuantity}'),
                    _buildDetailRow('Status', product.isActive ? 'Active' : 'Inactive'),
                    const SizedBox(height: 16),
                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showEditStockDialog(product);
                            },
                            icon: const Icon(Icons.inventory),
                            label: const Text('Edit Stock'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VendorEditProduct(product: product),
                                ),
                              );
                              if (result == true) {
                                _loadVendorProducts();
                              }
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

}
