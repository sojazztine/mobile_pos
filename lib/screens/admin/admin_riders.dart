import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../widgets/admin/admin_bottom_nav.dart';
import '../../widgets/admin/admin_drawer.dart';
import 'admin_add_rider.dart';
import 'admin_dashboard.dart';

class AdminRiders extends StatefulWidget {
  const AdminRiders({super.key});

  @override
  State<AdminRiders> createState() => _AdminRidersState();
}

class _AdminRidersState extends State<AdminRiders> {
  List<User> _riders = [];
  List<User> _filteredRiders = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRiders();
    _searchController.addListener(_filterRiders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRiders() async {
    setState(() => _isLoading = true);

    final riders = await DatabaseService.instance.getAllRiders();

    setState(() {
      _riders = riders;
      _filterRiders();
      _isLoading = false;
    });
  }

  void _filterRiders() {
    setState(() {
      _filteredRiders = _riders.where((rider) {
        // Apply search filter
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            rider.fullName.toLowerCase().contains(searchQuery) ||
            rider.email.toLowerCase().contains(searchQuery);

        // Apply status filter
        final matchesFilter = _selectedFilter == 'All' ||
            (_selectedFilter == 'Active' && rider.isActive) ||
            (_selectedFilter == 'Inactive' && !rider.isActive);

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  Future<void> _toggleRiderStatus(User rider) async {
    final newStatus = !rider.isActive;
    final success = await DatabaseService.instance.toggleRiderStatus(
      rider.id!,
      newStatus,
    );

    if (success) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? '${rider.fullName} activated successfully'
                : '${rider.fullName} deactivated successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      _loadRiders();
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update rider status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'R';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AdminDrawer(currentPage: 'Riders'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboard(),
              ),
            );
          },
        ),
        title: const Text(
          'Riders',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search riders',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.pink[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterTab('All'),
                const SizedBox(width: 16),
                _buildFilterTab('Active'),
                const SizedBox(width: 16),
                _buildFilterTab('Inactive'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Riders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRiders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No riders found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredRiders.length,
                        itemBuilder: (context, index) {
                          final rider = _filteredRiders[index];
                          return _buildRiderCard(rider);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminAddRider(),
            ),
          );
          if (result == true) {
            _loadRiders();
          }
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 4),
    );
  }


  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
          _filterRiders();
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.pink : Colors.grey,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRiderCard(User rider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.pink[100],
            backgroundImage: rider.profileImage != null
                ? FileImage(File(rider.profileImage!))
                : null,
            child: rider.profileImage == null
                ? Text(
                    _getInitials(rider.fullName),
                    style: TextStyle(
                      color: Colors.pink[700],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Rider Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rider.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rider.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: rider.isActive ? Colors.green[600] : Colors.red[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Toggle Switch and Menu
          Row(
            children: [
              Switch(
                value: rider.isActive,
                onChanged: (value) {
                  _showToggleConfirmation(rider);
                },
                activeTrackColor: Colors.green,
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                onSelected: (value) {
                  if (value == 'toggle') {
                    _showToggleConfirmation(rider);
                  } else if (value == 'details') {
                    _showRiderDetails(rider);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(rider.isActive ? 'Deactivate' : 'Activate'),
                  ),
                  const PopupMenuItem(
                    value: 'details',
                    child: Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showToggleConfirmation(User rider) {
    final newStatus = !rider.isActive;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newStatus ? 'Activate Rider' : 'Deactivate Rider'),
        content: Text(
          newStatus
              ? 'Are you sure you want to activate ${rider.fullName}?'
              : 'Are you sure you want to deactivate ${rider.fullName}? They will not be able to access their account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _toggleRiderStatus(rider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(newStatus ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showRiderDetails(User rider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(rider.fullName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', rider.email),
            const SizedBox(height: 8),
            _buildDetailRow('Phone', rider.phone),
            const SizedBox(height: 8),
            _buildDetailRow('Address', rider.address),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Status',
              rider.isActive ? 'Active' : 'Inactive',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Joined',
              '${rider.createdAt.day}/${rider.createdAt.month}/${rider.createdAt.year}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

}
