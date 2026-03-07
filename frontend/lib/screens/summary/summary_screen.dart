import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/api_config.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  Map<String, dynamic>? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() => _loading = true);
    try {
      final response = await ApiClient().get(ApiConfig.weeklySummary);
      if (response.statusCode == 200) {
        setState(() => _summary = jsonDecode(response.body));
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Summary')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _summary == null
              ? const Center(child: Text('Could not load summary'))
              : RefreshIndicator(
                  onRefresh: _fetchSummary,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Overview card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('This Week', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _StatTile('Spent', '\$${(_summary!['total_spending'] as num).toStringAsFixed(2)}'),
                                  _StatTile('Weekly Left', '\$${(_summary!['remaining_weekly_budget'] as num).toStringAsFixed(2)}'),
                                  _StatTile('Monthly Left', '\$${(_summary!['remaining_monthly_budget'] as num).toStringAsFixed(2)}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Insight
                      Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_summary!['insight'])),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Category pie chart
                      Text('Spending by Category', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: _buildPieChart(),
                      ),
                      const SizedBox(height: 24),

                      // Daily bar chart
                      Text('Daily Spending', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: _buildBarChart(),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPieChart() {
    final categories = (_summary!['category_breakdown'] as List);
    if (categories.isEmpty) return const Center(child: Text('No data'));

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.pink,
    ];

    return PieChart(
      PieChartData(
        sections: categories.asMap().entries.map((entry) {
          final i = entry.key;
          final cat = entry.value;
          return PieChartSectionData(
            value: (cat['total'] as num).toDouble(),
            title: '${cat['category']}\n${(cat['percentage'] as num).toStringAsFixed(0)}%',
            color: colors[i % colors.length],
            radius: 80,
            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildBarChart() {
    final days = (_summary!['daily_spending'] as List);
    if (days.isEmpty) return const Center(child: Text('No data'));

    return BarChart(
      BarChartData(
        barGroups: days.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: (entry.value['total'] as num).toDouble(),
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                if (value.toInt() < days.length) {
                  final date = days[value.toInt()]['date'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(date.substring(5), style: const TextStyle(fontSize: 10)),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
