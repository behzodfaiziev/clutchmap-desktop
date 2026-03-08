import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/benchmark_data.dart';

class TacticalRadarChart extends StatelessWidget {
  final BenchmarkData benchmark;

  const TacticalRadarChart({
    super.key,
    required this.benchmark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: 300,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                RadarDataSet(
                  dataEntries: [
                    RadarEntry(value: benchmark.aggression.toDouble()),
                    RadarEntry(value: benchmark.structure.toDouble()),
                    RadarEntry(value: benchmark.variety.toDouble()),
                    RadarEntry(value: benchmark.risk.toDouble()),
                  ],
                  fillColor: Colors.blue.withOpacity(0.4),
                  borderColor: Colors.blueAccent,
                  borderWidth: 2,
                ),
              ],
              radarBackgroundColor: Colors.transparent,
              tickCount: 5,
              ticksTextStyle: const TextStyle(color: Colors.white70, fontSize: 10),
              radarBorderData: BorderSide(color: Colors.white24),
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              getTitle: (index, angle) {
                const titles = ['Aggression', 'Structure', 'Variety', 'Risk'];
                return RadarChartTitle(
                  text: titles[index],
                  angle: angle,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

