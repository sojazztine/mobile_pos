import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'components/admin_bottom_nav.dart';
import 'components/admin_drawer.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AdminDrawer(currentPage: 'Dashboard'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sales Performance Section
            const Text(
              'Sales Performance',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '\$12,345',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'This Month',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            // Chart
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[value.toInt()],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(1, 5),
                        const FlSpot(2, 3.5),
                        const FlSpot(3, 6),
                        const FlSpot(4, 4),
                        const FlSpot(5, 7),
                        const FlSpot(6, 5),
                      ],
                      isCurved: true,
                      color: Colors.pink,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.pink.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Overview Section
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Top Selling
            _buildOverviewItem(
              context,
              icon: Icons.fastfood,
              iconColor: Colors.orange[100]!,
              iconBgColor: Colors.orange[50]!,
              title: 'TOP SELLING',
              subtitle: 'Chicken Sandwich',
              trailing: '120 sold',
              imageUrl: 'assets/burger.png', // You can add image later
            ),

            const SizedBox(height: 12),

            // Low Stock
            _buildOverviewItem(
              context,
              icon: Icons.inventory_2_outlined,
              iconColor: Colors.yellow[700]!,
              iconBgColor: Colors.yellow[50]!,
              title: 'LOW STOCK',
              subtitle: 'Fries',
              trailing: '10 remaining',
              imageUrl: 'assets/fries.png',
            ),

            const SizedBox(height: 12),

            // Active Vendors
            _buildOverviewItem(
              context,
              icon: Icons.store_outlined,
              iconColor: Colors.brown[400]!,
              iconBgColor: Colors.brown[50]!,
              title: 'ACTIVE VENDORS',
              subtitle: 'Vendor A',
              trailing: 'Active',
              imageUrl: 'assets/vendor.png',
            ),

            const SizedBox(height: 12),

            // Pending Orders
            _buildOverviewItem(
              context,
              icon: Icons.shopping_bag_outlined,
              iconColor: Colors.red[400]!,
              iconBgColor: Colors.red[50]!,
              title: 'PENDING ORDERS',
              subtitle: 'Rider 1',
              trailing: 'Ready',
              imageUrl: 'assets/rider.png',
            ),

            const SizedBox(height: 80), // Space for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }

  Widget _buildOverviewItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String trailing,
    String? imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Icon/Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 12),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  trailing,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Arrow
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

}
