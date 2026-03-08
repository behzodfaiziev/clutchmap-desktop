import 'package:flutter/material.dart';
import '../../domain/entities/benchmark_data.dart';
import '../../domain/entities/meta_alignment.dart';

class InterpretationSection extends StatelessWidget {
  final BenchmarkData benchmark;
  final MetaAlignment alignment;

  const InterpretationSection({
    super.key,
    required this.benchmark,
    required this.alignment,
  });

  String _generateInsight() {
    final insights = <String>[];

    if (benchmark.aggressionPercentile > 80 && benchmark.riskPercentile > 75) {
      insights.add("You are among the most aggressive teams on platform.");
    }

    if (alignment.alignmentScore < 50) {
      insights.add("Your style is significantly misaligned with current meta.");
    } else if (alignment.alignmentScore > 70) {
      insights.add("Your style is well-aligned with current meta.");
    }

    if (benchmark.structurePercentile < 40) {
      insights.add("Your structure score is below average.");
    }

    if (benchmark.varietyPercentile > 70) {
      insights.add("You show high tactical variety.");
    }

    return insights.isEmpty
        ? "Your team profile is balanced."
        : insights.join(" ");
  }

  @override
  Widget build(BuildContext context) {
    final insight = _generateInsight();

    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.yellow),
                const SizedBox(width: 8),
                Text(
                  "Insights",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade900.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                insight,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



