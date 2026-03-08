import 'package:flutter/material.dart';
import '../../domain/entities/matchup_analysis.dart';

class GapAnalysisSection extends StatelessWidget {
  final MatchupAnalysis matchup;

  const GapAnalysisSection({
    super.key,
    required this.matchup,
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
            Text(
              "Gap Analysis",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _GapRow(label: "Aggression", delta: matchup.aggressionGap),
            _GapRow(label: "Structure", delta: matchup.structureGap),
            _GapRow(label: "Variety", delta: matchup.varietyGap),
          ],
        ),
      ),
    );
  }
}

class _GapRow extends StatelessWidget {
  final String label;
  final int delta;

  const _GapRow({
    required this.label,
    required this.delta,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            delta > 0 ? "+$delta" : "$delta",
            style: TextStyle(
              color: delta > 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}



