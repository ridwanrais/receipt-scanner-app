import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/providers/dashboard_provider.dart';
import '../../core/models/receipt_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<DashboardProvider>(context, listen: false)
            .loadDashboardData(),
        child: Consumer<DashboardProvider>(
          builder: (context, dashboardProvider, _) {
            if (dashboardProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (dashboardProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(dashboardProvider.error!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => dashboardProvider.loadDashboardData(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSpendingOverview(dashboardProvider),
                    const SizedBox(height: 24),
                    _buildSpendingTrendChart(context, dashboardProvider),
                    const SizedBox(height: 24),
                    _buildCategorySpending(context, dashboardProvider),
                    const SizedBox(height: 24),
                    _buildRecentActivities(dashboardProvider),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpendingOverview(DashboardProvider provider) {
    // Format the number with commas
    final formattedAmount = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    ).format(provider.totalMonthlySpending / 1000);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            'Spending Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          formattedAmount,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Row(
          children: [
            Text(
              'Last 6 Months',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '-5%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpendingTrendChart(BuildContext context, DashboardProvider provider) {
    // Sample data for the 6-month chart
    final List<FlSpot> spots = [
      const FlSpot(0, 2800), // Jan
      const FlSpot(1, 2200), // Feb
      const FlSpot(2, 2900), // Mar
      const FlSpot(3, 2300), // Apr
      const FlSpot(4, 3200), // May
      const FlSpot(5, 3000), // Jun
    ];
    
    // Fixed list of months - no duplicates
    const List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: false,
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final int index = value.toInt();
                    if (index >= 0 && index < months.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          months[index],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  reservedSize: 30,
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Theme.of(context).primaryColor,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: Colors.black.withOpacity(0.8),
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '\$${spot.y.toInt()}',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySpending(BuildContext context, DashboardProvider provider) {
    // Mock data for category comparison
    final List<Map<String, dynamic>> categories = [
      {'name': 'Groceries', 'amount': 850.0, 'color': Colors.blue.shade200},
      {'name': 'Dining', 'amount': 450.0, 'color': Colors.orange.shade200},
      {'name': 'Utilities', 'amount': 350.0, 'color': Colors.green.shade200},
      {'name': 'Shopping', 'amount': 600.0, 'color': Colors.purple.shade200},
    ];

    // Find max value for normalizing bar heights
    final maxAmount = categories.map((e) => e['amount'] as double).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spending by Category',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Category Spending Comparison',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const Text(
          'Current Month vs. Previous Month',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        // Wrap the chart in a fixed height container with enough space
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: categories.map((category) {
                  final double normalizedHeight = 55 * (category['amount'] as double) / maxAmount;
                  return Container(
                    width: MediaQuery.of(context).size.width / 4.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 55,
                          height: normalizedHeight,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        Container(
                          height: 1,
                          width: 55,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          category['name'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRecentActivities(DashboardProvider provider) {
    // Mock recent activities data
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'Grocery Purchase',
        'amount': '\$123.45',
        'merchant': 'Supermart',
        'icon': Icons.shopping_basket_outlined,
      },
      {
        'title': 'Dinner with Friends',
        'amount': '\$87.65',
        'merchant': 'Bistro Cafe',
        'icon': Icons.restaurant_outlined,
      },
      {
        'title': 'Utility Payment',
        'amount': '\$200.00',
        'merchant': 'Energy Co.',
        'icon': Icons.bolt_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ...activities.map((activity) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  activity['icon'] as IconData,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${activity['amount']} - ${activity['merchant']}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
}
