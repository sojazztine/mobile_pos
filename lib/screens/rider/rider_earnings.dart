import 'package:flutter/material.dart';

class RiderEarnings extends StatefulWidget {
  const RiderEarnings({super.key});

  @override
  State<RiderEarnings> createState() => _RiderEarningsState();
}

class _RiderEarningsState extends State<RiderEarnings> {
  String _selectedPeriod = 'Weekly';

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
          'Earnings',
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
              // This Week Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'This Week',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      _buildPeriodTab('Daily', false),
                      const SizedBox(width: 4),
                      _buildPeriodTab('Weekly', true),
                      const SizedBox(width: 4),
                      _buildPeriodTab('Monthly', false),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Earnings Cards
              Row(
                children: [
                  Expanded(
                    child: _buildEarningCard(
                      'Deliveries',
                      '\$250.75',
                      Colors.pink[50]!,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEarningCard(
                      'Tips',
                      '\$50.25',
                      Colors.pink[50]!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bonuses Card
              _buildEarningCard(
                'Bonuses',
                '\$20.00',
                Colors.pink[50]!,
              ),
              const SizedBox(height: 20),

              // Total Earnings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$321.00',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Total Earnings',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Show payout methods
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.pink,
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Payout Methods',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Week Calendar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDayColumn('Mon', false),
                  _buildDayColumn('Tue', false),
                  _buildDayColumn('Wed', false),
                  _buildDayColumn('Thu', false),
                  _buildDayColumn('Fri', true),
                  _buildDayColumn('Sat', false),
                  _buildDayColumn('Sun', false),
                ],
              ),
              const SizedBox(height: 32),

              // Recent Payouts Section
              const Text(
                'Recent Payouts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Payout Items
              _buildPayoutItem(
                amount: '\$320.00',
                date: 'May 18, 2024',
                status: 'Completed',
                statusColor: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildPayoutItem(
                amount: '\$280.00',
                date: 'May 9, 2024',
                status: 'Completed',
                statusColor: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildPayoutItem(
                amount: '\$300.00',
                date: 'May 1, 2024',
                status: 'Completed',
                statusColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildPeriodTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildEarningCard(String label, String amount, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(String day, bool isSelected) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.pink : Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isSelected ? Colors.pink : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildPayoutItem({
    required String amount,
    required String date,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance,
              color: Colors.pink[400],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Status
          Text(
            status,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 1, // Earnings tab
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        backgroundColor: Colors.white,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Deliveries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context); // Go back to deliveries
          }
        },
      ),
    );
  }
}
