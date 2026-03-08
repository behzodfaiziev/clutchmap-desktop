import 'package:flutter/material.dart';
import '../../domain/entities/benchmark_data.dart';

class PercentileCards extends StatelessWidget {
  final BenchmarkData benchmark;

  const PercentileCards({
    super.key,
    required this.benchmark,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _PercentileCard(
          label: "Aggression",
          percentile: benchmark.aggressionPercentile,
          score: benchmark.aggression,
        ),
        _PercentileCard(
          label: "Structure",
          percentile: benchmark.structurePercentile,
          score: benchmark.structure,
        ),
        _PercentileCard(
          label: "Variety",
          percentile: benchmark.varietyPercentile,
          score: benchmark.variety,
        ),
        _PercentileCard(
          label: "Risk",
          percentile: benchmark.riskPercentile,
          score: benchmark.risk,
        ),
      ],
    );
  }
}

class _PercentileCard extends StatelessWidget {
  final String label;
  final int percentile;
  final int score;

  const _PercentileCard({
    required this.label,
    required this.percentile,
    required this.score,
  });

  Color _getPercentileColor(int percentile) {
    if (percentile >= 80) {
      return Colors.green;
    } else if (percentile >= 50) {
      return Colors.blue;
    } else {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPercentileColor(percentile);
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "$percentile%",
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Score: $score",
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

