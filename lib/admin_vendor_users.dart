import 'package:flutter/material.dart';
import 'dart:io';
import 'models/user_model.dart';
import 'database/database_helper.dart';
import 'components/admin_bottom_nav.dart';
import 'components/admin_drawer.dart';
import 'admin_add_vendor.dart';
import 'admin_dashboard.dart';

class AdminVendorUsers extends StatefulWidget {
  const AdminVendorUsers({super.key});

  @override
  State<AdminVendorUsers> createState() => _AdminVendorUsersState();
}

class _AdminVendorUsersState extends State<AdminVendorUsers> {
  List<User> _vendors = [];
  List<User> _filteredVendors = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVendors();
    _searchController.addListener(_filterVendors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVendors() async {
    setState(() => _isLoading = true);

    final vendors = await DatabaseHelper.instance.getAllVendors();

    setState(() {
      _vendors = vendors;
      _filterVendors();
      _isLoading = false;
    });
  }

  void _filterVendors() {
    setState(() {
      _filteredVendors = _vendors.where((vendor) {
        // Apply search filter
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            vendor.fullName.toLowerCase().contains(searchQuery) ||
            vendor.email.toLowerCase().contains(searchQuery);

        // Apply status filter
        final matchesFilter = _selectedFilter == 'All' ||
            (_selectedFilter == 'Active' && vendor.isActive) ||
            (_selectedFilter == 'Inactive' && !vendor.isActive);

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  Future<void> _toggleVendorStatus(User vendor) async {
    final newStatus = !vendor.isActive;
    final success = await DatabaseHelper.instance.toggleVendorStatus(
      vendor.id!,
      newStatus,
    );

    if (success) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? '${vendor.fullName} activated successfully'
                : '${vendor.fullName} deactivated successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      _loadVendors();
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update vendor status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'V';
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
      drawer: const AdminDrawer(currentPage: 'Vendors'),
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
          'Users',
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
                hintText: 'Search users',
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

          // Vendors List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredVendors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No vendors found',
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
                        itemCount: _filteredVendors.length,
                        itemBuilder: (context, index) {
                          final vendor = _filteredVendors[index];
                          return _buildVendorCard(vendor);
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
              builder: (context) => const AdminAddVendor(),
            ),
          );
          if (result == true) {
            _loadVendors();
          }
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 3),
    );
  }


  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
          _filterVendors();
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

  Widget _buildVendorCard(User vendor) {
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
            backgroundImage: vendor.profileImage != null
                ? FileImage(File(vendor.profileImage!))
                : null,
            child: vendor.profileImage == null
                ? Text(
                    _getInitials(vendor.fullName),
                    style: TextStyle(
                      color: Colors.pink[700],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Vendor Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vendor.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: vendor.isActive ? Colors.green[600] : Colors.red[600],
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
                value: vendor.isActive,
                onChanged: (value) {
                  _showToggleConfirmation(vendor);
                },
                activeTrackColor: Colors.green,
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                onSelected: (value) {
                  if (value == 'toggle') {
                    _showToggleConfirmation(vendor);
                  } else if (value == 'details') {
                    _showVendorDetails(vendor);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(vendor.isActive ? 'Deactivate' : 'Activate'),
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

  void _showToggleConfirmation(User vendor) {
    final newStatus = !vendor.isActive;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newStatus ? 'Activate Vendor' : 'Deactivate Vendor'),
        content: Text(
          newStatus
              ? 'Are you sure you want to activate ${vendor.fullName}?'
              : 'Are you sure you want to deactivate ${vendor.fullName}? They will not be able to access their account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _toggleVendorStatus(vendor);
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

  void _showVendorDetails(User vendor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vendor.fullName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', vendor.email),
            const SizedBox(height: 8),
            _buildDetailRow('Phone', vendor.phone),
            const SizedBox(height: 8),
            _buildDetailRow('Address', vendor.address),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Status',
              vendor.isActive ? 'Active' : 'Inactive',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Joined',
              '${vendor.createdAt.day}/${vendor.createdAt.month}/${vendor.createdAt.year}',
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
