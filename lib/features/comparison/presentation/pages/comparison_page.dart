import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
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

class ComparisonPage extends StatelessWidget {
  const ComparisonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ComparisonBloc(
        comparisonDataSource: ComparisonRemoteDataSource(getIt<ApiClient>()),
        matchesDataSource: MatchesRemoteDataSource(getIt<ApiClient>()),
        workspaceDataSource: WorkspaceRemoteDataSource(getIt<ApiClient>()),
      )..add(const MatchesListLoaded()),
      child: const _ComparisonPageContent(),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ComparisonBloc>().add(const MatchesListLoaded());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ComparisonLoaded) {
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
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("No round differences found."),
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

