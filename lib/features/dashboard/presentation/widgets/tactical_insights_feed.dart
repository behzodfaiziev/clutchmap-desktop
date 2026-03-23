import 'package:flutter/material.dart';
import '../../domain/entities/team_insight.dart';

/// Tactical intelligence feed (Day 132) on the team dashboard.
class TacticalInsightsFeed extends StatelessWidget {
  final String teamId;
  final List<TeamInsight> insights;
  final VoidCallback onRefresh;
  final void Function(String insightId) onDismiss;

  const TacticalInsightsFeed({
    super.key,
    required this.teamId,
    required this.insights,
    required this.onRefresh,
    required this.onDismiss,
  });

  Color _severityColor(int s) {
    if (s >= 70) return Colors.orangeAccent;
    if (s >= 45) return Colors.amber;
    return Colors.greenAccent;
  }

  IconData _categoryIcon(String c) {
    switch (c) {
      case 'REGRESSION':
        return Icons.trending_down;
      case 'IMPROVEMENT':
        return Icons.trending_up;
      case 'DRIFT':
        return Icons.shuffle;
      case 'ANOMALY':
        return Icons.warning_amber_outlined;
      default:
        return Icons.lightbulb_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Tactical intelligence feed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Refresh insights'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (insights.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.insights, color: Colors.white38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No active insights yet. Tap "Refresh insights" to run detection from your team profile.',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...insights.map((i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                color: Colors.grey.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(_categoryIcon(i.category), size: 22, color: _severityColor(i.severity)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              i.headline,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _severityColor(i.severity).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Severity ${i.severity}',
                              style: TextStyle(
                                fontSize: 11,
                                color: _severityColor(i.severity),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            tooltip: 'Dismiss',
                            onPressed: () => onDismiss(i.id),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        i.description,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        i.category.replaceAll('_', ' '),
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
