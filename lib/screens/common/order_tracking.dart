import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  final String restaurant;
  final String currentStatus;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.restaurant,
    this.currentStatus = 'On the way',
  });

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
          'Order Tracking',
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Number
              Text(
                'Order #$orderId',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // Order Status Steps
              _buildStatusStep(
                'Order placed',
                'Estimated delivery: 20-30 minutes',
                true,
                false,
              ),
              _buildConnectorLine(true),
              _buildStatusStep(
                'Preparing',
                'Your order is being prepared',
                true,
                false,
              ),
              _buildConnectorLine(true),
              _buildStatusStep(
                'On the way',
                'The rider is heading to you',
                currentStatus == 'On the way' ||
                    currentStatus == 'Delivered',
                false,
              ),
              _buildConnectorLine(currentStatus == 'Delivered'),
              _buildStatusStep(
                'Delivered',
                'Your order has been delivered',
                currentStatus == 'Delivered',
                true,
              ),

              const SizedBox(height: 32),

              // Delivery Progress
              const Text(
                'Delivery Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _getProgressValue(currentStatus),
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
                ),
              ),

              const SizedBox(height: 24),

              // Map Section
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Placeholder for map - you would use google_maps_flutter here
                      Container(
                        color: const Color(0xFFB3E5FC),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 64,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Delivery Map',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tracking rider location...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Restaurant marker
                      Positioned(
                        top: 40,
                        left: 40,
                        child: _buildMapMarker(Icons.restaurant, Colors.orange),
                      ),
                      // Delivery marker
                      Positioned(
                        bottom: 40,
                        right: 40,
                        child: _buildMapMarker(Icons.location_on, Colors.pink),
                      ),
                    ],
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

  Widget _buildStatusStep(
    String title,
    String subtitle,
    bool isCompleted,
    bool isLast,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCompleted ? Colors.pink : const Color(0xFFFCE4EC),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.circle_outlined,
            color: isCompleted ? Colors.white : Colors.pink,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),

        // Status Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.black : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
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
      ],
    );
  }

  Widget _buildConnectorLine(bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(left: 23),
      child: Container(
        width: 2,
        height: 24,
        color: isCompleted ? Colors.pink : Colors.grey[300],
      ),
    );
  }

  Widget _buildMapMarker(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  double _getProgressValue(String status) {
    switch (status) {
      case 'Order placed':
        return 0.25;
      case 'Preparing':
        return 0.5;
      case 'On the way':
        return 0.75;
      case 'Delivered':
        return 1.0;
      default:
        return 0.5;
    }
  }
}
