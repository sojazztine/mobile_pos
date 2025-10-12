import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/order_model.dart';
import '../../services/database_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String restaurant;
  final String currentStatus;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.restaurant,
    this.currentStatus = 'pending',
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Order? currentOrder;
  Timer? _refreshTimer;
  bool isLoading = true;
  GoogleMapController? _mapController;
  LatLng? _customerLocation;
  LatLng? _riderLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isMapLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
    // Auto-refresh every 10 seconds for real-time updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadOrderDetails();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadOrderDetails() async {
    final db = DatabaseService.instance;
    final order = await db.getOrderById(int.parse(widget.orderId));

    if (mounted && order != null) {
      setState(() {
        currentOrder = order;
        isLoading = false;
      });

      // Load map data after order is loaded
      if (order.status == 'delivering' || order.status == 'completed') {
        await _initializeMap();
      }
    }
  }

  Future<void> _initializeMap() async {
    if (currentOrder == null) return;

    try {
      // Geocode customer address
      final addresses = await locationFromAddress(currentOrder!.deliveryAddress);
      if (addresses.isNotEmpty) {
        _customerLocation = LatLng(
          addresses.first.latitude,
          addresses.first.longitude,
        );
      }

      // Simulate rider location (in real app, this would come from rider's GPS)
      // For now, we'll place the rider somewhere between restaurant and customer
      if (_customerLocation != null) {
        // Place rider 70% of the way to customer (simulating delivery in progress)
        _riderLocation = LatLng(
          _customerLocation!.latitude - 0.01,
          _customerLocation!.longitude - 0.01,
        );
      }

      _setupMapElements();

      if (mounted) {
        setState(() {
          _isMapLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing map: $e');
      // Use default location if geocoding fails
      setState(() {
        _customerLocation = const LatLng(37.7749, -122.4194);
        _riderLocation = const LatLng(37.7649, -122.4094);
        _isMapLoading = false;
      });
      _setupMapElements();
    }
  }

  void _setupMapElements() {
    if (_customerLocation == null) return;

    setState(() {
      _markers = {
        // Customer location marker
        Marker(
          markerId: const MarkerId('customer'),
          position: _customerLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Delivery Location',
            snippet: currentOrder?.customerName ?? 'Your location',
          ),
        ),
      };

      // Add rider marker if order is being delivered
      if (_riderLocation != null && currentOrder?.status == 'delivering') {
        _markers.add(
          Marker(
            markerId: const MarkerId('rider'),
            position: _riderLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(
              title: 'Rider Location',
              snippet: 'Your delivery is on the way!',
            ),
          ),
        );

        // Add polyline between rider and customer
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [_riderLocation!, _customerLocation!],
            color: Colors.blue,
            width: 5,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          ),
        };
      }
    });
  }

  void _fitMapToBounds() {
    if (_mapController == null || _customerLocation == null) return;

    if (_riderLocation != null && currentOrder?.status == 'delivering') {
      // Show both rider and customer
      final bounds = LatLngBounds(
        southwest: LatLng(
          _riderLocation!.latitude < _customerLocation!.latitude
              ? _riderLocation!.latitude
              : _customerLocation!.latitude,
          _riderLocation!.longitude < _customerLocation!.longitude
              ? _riderLocation!.longitude
              : _customerLocation!.longitude,
        ),
        northeast: LatLng(
          _riderLocation!.latitude > _customerLocation!.latitude
              ? _riderLocation!.latitude
              : _customerLocation!.latitude,
          _riderLocation!.longitude > _customerLocation!.longitude
              ? _riderLocation!.longitude
              : _customerLocation!.longitude,
        ),
      );
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    } else {
      // Show only customer location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_customerLocation!, 15),
      );
    }
  }

  Future<void> _openMapNavigation() async {
    if (currentOrder == null) return;

    final address = Uri.encodeComponent(currentOrder!.deliveryAddress);
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$address');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open map navigation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || currentOrder == null) {
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
            'Order Tracking',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator(color: Colors.pink)),
      );
    }

    final status = currentOrder!.status.toLowerCase();

    // Determine which steps are completed based on real status
    bool isAccepted = ['accepted', 'preparing', 'ready', 'delivering', 'completed'].contains(status);
    bool isPreparing = ['preparing', 'ready', 'delivering', 'completed'].contains(status);
    bool isReady = ['ready', 'delivering', 'completed'].contains(status);
    bool isDelivering = ['delivering', 'completed'].contains(status);
    bool isCompleted = status == 'completed';

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
          'Order Tracking',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadOrderDetails,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade400, Colors.pink.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${currentOrder!.id}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getStatusText(status),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentOrder!.restaurant,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Delivering to: ${currentOrder!.deliveryAddress.split('\n')[0]}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Order Status Steps
              _buildStatusStep(
                'Order Placed',
                _getStatusTime('pending'),
                true,
                Icons.receipt_long,
              ),
              _buildConnectorLine(isAccepted),
              _buildStatusStep(
                'Order Accepted',
                _getStatusTime('accepted'),
                isAccepted,
                Icons.check_circle_outline,
              ),
              _buildConnectorLine(isPreparing),
              _buildStatusStep(
                'Preparing',
                _getStatusTime('preparing'),
                isPreparing,
                Icons.restaurant_menu,
              ),
              _buildConnectorLine(isReady),
              _buildStatusStep(
                'Ready for Pickup',
                _getStatusTime('ready'),
                isReady,
                Icons.shopping_bag,
              ),
              _buildConnectorLine(isDelivering),
              _buildStatusStep(
                'Out for Delivery',
                _getStatusTime('delivering'),
                isDelivering,
                Icons.delivery_dining,
              ),
              _buildConnectorLine(isCompleted),
              _buildStatusStep(
                'Delivered',
                _getStatusTime('completed'),
                isCompleted,
                Icons.home,
              ),

              const SizedBox(height: 32),

              // Delivery Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Delivery Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(_getProgressValue(status) * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _getProgressValue(status),
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
                ),
              ),

              const SizedBox(height: 32),

              // Map Section with Navigation Button
              if (isDelivering && !isCompleted) ...[
                const Text(
                  'Track Delivery',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _isMapLoading
                        ? Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(color: Colors.pink),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Loading map...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _customerLocation == null
                            ? Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_off,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Unable to load map',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Stack(
                                children: [
                                  GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: _customerLocation!,
                                      zoom: 14,
                                    ),
                                    onMapCreated: (controller) {
                                      _mapController = controller;
                                      _fitMapToBounds();
                                    },
                                    markers: _markers,
                                    polylines: _polylines,
                                    myLocationEnabled: false,
                                    myLocationButtonEnabled: false,
                                    zoomControlsEnabled: false,
                                    mapToolbarEnabled: false,
                                    compassEnabled: true,
                                  ),
                                  // Legend overlay
                                  Positioned(
                                    top: 16,
                                    left: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.delivery_dining,
                                            color: Colors.green[600],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Rider',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(
                                            Icons.location_on,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'You',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openMapNavigation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.navigation),
                    label: const Text(
                      'Open in Google Maps',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'delivering':
        return 'Out for Delivery';
      case 'completed':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  String _getStatusTime(String checkStatus) {
    if (currentOrder == null) return '';

    final status = currentOrder!.status.toLowerCase();

    if (checkStatus == 'pending') {
      return 'Order placed on ${currentOrder!.date}';
    }

    if (checkStatus == 'accepted' && currentOrder!.acceptedAt != null) {
      final time = currentOrder!.acceptedAt!;
      return 'Accepted at ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }

    if (checkStatus == 'completed' && currentOrder!.completedAt != null) {
      final time = currentOrder!.completedAt!;
      return 'Delivered at ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }

    // Check if this status has been reached
    final statusOrder = ['pending', 'accepted', 'preparing', 'ready', 'delivering', 'completed'];
    final currentIndex = statusOrder.indexOf(status);
    final checkIndex = statusOrder.indexOf(checkStatus);

    if (currentIndex >= checkIndex) {
      if (checkStatus == status) {
        return 'In progress...';
      }
      return 'Completed';
    }

    return 'Pending';
  }

  Widget _buildStatusStep(
    String title,
    String subtitle,
    bool isCompleted,
    IconData icon,
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
            isCompleted ? Icons.check_circle : icon,
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
            color: Colors.black.withValues(alpha: 0.2),
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
    switch (status.toLowerCase()) {
      case 'pending':
        return 0.16; // 1/6
      case 'accepted':
        return 0.33; // 2/6
      case 'preparing':
        return 0.50; // 3/6
      case 'ready':
        return 0.66; // 4/6
      case 'delivering':
        return 0.83; // 5/6
      case 'completed':
        return 1.0; // 6/6
      case 'cancelled':
        return 0.0;
      default:
        return 0.16;
    }
  }
}
