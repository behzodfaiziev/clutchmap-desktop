import 'package:flutter/material.dart';
import '../../domain/entities/meta_alignment.dart';

class MetaAlignmentSection extends StatelessWidget {
  final MetaAlignment alignment;

  const MetaAlignmentSection({
    super.key,
    required this.alignment,
  });

  Color _getAlignmentColor(int score) {
    if (score > 70) {
      return Colors.green;
    } else if (score > 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Alignment Score: ${alignment.alignmentScore}",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getAlignmentColor(alignment.alignmentScore),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    alignment.alignmentScore > 70
                        ? "Aligned"
                        : alignment.alignmentScore > 50
                            ? "Moderate"
                            : "Misaligned",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: alignment.alignmentScore / 100.0,
              color: _getAlignmentColor(alignment.alignmentScore),
              backgroundColor: Colors.grey.shade700,
              minHeight: 8,
            ),
            const SizedBox(height: 24),
            Text(
              "Gaps",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 12),
            _GapRow(label: "Aggression Gap", value: alignment.aggressionGap),
            _GapRow(label: "Structure Gap", value: alignment.structureGap),
            _GapRow(label: "Variety Gap", value: alignment.varietyGap),
            _GapRow(label: "Risk Gap", value: alignment.riskGap),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade900.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alignment.explanation.isNotEmpty
                          ? alignment.explanation
                          : "No explanation available",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GapRow extends StatelessWidget {
  final String label;
  final int value;

  const _GapRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value > 0 ? "+$value" : "$value",
            style: TextStyle(
              color: value > 0 ? Colors.green : value < 0 ? Colors.red : Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}



