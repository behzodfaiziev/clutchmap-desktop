import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../infrastructure/datasources/dashboard_remote_data_source.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/metric_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(
            child: Text(
              'Please log in',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        // For now, use a placeholder teamId - will be replaced with actual team selection
        final teamId = 'temp-team-id';

        return BlocProvider(
          create: (_) {
            final bloc = DashboardBloc(
              dataSource: DashboardRemoteDataSource(
                getIt<ApiClient>(),
              ),
            );
            bloc.add(DashboardLoaded(teamId));
            return bloc;
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is DashboardLoadedState) {
                  return _DashboardContent(state: state);
                }
                if (state is DashboardError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error loading dashboard',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<DashboardBloc>().add(
                                  DashboardLoaded(teamId),
                                );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(
                  child: Text(
                    'Error loading dashboard',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardLoadedState state;

  const _DashboardContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics Grid
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              MetricCard(
                title: "Aggression",
                value: state.intelligence.aggression,
              ),
              MetricCard(
                title: "Structure",
                value: state.intelligence.structure,
              ),
              MetricCard(
                title: "Overall",
                value: state.intelligence.overall,
              ),
              MetricCard(
                title: "Alignment",
                value: state.alignment.alignmentScore,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Playstyle Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Playstyle",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.intelligence.playstyle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Recent Matches
          const Text(
            "Recent Matches",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.recentMatches.length,
              itemBuilder: (_, index) {
                final match = state.recentMatches[index];
                return ListTile(
                  title: Text(
                    match.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    match.mapName ?? 'No map',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    _formatDate(match.updatedAt),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    context.go("/match/${match.id}");
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

