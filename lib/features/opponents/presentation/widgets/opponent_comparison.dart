import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/opponent_profile.dart';
import '../../domain/entities/matchup_analysis.dart';
import 'comparison_radar_chart.dart';
import 'gap_analysis_section.dart';
import 'matchup_classification_card.dart';
import 'counter_style_summary.dart';

class OpponentComparison extends StatelessWidget {
  final OpponentProfile teamProfile;
  final OpponentProfile opponentProfile;
  final MatchupAnalysis? matchup;

  const OpponentComparison({
    super.key,
    required this.teamProfile,
    required this.opponentProfile,
    this.matchup,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            opponentProfile.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 32),
          // Radar Comparison
          Text(
            "Tactical Profile Comparison",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ComparisonRadarChart(
            teamProfile: teamProfile,
            opponentProfile: opponentProfile,
          ),
          const SizedBox(height: 32),
          // Gap Analysis
          if (matchup != null) ...[
            GapAnalysisSection(matchup: matchup!),
            const SizedBox(height: 32),
            // Matchup Classification
            MatchupClassificationCard(matchup: matchup!),
            const SizedBox(height: 32),
          ],
          // Counter Style Summary
          CounterStyleSummary(opponentProfile: opponentProfile),
        ],
      ),
    );
  }
}



