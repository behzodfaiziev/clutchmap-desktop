import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/team_snapshot.dart';
import '../bloc/benchmark_bloc.dart';
import '../bloc/benchmark_event.dart';

class EvolutionComparisonSection extends StatelessWidget {
  final List<TeamSnapshot> snapshots;
  final int window;

  const EvolutionComparisonSection({
    super.key,
    required this.snapshots,
    required this.window,
  });

  TeamSnapshot? get _oldestSnapshot {
    if (snapshots.isEmpty) return null;
    return snapshots.first;
  }

  TeamSnapshot? get _newestSnapshot {
    if (snapshots.isEmpty) return null;
    return snapshots.last;
  }

  String _detectShift(TeamSnapshot oldSnap, TeamSnapshot newSnap) {
    final aggressionDelta = newSnap.aggression - oldSnap.aggression;
    final structureDelta = newSnap.structure - oldSnap.structure;
    final riskDelta = newSnap.risk - oldSnap.risk;
    final varietyDelta = newSnap.variety - oldSnap.variety;

    if (aggressionDelta > 10 && riskDelta > 10) {
      return "Shift toward high-tempo, high-risk playstyle";
    }

    if (structureDelta > 10 && riskDelta < -5) {
      return "Shift toward structured stability";
    }

    if (aggressionDelta < -10) {
      return "Shift toward slower tempo";
    }

    if (varietyDelta > 10) {
      return "Shift toward increased tactical variety";
    }

    return "Minor tactical adjustments";
  }

  @override
  Widget build(BuildContext context) {
    if (snapshots.length < 2) {
      return Card(
        color: Colors.grey.shade800,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              "Not enough snapshot data for comparison",
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ),
      );
    }

    final oldest = _oldestSnapshot!;
    final newest = _newestSnapshot!;
    final shift = _detectShift(oldest, newest);

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
                  "Evolution Comparison ($window Days)",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ToggleButtons(
                  isSelected: [window == 7, window == 30, window == 90],
                  onPressed: (index) {
                    final newWindow = [7, 30, 90][index];
                    context.read<BenchmarkBloc>().add(SnapshotWindowChanged(newWindow));
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("7 Days"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("30 Days"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("90 Days"),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _EvolutionRow(
              label: "Aggression",
              before: oldest.aggression,
              after: newest.aggression,
            ),
            _EvolutionRow(
              label: "Structure",
              before: oldest.structure,
              after: newest.structure,
            ),
            _EvolutionRow(
              label: "Variety",
              before: oldest.variety,
              after: newest.variety,
            ),
            _EvolutionRow(
              label: "Risk",
              before: oldest.risk,
              after: newest.risk,
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade900.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, color: Colors.blueAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      shift,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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

class _EvolutionRow extends StatelessWidget {
  final String label;
  final int before;
  final int after;

  const _EvolutionRow({
    required this.label,
    required this.before,
    required this.after,
  });

  @override
  Widget build(BuildContext context) {
    final delta = after - before;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Text(
            "$before → $after",
            style: const TextStyle(color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: delta > 0
                  ? Colors.green.withValues(alpha: 0.2)
                  : delta < 0
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              delta > 0 ? "+$delta" : "$delta",
              style: TextStyle(
                color: delta > 0
                    ? Colors.green
                    : delta < 0
                        ? Colors.red
                        : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

