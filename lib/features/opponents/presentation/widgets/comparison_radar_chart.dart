import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/opponent_profile.dart';

class ComparisonRadarChart extends StatelessWidget {
  final OpponentProfile teamProfile;
  final OpponentProfile opponentProfile;

  const ComparisonRadarChart({
    super.key,
    required this.teamProfile,
    required this.opponentProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      dataEntries: [
                        RadarEntry(value: teamProfile.aggression.toDouble()),
                        RadarEntry(value: teamProfile.structure.toDouble()),
                        RadarEntry(value: teamProfile.variety.toDouble()),
                        RadarEntry(value: teamProfile.risk.toDouble()),
                      ],
                      fillColor: Colors.blue.withValues(alpha: 0.4),
                      borderColor: Colors.blueAccent,
                      borderWidth: 2,
                    ),
                    RadarDataSet(
                      dataEntries: [
                        RadarEntry(value: opponentProfile.aggression.toDouble()),
                        RadarEntry(value: opponentProfile.structure.toDouble()),
                        RadarEntry(value: opponentProfile.variety.toDouble()),
                        RadarEntry(value: opponentProfile.risk.toDouble()),
                      ],
                      fillColor: Colors.red.withValues(alpha: 0.3),
                      borderColor: Colors.redAccent,
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: Colors.blueAccent, label: "Your Team"),
                const SizedBox(width: 24),
                _LegendItem(color: Colors.redAccent, label: "Opponent"),
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



