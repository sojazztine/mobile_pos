import 'package:flutter/material.dart';
import 'dart:async';

class RiderNavigationMapScreen extends StatefulWidget {
  final String? deliveryAddress;
  final String? restaurantName;
  final double distanceMiles;

  const RiderNavigationMapScreen({
    super.key,
    this.deliveryAddress,
    this.restaurantName,
    this.distanceMiles = 3.2,
  });

  @override
  State<RiderNavigationMapScreen> createState() => _RiderNavigationMapScreenState();
}

class _RiderNavigationMapScreenState extends State<RiderNavigationMapScreen> {
  int _distanceFeet = 250;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        if (_distanceFeet > 0) {
          _distanceFeet -= 25;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.navigation, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              'Distance: $_distanceFeet ft',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              'To: ${widget.deliveryAddress ?? "Delivery Address"}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep old class for compatibility
class RiderNavigationMap extends StatefulWidget {
  final String deliveryAddress;
  final String restaurantName;
  final double distanceMiles;

  const RiderNavigationMap({
    super.key,
    required this.deliveryAddress,
    required this.restaurantName,
    this.distanceMiles = 3.2,
  });

  @override
  State<RiderNavigationMap> createState() => _RiderNavigationMapState();
}

class _RiderNavigationMapState extends State<RiderNavigationMap> {
  int _distanceFeet = 250;
  Timer? _timer;
  double _progress = 0.5;

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSimulation() {
    // Simulate navigation progress
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          if (_distanceFeet > 0) {
            _distanceFeet -= 10;
            _progress += 0.02;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int hours = 12;
    final int minutes = 35;
    final String timeString = '$hours:$minutes PM arrival';
    final String distanceString = '(${widget.distanceMiles} mi)';

    return Scaffold(
      body: Stack(
        children: [
          // Map Placeholder (would be Google Maps or other map widget)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Map View',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Google Maps integration would go here',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Navigation Info
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Main Direction Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // Direction Icon
                      Icon(
                        Icons.turn_left,
                        color: Colors.blue[400],
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      // Direction Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Oak Street',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$_distanceFeet ft',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Close Button
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Arrival Time Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.grey[400],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeString,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        distanceString,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.restaurant,
                        color: Colors.blue[400],
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.restaurantName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Map Controls
          Positioned(
            right: 20,
            top: 250,
            child: Column(
              children: [
                // Zoom In
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      // Zoom in
                    },
                  ),
                ),
                Divider(height: 1, color: Colors.grey[700]),
                // Zoom Out
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white),
                    onPressed: () {
                      // Zoom out
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Center Location
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.navigation, color: Colors.white),
                    onPressed: () {
                      // Center on location
                    },
                  ),
                ),
              ],
            ),
          ),

          // Bottom Delivery Info Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Delivery Address
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery to ${widget.deliveryAddress}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ends in $_distanceFeet ft',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$hours:$minutes PM (${widget.distanceMiles} mi)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progress > 1.0 ? 1.0 : _progress,
                        backgroundColor: Colors.grey[700],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Call Button
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextButton.icon(
                              onPressed: () {
                                // Make call
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Calling customer...'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.phone,
                                color: Colors.white,
                                size: 20,
                              ),
                              label: const Text(
                                'Call',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // End Button
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextButton.icon(
                              onPressed: () {
                                _showEndDeliveryDialog();
                              },
                              icon: const Icon(
                                Icons.power_settings_new,
                                color: Colors.white,
                                size: 20,
                              ),
                              label: const Text(
                                'End',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Volume Button
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              // Toggle volume
                            },
                            icon: const Icon(
                              Icons.volume_up,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEndDeliveryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.grey[900],
        title: const Text(
          'End Delivery',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Have you successfully delivered the order?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _timer?.cancel();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to deliveries
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delivery completed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}
