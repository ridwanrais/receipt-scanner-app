import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/providers/insights_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Spending Insights',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<InsightsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadInsightsData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadInsightsData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeRangeFilter(context, provider),
                  const SizedBox(height: 24),
                  _buildCategoriesChart(context, provider),
                  const SizedBox(height: 24),
                  _buildSpendingTrends(context, provider),
                  const SizedBox(height: 24),
                  _buildTopMerchants(context, provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeRangeFilter(BuildContext context, InsightsProvider provider) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'weekly',
                  label: Text('Weekly'),
                  icon: Icon(Icons.calendar_view_week),
                ),
                ButtonSegment<String>(
                  value: 'monthly',
                  label: Text('Monthly'),
                  icon: Icon(Icons.calendar_month),
                ),
              ],
              selected: {provider.selectedTimeRange},
              onSelectionChanged: (Set<String> newSelection) {
                provider.setTimeRange(newSelection.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesChart(BuildContext context, InsightsProvider provider) {
    final categories = provider.spendingByCategory;
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    // Colors for the pie chart sections
    final List<Color> categoryColors = [
      Colors.blueAccent,
      Colors.redAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.tealAccent,
      Colors.pinkAccent,
    ];

    // Calculate total for percentages
    final double total = categories.values.fold(0, (sum, value) => sum + value);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  // Pie chart
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: List.generate(
                          categories.length,
                          (index) {
                            final key = categories.keys.elementAt(index);
                            final value = categories.values.elementAt(index);
                            final percentage = total > 0 ? (value / total) * 100 : 0;
                            
                            return PieChartSectionData(
                              color: categoryColors[index % categoryColors.length],
                              value: value,
                              title: '${percentage.toStringAsFixed(1)}%',
                              radius: 100,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Legend
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        categories.length,
                        (index) {
                          final key = categories.keys.elementAt(index);
                          final value = categories.values.elementAt(index);
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: categoryColors[index % categoryColors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    key,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...List.generate(
              categories.length,
              (index) {
                final category = categories.keys.elementAt(index);
                final amount = categories.values.elementAt(index);
                final percentage = total > 0 ? (amount / total * 100).toStringAsFixed(1) : '0.0';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${provider.formatCurrency(amount)} ($percentage%)',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingTrends(BuildContext context, InsightsProvider provider) {
    final trends = provider.monthlyTrends;
    if (trends.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: trends.map((e) => e['amount'] as double).reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.black,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          provider.formatCurrency(rod.toY),
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= trends.length) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              trends[value.toInt()]['month'] as String,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          String text = '${(value / 1000000).toStringAsFixed(1)}M';
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(text, style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    trends.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: trends[index]['amount'] as double,
                          color: Theme.of(context).colorScheme.primary,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopMerchants(BuildContext context, InsightsProvider provider) {
    final topMerchants = provider.getTopMerchants();

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Merchants',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              topMerchants.length,
              (index) {
                final merchant = topMerchants[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade200,
                        child: Text(
                          merchant['name'].toString().substring(0, 1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              merchant['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              provider.formatCurrency(merchant['total'] as double),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.trending_up,
                        color: Colors.green.shade400,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
