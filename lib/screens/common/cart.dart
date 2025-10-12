import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/auth/login_modal.dart';
import 'checkout.dart';
import '../../models/cart_model.dart';
import '../../models/auth_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _discountController = TextEditingController();

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  void _applyDiscount(CartModel cart) {
    String code = _discountController.text.toUpperCase();
    cart.applyDiscount(code);
    if (code == 'SAVE10') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Discount applied: 10% off!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (code.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid discount code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _checkout(CartModel cart) async {
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authModel = Provider.of<AuthModel>(context, listen: false);

    if (!authModel.isLoggedIn) {
      final bool? loggedIn = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LoginModal(),
      );

      if (loggedIn != true) {
        return;
      }
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          subtotal: cart.subtotal,
          deliveryFee: cart.deliveryFee,
          taxes: cart.taxes,
          total: cart.total,
          cartItems: cart.getCartItems(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        final cartItemsList = cart.items.values.toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              'My Cart',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: cart.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your cart is empty',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Cart Items List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: 16,
                        ),
                        itemCount: cartItemsList.length,
                        itemBuilder: (context, index) {
                          final item = cartItemsList[index];
                          return _buildCartItem(
                            cart,
                            item.name,
                            item.price,
                            item.quantity,
                            item.imageType,
                            item.id,
                          );
                        },
                      ),
                    ),

                    // Bottom Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Discount Code
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 48,
                                      maxHeight: 48,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: TextField(
                                      controller: _discountController,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter Discount Code',
                                        hintStyle:
                                            TextStyle(fontSize: 14),
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _applyDiscount(cart),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFFCE4EC),
                                    foregroundColor: Colors.pink,
                                    elevation: 0,
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    minimumSize: const Size(0, 48),
                                  ),
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Order Summary
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Order Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryRow('Subtotal', cart.subtotal),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                                'Delivery Fee', cart.deliveryFee),
                            const SizedBox(height: 8),
                            _buildSummaryRow('Taxes', cart.taxes),
                            if (cart.discount > 0) ...[
                              const SizedBox(height: 8),
                              _buildSummaryRow('Discount', -cart.discount,
                                  isDiscount: true),
                            ],
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$${cart.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Checkout Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _checkout(cart),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Checkout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildCartItem(
    CartModel cart,
    String name,
    double price,
    int quantity,
    String imageType,
    String itemId,
  ) {
    Color bgColor = Colors.grey[300]!;
    if (imageType == 'burger') bgColor = Colors.orange[200]!;
    if (imageType == 'fries') bgColor = Colors.grey[300]!;
    if (imageType == 'coke') bgColor = Colors.brown[200]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Item Image
          SizedBox(
            width: 60,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Quantity Controls
          Row(
            children: [
              _buildQuantityButton(
                Icons.remove,
                () => cart.decrementQuantity(itemId),
                const Color(0xFFFCE4EC),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildQuantityButton(
                Icons.add,
                () => cart.incrementQuantity(itemId),
                const Color(0xFFFCE4EC),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: Colors.pink,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount,
      {bool isDiscount = false}) {
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
          '${isDiscount ? '-' : ''}\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            color: isDiscount ? Colors.green : Colors.grey[700],
            fontWeight:
                isDiscount ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}