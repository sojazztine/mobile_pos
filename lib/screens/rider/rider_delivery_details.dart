import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/database_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'rider_navigation_map.dart';

class RiderDeliveryDetailsScreen extends StatefulWidget {
  final Order order;

  const RiderDeliveryDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<RiderDeliveryDetailsScreen> createState() => _RiderDeliveryDetailsScreenState();
}

class _RiderDeliveryDetailsScreenState extends State<RiderDeliveryDetailsScreen> {
  late Order currentOrder;

  @override
  void initState() {
    super.initState();
    currentOrder = widget.order;
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    final db = DatabaseService.instance;
    final success = await db.updateOrderStatus(currentOrder.id!, newStatus);

    if (!mounted) return;

    if (success) {
      // Refresh order from database
      final updatedOrder = await db.getOrderById(currentOrder.id!);
      if (updatedOrder != null) {
        setState(() {
          currentOrder = updatedOrder;
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${newStatus.toUpperCase()}'),
            backgroundColor: Colors.green,
          ),
        );

        // If completed, navigate back
        if (newStatus == 'completed') {
          Navigator.pop(context);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update order status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _callCustomer() async {
    final phoneUrl = Uri.parse('tel:${currentOrder.phoneNumber}');
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not make phone call'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _getStatusButton() {
    switch (currentOrder.status) {
      case 'accepted':
        return ElevatedButton(
          onPressed: () => _updateOrderStatus('delivering'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delivery_dining),
              SizedBox(width: 8),
              Text(
                'Start Delivery',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      case 'delivering':
        return ElevatedButton(
          onPressed: () => _updateOrderStatus('completed'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle),
              SizedBox(width: 8),
              Text(
                'Complete Delivery',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      case 'completed':
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Delivery Completed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Color _getStatusColor() {
    switch (currentOrder.status) {
      case 'accepted':
        return Colors.orange;
      case 'delivering':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
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
        title: Text(
          'Order #${currentOrder.id}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor()),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: _getStatusColor(),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Status: ${currentOrder.status.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // DELIVER TO Section
              Text(
                'DELIVER TO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Customer Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.pink, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          currentOrder.customerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: Colors.pink, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currentOrder.deliveryAddress,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.pink, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              currentOrder.phoneNumber,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _callCustomer,
                          icon: const Icon(Icons.phone, color: Colors.green),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ORDER DETAILS Section
              Text(
                'ORDER DETAILS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[600],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Restaurant Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.store, color: Colors.pink, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          currentOrder.restaurant,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...currentOrder.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item['quantity']}x ${item['name']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Text(
                              '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '\$${currentOrder.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.payment,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Payment: ${currentOrder.paymentMethod}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Navigation Button
              if (currentOrder.status == 'delivering')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RiderNavigationMapScreen(
                            order: currentOrder,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.pink,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.pink, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.map),
                    label: const Text(
                      'Open Navigation',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              if (currentOrder.status == 'delivering')
                const SizedBox(height: 12),

              // Status Action Button
              SizedBox(
                width: double.infinity,
                child: _getStatusButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Keep old class for compatibility
class RiderDeliveryDetails extends StatelessWidget {
  final String orderId;
  final String customerName;
  final String deliveryAddress;
  final String addressDetails;

  const RiderDeliveryDetails({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.deliveryAddress,
    required this.addressDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('This screen has been deprecated. Use RiderDeliveryDetailsScreen instead.'),
      ),
    );
  }
}
