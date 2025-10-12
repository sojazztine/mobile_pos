import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_model.dart';
import '../../services/database_service.dart';

class RiderEarnings extends StatefulWidget {
  const RiderEarnings({super.key});

  @override
  State<RiderEarnings> createState() => _RiderEarningsState();
}

class _RiderEarningsState extends State<RiderEarnings> {
  String selectedPeriod = 'week';
  bool isLoading = true;
  Map<String, dynamic> earningsData = {
    'deliveries': 0.0,
    'tips': 0.0,
    'bonuses': 0.0,
    'total': 0.0,
    'deliveryCount': 0,
  };
  List<Map<String, dynamic>> dailyEarnings = [];
  List<Map<String, dynamic>> payouts = [];

  @override
  void initState() {
    super.initState();
    _loadEarningsData();
  }

  Future<void> _loadEarningsData() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    final riderId = authModel.currentUser?.id;

    if (riderId == null) return;

    setState(() {
      isLoading = true;
    });

    final db = DatabaseService.instance;

    // Load earnings for selected period
    final earnings = await db.getRiderEarnings(riderId, period: selectedPeriod);
    final daily = await db.getRiderDailyEarnings(riderId);
    final payoutsList = await db.getRiderPayouts(riderId, limit: 3);

    if (mounted) {
      setState(() {
        earningsData = earnings;
        dailyEarnings = daily;
        payouts = payoutsList;
        isLoading = false;
      });
    }
  }

  void _changePeriod(String period) {
    setState(() {
      selectedPeriod = period;
    });
    _loadEarningsData();
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // This Week Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedPeriod == 'day'
                        ? 'Today'
                        : selectedPeriod == 'week'
                            ? 'This Week'
                            : 'This Month',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      _buildPeriodTab('Daily', selectedPeriod == 'day'),
                      const SizedBox(width: 4),
                      _buildPeriodTab('Weekly', selectedPeriod == 'week'),
                      const SizedBox(width: 4),
                      _buildPeriodTab('Monthly', selectedPeriod == 'month'),
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
                      '\$${(earningsData['deliveries'] as double).toStringAsFixed(2)}',
                      Colors.pink[50]!,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEarningCard(
                      'Tips',
                      '\$${(earningsData['tips'] as double).toStringAsFixed(2)}',
                      Colors.pink[50]!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bonuses Card
              _buildEarningCard(
                'Bonuses',
                '\$${(earningsData['bonuses'] as double).toStringAsFixed(2)}',
                Colors.pink[50]!,
              ),
              const SizedBox(height: 20),

              // Total Earnings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${(earningsData['total'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Total Earnings (${earningsData['deliveryCount']} deliveries)',
                        style: const TextStyle(
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
              if (selectedPeriod == 'week' && dailyEarnings.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: dailyEarnings.map((dayData) {
                    final isToday = dayData['date'].day == DateTime.now().day &&
                        dayData['date'].month == DateTime.now().month;
                    return _buildDayColumn(
                      dayData['day'],
                      isToday,
                      dayData['deliveries'],
                    );
                  }).toList(),
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
              if (payouts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No payouts yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                ...payouts.map((payout) {
                  final date = payout['date'] as DateTime;
                  final dateStr = '${_getMonthName(date.month)} ${date.day}, ${date.year}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildPayoutItem(
                      amount: '\$${payout['amount'].toStringAsFixed(2)}',
                      date: dateStr,
                      status: payout['status'],
                      statusColor: Colors.green,
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (label == 'Daily') {
          _changePeriod('day');
        } else if (label == 'Weekly') {
          _changePeriod('week');
        } else if (label == 'Monthly') {
          _changePeriod('month');
        }
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

  Widget _buildDayColumn(String day, bool isSelected, int deliveryCount) {
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
          width: deliveryCount > 0 ? 10 : 8,
          height: deliveryCount > 0 ? 10 : 8,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.pink
                : deliveryCount > 0
                    ? Colors.pink.withValues(alpha: 0.3)
                    : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
        if (deliveryCount > 0) ...[
          const SizedBox(height: 4),
          Text(
            '$deliveryCount',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
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

}
