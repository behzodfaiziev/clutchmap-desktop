import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/workspace_bloc.dart';
import '../bloc/workspace_state.dart';
import 'round_intelligence_panel.dart';

class MatchIntelligencePanel extends StatelessWidget {
  final String matchId;

  const MatchIntelligencePanel({
    super.key,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceBloc, WorkspaceState>(
      builder: (context, state) {
        if (state is! WorkspaceLoadedState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final matchIntel = state.matchIntel;
        final matchRisk = state.matchRisk;
        final matchRobustness = state.matchRobustness;
        final matchup = state.matchup;

        if (matchIntel == null || matchRisk == null || matchRobustness == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).cardColor,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Match Intelligence",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                // Tactical Scores
                Text(
                  "Tactical Scores",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 8),
                MetricBar(
                  label: "Overall",
                  value: matchIntel.overall,
                  color: Colors.blue,
                ),
                MetricBar(
                  label: "Aggression",
                  value: matchIntel.aggression,
                  color: Colors.redAccent,
                ),
                MetricBar(
                  label: "Structure",
                  value: matchIntel.structure,
                  color: Colors.blueAccent,
                ),
                MetricBar(
                  label: "Variety",
                  value: matchIntel.variety,
                  color: Colors.purpleAccent,
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                // Risk & Robustness
                Text(
                  "Risk & Robustness",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 8),
                MetricBar(
                  label: "Risk",
                  value: matchRisk.risk,
                  color: Colors.orangeAccent,
                ),
                MetricBar(
                  label: "Volatility",
                  value: matchRisk.volatility,
                  color: Colors.purpleAccent,
                ),
                MetricBar(
                  label: "Robustness",
                  value: matchRobustness.robustness,
                  color: Colors.greenAccent,
                ),
                // Opponent Matchup (optional)
                if (matchup != null) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    "Opponent Matchup",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          matchup.predictedAdvantage.replaceAll('_', ' '),
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: matchup.advantageColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Confidence: ${matchup.confidence}%",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}



