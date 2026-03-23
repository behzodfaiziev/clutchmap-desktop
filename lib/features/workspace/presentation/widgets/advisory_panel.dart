import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/workspace_bloc.dart';
import '../bloc/workspace_event.dart';
import '../bloc/workspace_state.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/optimize_mode.dart';
import '../../domain/entities/recommendation_history_item.dart';
import '../../domain/entities/recommendation_impact.dart';
import '../../domain/entities/advisor_performance.dart';

class AdvisoryPanel extends StatefulWidget {
  final String matchId;

  const AdvisoryPanel({
    super.key,
    required this.matchId,
  });

  @override
  State<AdvisoryPanel> createState() => _AdvisoryPanelState();
}

class _AdvisoryPanelState extends State<AdvisoryPanel> {
  OptimizeMode _selectedMode = OptimizeMode.safe;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkspaceBloc, WorkspaceState>(
      listenWhen: (prev, curr) {
        if (curr is! WorkspaceLoadedState) return false;
        final preview = curr.recommendationPreview;
        return preview != null && preview.isNotEmpty;
      },
      listener: (context, state) {
        final s = state as WorkspaceLoadedState;
        final preview = s.recommendationPreview!;
        final entry = preview.entries.first;
        if (!context.mounted) return;
        context.read<WorkspaceBloc>().add(const ClearRecommendationPreview());
        showDialog<void>(
          context: context,
          builder: (ctx) => _PreviewApplyDialog(
            recommendationId: entry.key,
            data: entry.value,
          ),
        );
      },
      buildWhen: (prev, curr) => true,
      builder: (context, state) {
        if (state is! WorkspaceLoadedState) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).cardColor,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Advisory Engine",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                if (state.match.archived) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: Colors.orange.shade300),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Archived matches are read-only. Simulate and Optimize are disabled.",
                            style: TextStyle(
                              color: Colors.orange.shade300,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Simulate Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.advisoryLoading || state.match.archived
                        ? null
                        : () {
                            context.read<WorkspaceBloc>().add(
                                  SimulateRequested(widget.matchId),
                                );
                          },
                    child: const Text("Simulate Matchup"),
                  ),
                ),
                const SizedBox(height: 16),
                // Optimization Mode Selector
                Text(
                  "Optimization Mode:",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<OptimizeMode>(
                  value: _selectedMode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: OptimizeMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode.displayName),
                    );
                  }).toList(),
                  onChanged: state.advisoryLoading || state.match.archived
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedMode = value);
                          }
                        },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.advisoryLoading || state.match.archived
                        ? null
                        : () {
                            context.read<WorkspaceBloc>().add(
                                  OptimizeRequested(
                                    matchId: widget.matchId,
                                    mode: _selectedMode.toBackendValue(),
                                  ),
                                );
                          },
                    child: state.advisoryLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Run Optimization"),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                // Recommendations
                Text(
                  "Top Recommendations",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 12),
                if (state.recommendations.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        "No recommendations yet. Run optimization to generate suggestions.",
                        style: TextStyle(color: Colors.white54),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...state.recommendations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final recommendation = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RecommendationCard(
                        recommendation: recommendation,
                        rank: index + 1,
                        currentIntel: state.matchIntel,
                      ),
                    );
                  }),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                // Advisor Performance
                if (state.advisorPerformance != null) ...[
                  _AdvisorPerformanceCard(performance: state.advisorPerformance!),
                  const SizedBox(height: 16),
                ],
                // Recommendation History
                Text(
                  "Recommendation History",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 12),
                if (state.recommendationHistory.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        "No recommendation history yet.",
                        style: TextStyle(color: Colors.white54),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...state.recommendationHistory.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _RecommendationHistoryCard(item: item),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final int rank;
  final dynamic currentIntel; // MatchIntelligence?

  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.rank,
    this.currentIntel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recommendation #$rank",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Projected Advantage: ${recommendation.projectedAdvantage}",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              "Δ Aggression: ${recommendation.deltaAggression > 0 ? '+' : ''}${recommendation.deltaAggression}",
              style: TextStyle(
                color: recommendation.deltaAggression > 0
                    ? Colors.green
                    : recommendation.deltaAggression < 0
                        ? Colors.red
                        : Colors.white70,
              ),
            ),
            Text(
              "Δ Structure: ${recommendation.deltaStructure > 0 ? '+' : ''}${recommendation.deltaStructure}",
              style: TextStyle(
                color: recommendation.deltaStructure > 0
                    ? Colors.green
                    : recommendation.deltaStructure < 0
                        ? Colors.red
                        : Colors.white70,
              ),
            ),
            Text(
              "Δ Variety: ${recommendation.deltaVariety > 0 ? '+' : ''}${recommendation.deltaVariety}",
              style: TextStyle(
                color: recommendation.deltaVariety > 0
                    ? Colors.green
                    : recommendation.deltaVariety < 0
                        ? Colors.red
                        : Colors.white70,
              ),
            ),
            if (recommendation.riskImpact != 0)
              Text(
                "Risk Impact: ${recommendation.riskImpact > 0 ? '+' : ''}${recommendation.riskImpact}",
                style: const TextStyle(color: Colors.white70),
              ),
            if (recommendation.robustnessImpact != 0)
              Text(
                "Robustness Impact: ${recommendation.robustnessImpact > 0 ? '+' : ''}${recommendation.robustnessImpact}",
                style: const TextStyle(color: Colors.white70),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<WorkspaceBloc>().add(
                            PreviewApplyRequested(recommendation.id),
                          );
                    },
                    icon: const Icon(Icons.preview, size: 18),
                    label: const Text('Preview'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<WorkspaceBloc>().add(
                            RecommendationApplied(recommendation.id),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Recommendation applied")),
                      );
                    },
                    child: const Text("Apply"),
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

class _PreviewApplyDialog extends StatelessWidget {
  final String recommendationId;
  final Map<String, dynamic> data;

  const _PreviewApplyDialog({
    required this.recommendationId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Preview apply'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendation: ${recommendationId.length > 8 ? recommendationId.substring(0, 8) : recommendationId}...',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...data.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${e.key}: ${e.value}',
                style: const TextStyle(fontSize: 13),
              ),
            )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _AdvisorPerformanceCard extends StatelessWidget {
  final AdvisorPerformance performance;

  const _AdvisorPerformanceCard({required this.performance});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Advisor Performance",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Applied Recommendations: ${performance.appliedCount}",
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              "Avg Impact: ${performance.averageImpact > 0 ? '+' : ''}${performance.averageImpact.toStringAsFixed(1)}",
              style: TextStyle(
                color: performance.averageImpact > 0 ? Colors.green : Colors.red,
              ),
            ),
            Text(
              "Success Rate: ${(performance.positiveImpactRate * 100).toStringAsFixed(0)}%",
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationHistoryCard extends StatelessWidget {
  final RecommendationHistoryItem item;

  const _RecommendationHistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: item.applied
          ? Colors.green.shade900.withValues(alpha: 0.3)
          : Colors.grey.shade800,
      child: ListTile(
        title: Text(
          "Projected Advantage: ${item.projectedAdvantage}",
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          item.applied ? "Applied" : "Not Applied",
          style: TextStyle(
            color: item.applied ? Colors.green : Colors.white54,
          ),
        ),
        trailing: item.applied
            ? IconButton(
                icon: const Icon(Icons.analytics, color: Colors.white70),
                onPressed: () {
                  context.read<WorkspaceBloc>().add(
                        ImpactRequested(item.id),
                      );
                  // Show impact dialog after a short delay to allow state update
                  Future.delayed(const Duration(milliseconds: 100), () {
                    final state = context.read<WorkspaceBloc>().state;
                    if (state is WorkspaceLoadedState && state.selectedImpact != null) {
                      showDialog(
                        context: context,
                        builder: (_) => ImpactDialog(impact: state.selectedImpact!),
                      );
                    }
                  });
                },
              )
            : null,
      ),
    );
  }
}

class ImpactDialog extends StatelessWidget {
  final RecommendationImpact impact;

  const ImpactDialog({
    super.key,
    required this.impact,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Recommendation Impact"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ImpactRow(
            label: "Overall Score",
            before: impact.beforeScore,
            after: impact.afterScore,
          ),
          _ImpactRow(
            label: "Risk",
            delta: impact.riskChange,
          ),
          _ImpactRow(
            label: "Robustness",
            delta: impact.robustnessChange,
          ),
          const SizedBox(height: 8),
          _ImpactRow(
            label: "Impact Score",
            delta: impact.impactScore,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }
}

class _ImpactRow extends StatelessWidget {
  final String label;
  final int? before;
  final int? after;
  final int? delta;

  const _ImpactRow({
    required this.label,
    this.before,
    this.after,
    this.delta,
  });

  @override
  Widget build(BuildContext context) {
    if (before != null && after != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              "$before → $after",
              style: TextStyle(
                color: (after ?? 0) > (before ?? 0) ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
            Text(
              (delta ?? 0) > 0 ? "+${delta ?? 0}" : "${delta ?? 0}",
              style: TextStyle(
                color: (delta ?? 0) > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

