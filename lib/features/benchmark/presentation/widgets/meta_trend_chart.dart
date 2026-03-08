import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/meta_trend_point.dart';
import '../bloc/benchmark_bloc.dart';
import '../bloc/benchmark_event.dart';

class MetaTrendChart extends StatelessWidget {
  final List<MetaTrendPoint> trends;
  final int window;

  const MetaTrendChart({
    super.key,
    required this.trends,
    required this.window,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Meta Trend ($window days)",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ToggleButtons(
                  isSelected: [window == 7, window == 30],
                  onPressed: (index) {
                    final newWindow = index == 0 ? 7 : 30;
                    context.read<BenchmarkBloc>().add(
                          MetaTrendsWindowChanged(newWindow),
                        );
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("7 days"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("30 days"),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: trends.isEmpty
                  ? const Center(
                      child: Text(
                        "No trend data available",
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 20,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.white24,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
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
                                // Format date if needed
                                return Text(
                                  '',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.white24),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: trends.map((e) {
                              return FlSpot(
                                e.date.millisecondsSinceEpoch.toDouble(),
                                e.aggression.toDouble(),
                              );
                            }).toList(),
                            isCurved: true,
                            color: Colors.redAccent,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.redAccent.withValues(alpha: 0.1),
                            ),
                          ),
                          LineChartBarData(
                            spots: trends.map((e) {
                              return FlSpot(
                                e.date.millisecondsSinceEpoch.toDouble(),
                                e.risk.toDouble(),
                              );
                            }).toList(),
                            isCurved: true,
                            color: Colors.orangeAccent,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.orangeAccent.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _LegendItem(color: Colors.redAccent, label: "Aggression"),
                const SizedBox(width: 16),
                _LegendItem(color: Colors.orangeAccent, label: "Risk"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

