import 'package:flutter/material.dart';
import '../../domain/entities/comparison_result.dart';

class RoundDiffCard extends StatelessWidget {
  final RoundDiff diff;

  const RoundDiffCard({
    super.key,
    required this.diff,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Round ${diff.roundNumber}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (diff.notesChanged)
              _DiffItem(
                icon: Icons.note,
                label: "Notes changed",
                color: Colors.blue,
              ),
            if (diff.buyChanged)
              _DiffItem(
                icon: Icons.shopping_cart,
                label: "Buy changed",
                color: Colors.orange,
              ),
            if (diff.eventsAdded.isNotEmpty)
              _DiffItem(
                icon: Icons.add_circle,
                label: "Added: ${diff.eventsAdded.join(", ")}",
                color: Colors.green,
              ),
            if (diff.eventsRemoved.isNotEmpty)
              _DiffItem(
                icon: Icons.remove_circle,
                label: "Removed: ${diff.eventsRemoved.join(", ")}",
                color: Colors.red,
              ),
          ],
        ),
      ),
    );
  }
}

class _DiffItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DiffItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

