import 'package:flutter/material.dart';
import '../../domain/entities/matchup_analysis.dart';

class MatchupClassificationCard extends StatelessWidget {
  final MatchupAnalysis matchup;

  const MatchupClassificationCard({
    super.key,
    required this.matchup,
  });

  Color _getAdvantageColor(String advantage) {
    switch (advantage) {
      case 'CONTROL_ADVANTAGE':
        return Colors.green;
      case 'PACE_ADVANTAGE':
        return Colors.blue;
      case 'EVEN_MATCH':
        return Colors.orange;
      case 'UNCERTAIN':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _formatAdvantage(String advantage) {
    return advantage
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

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
              "Predicted Matchup",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Chip(
              label: Text(
                _formatAdvantage(matchup.predictedAdvantage),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: _getAdvantageColor(matchup.predictedAdvantage),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Team Advantage Score:",
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  "${matchup.teamAdvantageScore}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Opponent Advantage Score:",
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  "${matchup.opponentAdvantageScore}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



