import 'package:flutter/material.dart';
import '../../domain/entities/opponent_profile.dart';

class CounterStyleSummary extends StatelessWidget {
  final OpponentProfile opponentProfile;

  const CounterStyleSummary({
    super.key,
    required this.opponentProfile,
  });

  String _counterSummary(OpponentProfile opponent) {
    if (opponent.aggression > 75) {
      return "Opponent favors high-tempo play. Consider structured setups and mid-round slows.";
    }

    if (opponent.structure > 70) {
      return "Opponent highly structured. Introduce tempo variation and fakes.";
    }

    if (opponent.risk > 65) {
      return "Opponent plays volatile rounds. Stabilize and punish overextensions.";
    }

    return "Balanced opponent. Focus on small tactical edges.";
  }

  @override
  Widget build(BuildContext context) {
    final summary = _counterSummary(opponentProfile);

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
                  "Counter-Style Summary",
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
                color: Colors.blue.shade900.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                summary,
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



