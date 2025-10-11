import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productName;
  final String description;
  final double basePrice;
  final String imageType;
  final Color backgroundColor;
  final String? imagePath;
  final bool hasCustomization;

  const ProductDetailsScreen({
    super.key,
    required this.productName,
    required this.description,
    required this.basePrice,
    required this.imageType,
    required this.backgroundColor,
    this.imagePath,
    this.hasCustomization = false,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String selectedSize = 'Single';
  Set<String> selectedAddons = {};
  int quantity = 1;

  final Map<String, double> sizePrices = {
    'Single': 1.0,
    'Double': 1.5,
    'Triple': 2.0,
  };

  final Map<String, double> addonPrices = {
    'Extra Cheese': 1.50,
    'Bacon': 2.00,
    'Avocado': 1.75,
    'Extra Sauce': 0.50,
  };

  double get totalPrice {
    double sizeMultiplier = sizePrices[selectedSize] ?? 1.0;
    double addonsPrice = selectedAddons.fold(
      0.0,
      (sum, addon) => sum + (addonPrices[addon] ?? 0.0),
    );
    return (widget.basePrice * sizeMultiplier + addonsPrice) * quantity;
  }

  void _addToCart() {
    final cart = Provider.of<CartModel>(context, listen: false);

    // Create item name with customizations (only if product has customizations)
    String itemName = widget.productName;
    if (widget.hasCustomization) {
      if (selectedSize != 'Single') {
        itemName += ' ($selectedSize)';
      }
      if (selectedAddons.isNotEmpty) {
        itemName += ' + ${selectedAddons.join(', ')}';
      }
    }

    // Generate unique ID based on customizations
    String itemId;
    if (widget.hasCustomization) {
      itemId = '${widget.productName}_${selectedSize}_${selectedAddons.join('_')}'
          .toLowerCase()
          .replaceAll(' ', '_');
    } else {
      itemId = widget.productName.toLowerCase().replaceAll(' ', '_');
    }

    // Add to cart with calculated price
    double itemPrice = widget.hasCustomization ? (totalPrice / quantity) : widget.basePrice;
    
    // Add the item with the specified quantity
    for (int i = 0; i < quantity; i++) {
      cart.addItem(itemId, itemName, itemPrice, widget.imageType);
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName added to cart!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Close the product details screen
    Navigator.pop(context);
  }

  DecorationImage? _buildImage() {
    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      return DecorationImage(
        image: FileImage(File(widget.imagePath!)),
        fit: BoxFit.cover,
      );
    }
    return null;
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
          'Product Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image or Vendor Profile
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      image: _buildImage(),
                    ),
                    child: _buildImage() == null
                        ? Center(
                            child: Icon(
                              Icons.fastfood,
                              size: 120,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          )
                        : null,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          widget.productName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Customize Section (only if hasCustomization is true)
                        if (widget.hasCustomization) ...[
                          const Text(
                            'Size',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Size Options
                          Row(
                            children: [
                              _buildSizeOption('Single'),
                              const SizedBox(width: 12),
                              _buildSizeOption('Double'),
                              const SizedBox(width: 12),
                              _buildSizeOption('Triple'),
                            ],
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            'Add-ons',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Add-ons List
                          ...addonPrices.keys.map((addon) {
                            return _buildAddonOption(addon, addonPrices[addon]!);
                          }),

                          const SizedBox(height: 24),
                        ],

                        // Quantity Section
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Quantity Selector
                        Row(
                          children: [
                            _buildQuantityButton(
                              Icons.remove,
                              () {
                                if (quantity > 1) {
                                  setState(() {
                                    quantity--;
                                  });
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildQuantityButton(
                              Icons.add,
                              () {
                                setState(() {
                                  quantity++;
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add to Cart Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Add to Cart - \$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeOption(String size) {
    final bool isSelected = selectedSize == size;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedSize = size;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.pink : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.pink : Colors.grey[300]!,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              size,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddonOption(String addon, double price) {
    final bool isSelected = selectedAddons.contains(addon);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedAddons.remove(addon);
          } else {
            selectedAddons.add(addon);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? Colors.pink : Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.pink : Colors.grey[400]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                addon,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '+\$${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFCE4EC),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: Colors.pink,
        ),
      ),
    );
  }
}
