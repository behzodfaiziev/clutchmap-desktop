import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/team/active_team_service.dart';
import '../../../matches/infrastructure/datasources/matches_remote_data_source.dart';
import '../../../workspace/infrastructure/datasources/workspace_remote_data_source.dart';
import '../../infrastructure/datasources/comparison_remote_data_source.dart';
import '../bloc/comparison_bloc.dart';
import '../bloc/comparison_event.dart';
import '../bloc/comparison_state.dart';
import '../../domain/entities/comparison_result.dart';
import '../../domain/entities/match_intelligence_summary.dart';
import '../widgets/metric_delta_row.dart';
import '../widgets/round_diff_card.dart';
import '../widgets/insight_summary.dart';

class ComparisonPage extends StatefulWidget {
  const ComparisonPage({super.key});

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  Future<bool>? _hasTeamFuture;

  Future<bool> _ensureTeamThenHasTeam() async {
    final active = getIt<ActiveTeamService>();
    await active.ensureResolved();
    return active.activeTeamId != null && active.activeTeamId!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    _hasTeamFuture ??= _ensureTeamThenHasTeam();
    return FutureBuilder<bool>(
      future: _hasTeamFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || !(snapshot.data ?? false)) {
          return Scaffold(
            appBar: AppBar(title: const Text('Match Comparison')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.hasError
                      ? 'Could not load team. Check backend connection.'
                      : 'No team found. Create or join a team to compare matches.',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        return BlocProvider(
          create: (_) => ComparisonBloc(
            comparisonDataSource: getIt<ComparisonRemoteDataSource>(),
            matchesDataSource: getIt<MatchesRemoteDataSource>(),
            workspaceDataSource: getIt<WorkspaceRemoteDataSource>(),
          )..add(const MatchesListLoaded()),
          child: const _ComparisonPageContent(),
        );
      },
    );
  }
}

class _ComparisonPageContent extends StatelessWidget {
  const _ComparisonPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Comparison'),
      ),
      body: BlocBuilder<ComparisonBloc, ComparisonState>(
        builder: (context, state) {
          if (state is ComparisonLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ComparisonError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<ComparisonBloc>().add(const MatchesListLoaded());
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ComparisonLoaded) {
            if (state.matches.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.compare_arrows,
                        size: 56,
                        color: Colors.white24,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No matches to compare',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create or open matches first, then select two to compare.',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Match Selectors
                  _MatchSelectors(state: state),
                  const SizedBox(height: 24),
                  // Intelligence Comparison
                  if (state.intelligenceA != null && state.intelligenceB != null)
                    _IntelligenceComparison(
                      intelligenceA: state.intelligenceA!,
                      intelligenceB: state.intelligenceB!,
                    ),
                  const SizedBox(height: 24),
                  // Comparison Result
                  if (state.comparisonResult != null) ...[
                    InsightSummary(result: state.comparisonResult!),
                    const SizedBox(height: 24),
                    _RoundDiffsView(diffs: state.comparisonResult!.roundDiffs),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MatchSelectors extends StatelessWidget {
  final ComparisonLoaded state;

  const _MatchSelectors({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Plan A",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: state.matchAId,
                    isExpanded: true,
                    hint: const Text("Select match"),
                    items: state.matches
                        .map((match) => DropdownMenuItem(
                              value: match.id,
                              child: Text(match.title),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<ComparisonBloc>().add(MatchASelected(value));
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Plan B",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: state.matchBId,
                    isExpanded: true,
                    hint: const Text("Select match"),
                    items: state.matches
                        .map((match) => DropdownMenuItem(
                              value: match.id,
                              child: Text(match.title),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<ComparisonBloc>().add(MatchBSelected(value));
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: state.matchAId != null && state.matchBId != null
                  ? () {
                      context.read<ComparisonBloc>().add(const ComparisonRequested());
                    }
                  : null,
              child: const Text("Compare"),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntelligenceComparison extends StatelessWidget {
  final MatchIntelligenceSummary intelligenceA;
  final MatchIntelligenceSummary intelligenceB;

  const _IntelligenceComparison({
    required this.intelligenceA,
    required this.intelligenceB,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Intelligence Comparison",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            MetricDeltaRow(
              label: "Aggression",
              valueA: intelligenceA.aggression,
              valueB: intelligenceB.aggression,
            ),
            MetricDeltaRow(
              label: "Structure",
              valueA: intelligenceA.structure,
              valueB: intelligenceB.structure,
            ),
            MetricDeltaRow(
              label: "Variety",
              valueA: intelligenceA.variety,
              valueB: intelligenceB.variety,
            ),
            MetricDeltaRow(
              label: "Overall",
              valueA: intelligenceA.overall,
              valueB: intelligenceB.overall,
            ),
            MetricDeltaRow(
              label: "Risk",
              valueA: intelligenceA.risk,
              valueB: intelligenceB.risk,
            ),
            MetricDeltaRow(
              label: "Volatility",
              valueA: intelligenceA.volatility,
              valueB: intelligenceB.volatility,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundDiffsView extends StatelessWidget {
  final List<RoundDiff> diffs;

  const _RoundDiffsView({required this.diffs});

  @override
  Widget build(BuildContext context) {
    if (diffs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, size: 48, color: Colors.white24),
              const SizedBox(height: 12),
              Text(
                'No round differences found',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 4),
              const Text(
                'The selected rounds are identical.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Round-by-Round Differences",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...diffs.map((diff) => RoundDiffCard(diff: diff)),
          ],
        ),
      ),
    );
  }
}

