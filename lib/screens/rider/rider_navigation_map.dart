import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../models/order_model.dart';
import 'package:url_launcher/url_launcher.dart';

class RiderNavigationMapScreen extends StatefulWidget {
  final Order order;

  const RiderNavigationMapScreen({
    super.key,
    required this.order,
  });

  @override
  State<RiderNavigationMapScreen> createState() => _RiderNavigationMapScreenState();
}

class _RiderNavigationMapScreenState extends State<RiderNavigationMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  LatLng? _destinationLatLng;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Timer? _locationTimer;
  bool _isLoading = true;
  double _distanceInMeters = 0;
  String _estimatedTime = '';

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      // Check and request location permissions
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        if (!mounted) return;
        _showPermissionError();
        return;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Geocode destination address
      await _geocodeDestination();

      // Setup markers and polyline
      _setupMapElements();

      // Start real-time location tracking
      _startLocationTracking();

      setState(() {
        _isLoading = false;
      });

      // Move camera to show both locations
      if (_destinationLatLng != null) {
        _fitMapToBounds();
      }
    } catch (e) {
      debugPrint('Error initializing map: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showError('Could not initialize map: $e');
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> _geocodeDestination() async {
    try {
      final addresses = await locationFromAddress(widget.order.deliveryAddress);
      if (addresses.isNotEmpty) {
        setState(() {
          _destinationLatLng = LatLng(
            addresses.first.latitude,
            addresses.first.longitude,
          );
        });
      }
    } catch (e) {
      debugPrint('Error geocoding address: $e');
      // Use default location if geocoding fails (San Francisco)
      setState(() {
        _destinationLatLng = const LatLng(37.7749, -122.4194);
      });
    }
  }

  void _setupMapElements() {
    if (_currentPosition == null || _destinationLatLng == null) return;

    final currentLatLng = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    // Calculate distance
    _distanceInMeters = Geolocator.distanceBetween(
      currentLatLng.latitude,
      currentLatLng.longitude,
      _destinationLatLng!.latitude,
      _destinationLatLng!.longitude,
    );

    // Calculate estimated time (assuming 30 mph average speed)
    final distanceInMiles = _distanceInMeters / 1609.34;
    final timeInMinutes = (distanceInMiles / 30 * 60).round();
    _estimatedTime = '$timeInMinutes min';

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Your Location',
            snippet: 'Rider (${widget.order.restaurant})',
          ),
        ),
        Marker(
          markerId: const MarkerId('destination'),
          position: _destinationLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Delivery Location',
            snippet: widget.order.customerName,
          ),
        ),
      };

      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: [currentLatLng, _destinationLatLng!],
          color: Colors.blue,
          width: 5,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      };
    });
  }

  void _startLocationTracking() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        if (!mounted) return;

        setState(() {
          _currentPosition = position;
        });

        _setupMapElements();

        // Auto-center on rider location
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      } catch (e) {
        debugPrint('Error getting location: $e');
      }
    });
  }

  void _fitMapToBounds() {
    if (_currentPosition == null || _destinationLatLng == null) return;

    final currentLatLng = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    final bounds = LatLngBounds(
      southwest: LatLng(
        currentLatLng.latitude < _destinationLatLng!.latitude
            ? currentLatLng.latitude
            : _destinationLatLng!.latitude,
        currentLatLng.longitude < _destinationLatLng!.longitude
            ? currentLatLng.longitude
            : _destinationLatLng!.longitude,
      ),
      northeast: LatLng(
        currentLatLng.latitude > _destinationLatLng!.latitude
            ? currentLatLng.latitude
            : _destinationLatLng!.latitude,
        currentLatLng.longitude > _destinationLatLng!.longitude
            ? currentLatLng.longitude
            : _destinationLatLng!.longitude,
      ),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  void _centerOnCurrentLocation() {
    if (_currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15,
        ),
      );
    }
  }

  void _centerOnDestination() {
    if (_destinationLatLng != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_destinationLatLng!, 15),
      );
    }
  }

  Future<void> _openInGoogleMaps() async {
    if (_destinationLatLng == null) return;

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}'
      '&travelmode=driving',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open Google Maps'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _callCustomer() async {
    final phoneUrl = Uri.parse('tel:${widget.order.phoneNumber}');
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    }
  }

  void _showPermissionError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs location permission to show navigation. '
          'Please enable location services and grant permission in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await Geolocator.openLocationSettings();
              navigator.pop();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getDistanceText() {
    if (_distanceInMeters < 1000) {
      return '${_distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(_distanceInMeters / 1000).toStringAsFixed(2)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.pink),
              const SizedBox(height: 20),
              const Text(
                'Loading map...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Getting your location',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final initialPosition = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(37.7749, -122.4194); // Default: San Francisco

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (_destinationLatLng != null) {
                _fitMapToBounds();
              }
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
          ),

          // Top Info Card
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.navigation,
                            color: Colors.pink,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${widget.order.id}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.order.customerName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoChip(
                          Icons.straighten,
                          _getDistanceText(),
                          'Distance',
                        ),
                        _buildInfoChip(
                          Icons.access_time,
                          _estimatedTime,
                          'ETA',
                        ),
                        _buildInfoChip(
                          Icons.restaurant,
                          widget.order.restaurant,
                          'From',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Map Controls (Right Side)
          Positioned(
            right: 16,
            top: 220,
            child: Column(
              children: [
                _buildMapButton(
                  icon: Icons.add,
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  icon: Icons.remove,
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                  },
                ),
                const SizedBox(height: 16),
                _buildMapButton(
                  icon: Icons.my_location,
                  onPressed: _centerOnCurrentLocation,
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  icon: Icons.location_on,
                  onPressed: _centerOnDestination,
                  color: Colors.red,
                ),
              ],
            ),
          ),

          // Bottom Action Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 8,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag Handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Delivery Address',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                widget.order.deliveryAddress,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _callCustomer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.phone),
                            label: const Text(
                              'Call Customer',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openInGoogleMaps,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.directions),
                            label: const Text(
                              'Google Maps',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.pink),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color ?? Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color != null ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
