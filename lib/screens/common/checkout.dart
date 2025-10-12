import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_model.dart';
import '../../models/order_model.dart';
import '../../models/auth_model.dart';
import '../../services/database_service.dart';
import 'orders.dart';

class CheckoutScreen extends StatefulWidget {
  final double subtotal;
  final double deliveryFee;
  final double taxes;
  final double total;
  final List<Map<String, dynamic>> cartItems;

  const CheckoutScreen({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.taxes,
    required this.total,
    required this.cartItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPaymentMethod = 'Credit Card';
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-fill user information
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final user = authModel.currentUser;

      if (user != null) {
        _fullNameController.text = user.fullName;
        _addressController.text = user.address;
        _phoneController.text = user.phone;
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _placeOrder() async {
    // Validate form
    if (_fullNameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all delivery information'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authModel = Provider.of<AuthModel>(context, listen: false);
    final currentUser = authModel.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to place an order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final db = DatabaseService.instance;

      // First, validate all items and prepare order items
      final orderItems = <Map<String, dynamic>>[];
      final productsToDeduct = <Map<String, dynamic>>[];

      for (var item in widget.cartItems) {
        final productName = (item['name'] as String).split(' + ')[0]; // Get base product name without addons
        final quantity = item['quantity'] as int;

        // Get product from database by name to check stock
        final allProducts = await db.getAllProducts();
        final matchingProducts = allProducts.where((p) => p.name == productName).toList();

        if (matchingProducts.isEmpty) {
          if (!mounted) return;
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product "$productName" not found in database'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final product = matchingProducts.first;
        final productId = product.id!;

        // Check if enough stock is available
        if (product.stockQuantity < quantity) {
          if (!mounted) return;
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Insufficient stock for ${item['name']}. Available: ${product.stockQuantity}, Requested: $quantity'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Add to deduction list
        productsToDeduct.add({
          'productId': productId,
          'quantity': quantity,
        });

        // Add to order items
        orderItems.add({
          'productId': productId,
          'name': item['name'],
          'quantity': quantity,
          'price': item['price'],
        });
      }

      // All items have sufficient stock, now deduct them
      for (var productInfo in productsToDeduct) {
        final success = await db.updateProductStock(
          productInfo['productId'] as int,
          productInfo['quantity'] as int,
        );

        if (!success) {
          if (!mounted) return;
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update stock. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Get vendor ID from first product
      final firstProductId = orderItems.first['productId'] as int;
      final product = await db.getAllProducts();
      final vendorId = product.firstWhere((p) => p.id == firstProductId).vendorId;
      final vendor = await db.getUserById(vendorId);

      // Create order
      final order = Order(
        userId: currentUser.id!,
        vendorId: vendorId,
        restaurant: vendor?.fullName ?? 'Restaurant',
        date: _formatDate(DateTime.now()),
        description: orderItems.map((item) => item['name']).join(', '),
        price: widget.total,
        status: 'pending',
        items: orderItems,
        customerName: _fullNameController.text,
        deliveryAddress: _addressController.text,
        phoneNumber: _phoneController.text,
        paymentMethod: selectedPaymentMethod,
      );

      final createdOrder = await db.createOrder(order);

      // Debug: Print order creation result
      debugPrint('DEBUG: Order creation result: ${createdOrder != null ? "SUCCESS" : "FAILED"}');
      if (createdOrder != null) {
        debugPrint('DEBUG: Created order ID: ${createdOrder.id}, Status: ${createdOrder.status}');
      }

      if (createdOrder != null) {
        if (!mounted) return;
        // Update orders model
        final ordersModel = Provider.of<OrdersModel>(context, listen: false);
        ordersModel.addOrder(createdOrder);

        // Clear cart
        final cartModel = Provider.of<CartModel>(context, listen: false);
        cartModel.clearCart();

        Navigator.pop(context); // Close loading

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Order Placed Successfully!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text('Order #${createdOrder.id}'),
                Text('Total: \$${widget.total.toStringAsFixed(2)}'),
                Text('Payment Method: $selectedPaymentMethod'),
                const SizedBox(height: 8),
                const Text(
                  'You can track your order in the Orders tab.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Go to Home'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrdersScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
                child: const Text('View Orders'),
              ),
            ],
          ),
        );
      } else {
        if (!mounted) return;
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create order. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return '${days[date.weekday % 7]} ${months[date.month - 1]} ${date.day}';
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Section
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Grouped items
              ...widget.cartItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${item['quantity']} item${item['quantity'] > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),

              // Summary totals
              _buildSummaryRow('Subtotal', widget.subtotal),
              const SizedBox(height: 8),
              _buildSummaryRow('Tax', widget.taxes),
              const SizedBox(height: 8),
              _buildSummaryRow('Delivery Fee', widget.deliveryFee),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${widget.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Payment Method Section
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildPaymentOption(
                'Credit Card',
                Icons.credit_card,
              ),
              const SizedBox(height: 8),
              _buildPaymentOption(
                'GCash',
                Icons.account_balance_wallet,
              ),
              const SizedBox(height: 8),
              _buildPaymentOption(
                'Maya',
                Icons.payment,
              ),
              const SizedBox(height: 8),
              _buildPaymentOption(
                'Cash on Delivery',
                Icons.money,
              ),

              const SizedBox(height: 24),

              // Delivery Information Section
              const Text(
                'Delivery Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _fullNameController,
                hint: 'Full Name',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _addressController,
                hint: 'Delivery Address',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                hint: 'Phone Number',
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 32),

              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    final bool isSelected = selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFCE4EC) : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.pink : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.pink : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.pink : Colors.black,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.pink,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
