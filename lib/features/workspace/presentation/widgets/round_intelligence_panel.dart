import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/workspace_bloc.dart';
import '../bloc/workspace_state.dart';

class RoundIntelligencePanel extends StatelessWidget {
  final String roundId;

  const RoundIntelligencePanel({
    super.key,
    required this.roundId,
  });

  int? _computeDelta(int? current, int? previous) {
    if (current == null || previous == null) return null;
    return current - previous;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceBloc, WorkspaceState>(
      builder: (context, state) {
        if (state is! WorkspaceLoadedState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final intelligence = state.getRoundIntelligence(roundId);
        final previousIntelligence = state.getPreviousIntelligence(roundId);

        if (intelligence == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Round Intelligence",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              MetricBar(
                label: "Aggression",
                value: intelligence.aggression,
                color: Colors.redAccent,
                delta: _computeDelta(
                  intelligence.aggression,
                  previousIntelligence?.aggression,
                ),
              ),
              MetricBar(
                label: "Structure",
                value: intelligence.structure,
                color: Colors.blueAccent,
                delta: _computeDelta(
                  intelligence.structure,
                  previousIntelligence?.structure,
                ),
              ),
              MetricBar(
                label: "Risk",
                value: intelligence.risk,
                color: Colors.orangeAccent,
                delta: _computeDelta(
                  intelligence.risk,
                  previousIntelligence?.risk,
                ),
              ),
              MetricBar(
                label: "Volatility",
                value: intelligence.volatility,
                color: Colors.purpleAccent,
                delta: _computeDelta(
                  intelligence.volatility,
                  previousIntelligence?.volatility,
                ),
              ),
              MetricBar(
                label: "Economy Risk",
                value: intelligence.economyRisk,
                color: Colors.greenAccent,
                delta: _computeDelta(
                  intelligence.economyRisk,
                  previousIntelligence?.economyRisk,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MetricBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final int? delta;

  const MetricBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.delta,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$label ($value)",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            if (delta != null)
              Text(
                delta! > 0 ? "+$delta" : "$delta",
                style: TextStyle(
                  color: delta! > 0 ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100.0,
          color: color,
          backgroundColor: Colors.grey.shade800,
          minHeight: 8,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

