import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
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

class BenchmarkPage extends StatelessWidget {
  final String teamId;

  const BenchmarkPage({
    super.key,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BenchmarkBloc(
        dataSource: BenchmarkRemoteDataSource(getIt<ApiClient>()),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<BenchmarkBloc>().add(BenchmarkLoaded(teamId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
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

