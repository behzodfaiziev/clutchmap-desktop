import 'package:flutter/material.dart';
import '../../domain/entities/comparison_result.dart';

class InsightSummary extends StatelessWidget {
  final ComparisonResult result;

  const InsightSummary({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights();

    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  "Insights",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...insights.map((insight) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "• $insight",
                    style: const TextStyle(fontSize: 14),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  List<String> _generateInsights() {
    final insights = <String>[];

    if (result.aggressionDelta > 10 && result.riskDelta > 10) {
      insights.add("Plan B is significantly more aggressive and higher risk.");
    } else if (result.aggressionDelta < -10 && result.riskDelta < -10) {
      insights.add("Plan B is significantly less aggressive and lower risk.");
    }

    if (result.structureDelta > 10 && result.riskDelta < 0) {
      insights.add("Plan B is more structured and stable.");
    } else if (result.structureDelta < -10 && result.riskDelta > 0) {
      insights.add("Plan B is less structured and more volatile.");
    }

    if (result.varietyDelta > 10) {
      insights.add("Plan B has more tactical variety.");
    } else if (result.varietyDelta < -10) {
      insights.add("Plan B has less tactical variety.");
    }

    if (result.overallDelta > 10) {
      insights.add("Plan B shows overall improvement in tactical score.");
    } else if (result.overallDelta < -10) {
      insights.add("Plan B shows overall decline in tactical score.");
    }

    return insights;
  }
}


