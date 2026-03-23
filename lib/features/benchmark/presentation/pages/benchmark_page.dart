import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/team/active_team_service.dart';
import '../../infrastructure/datasources/benchmark_remote_data_source.dart';
import '../bloc/benchmark_bloc.dart';
import '../bloc/benchmark_event.dart';
import '../bloc/benchmark_state.dart';
import '../widgets/tactical_radar_chart.dart';
import '../widgets/percentile_cards.dart';
import '../widgets/meta_alignment_section.dart';
import '../widgets/meta_trend_chart.dart';
import '../widgets/interpretation_section.dart';
import '../widgets/evolution_comparison_section.dart';

class BenchmarkPage extends StatefulWidget {
  const BenchmarkPage({super.key});

  @override
  State<BenchmarkPage> createState() => _BenchmarkPageState();
}

class _BenchmarkPageState extends State<BenchmarkPage> {
  Future<String?>? _teamIdFuture;

  Future<String?> _teamIdAfterResolved() async {
    final active = getIt<ActiveTeamService>();
    await active.ensureResolved();
    return active.activeTeamId;
  }

  @override
  Widget build(BuildContext context) {
    _teamIdFuture ??= _teamIdAfterResolved();
    return FutureBuilder<String?>(
      future: _teamIdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final teamId = snapshot.data;
        if (teamId == null || teamId.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text("Team Benchmark")),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.hasError
                      ? 'Could not load team. Check backend connection.'
                      : 'No team found. Create or join a team to view benchmark.',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        return _BenchmarkContent(teamId: teamId);
      },
    );
  }
}

class _BenchmarkContent extends StatelessWidget {
  final String teamId;

  const _BenchmarkContent({required this.teamId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BenchmarkBloc(
        dataSource: getIt<BenchmarkRemoteDataSource>(),
      )..add(BenchmarkLoaded(teamId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Team Benchmark"),
        ),
        body: BlocBuilder<BenchmarkBloc, BenchmarkState>(
          builder: (context, state) {
            if (state is BenchmarkLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is BenchmarkError) {
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
                          context.read<BenchmarkBloc>().add(BenchmarkLoaded(teamId));
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is BenchmarkLoadedState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tactical Profile Radar
                    Text(
                      "Tactical Profile",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TacticalRadarChart(benchmark: state.benchmark),
                    const SizedBox(height: 32),
                    // Percentile Cards
                    Text(
                      "Percentile Rankings",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    PercentileCards(benchmark: state.benchmark),
                    const SizedBox(height: 32),
                    // Meta Alignment
                    Text(
                      "Meta Alignment",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    MetaAlignmentSection(alignment: state.metaAlignment),
                    const SizedBox(height: 32),
                    // Meta Trend
                    Text(
                      "Meta Trend",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    MetaTrendChart(
                      trends: state.metaTrends,
                      window: state.trendWindow,
                    ),
                    const SizedBox(height: 32),
                    // Evolution Comparison
                    EvolutionComparisonSection(
                      snapshots: state.teamSnapshots,
                      window: state.snapshotWindow,
                    ),
                    const SizedBox(height: 32),
                    // Interpretation
                    InterpretationSection(
                      benchmark: state.benchmark,
                      alignment: state.metaAlignment,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

