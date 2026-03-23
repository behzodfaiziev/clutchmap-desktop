import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/team/active_team_service.dart';
import '../../infrastructure/datasources/opponent_remote_data_source.dart';
import '../bloc/opponent_bloc.dart';
import '../bloc/opponent_event.dart';
import '../bloc/opponent_state.dart';
import '../widgets/create_opponent_dialog.dart';
import '../widgets/edit_opponent_dialog.dart';
import '../widgets/opponent_comparison.dart';
import '../widgets/opponent_list.dart';
import '../widgets/preparation/preparation_page.dart';

class OpponentsPage extends StatefulWidget {
  const OpponentsPage({super.key});

  @override
  State<OpponentsPage> createState() => _OpponentsPageState();
}

class _OpponentsPageState extends State<OpponentsPage> {
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
            appBar: AppBar(title: const Text("Opponents")),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.hasError
                      ? 'Could not load team. Check backend connection.'
                      : 'No team found. Create or join a team to view opponents.',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        return _OpponentsContent(teamId: teamId);
      },
    );
  }
}

class _OpponentsContent extends StatelessWidget {
  final String teamId;

  const _OpponentsContent({required this.teamId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OpponentBloc(
        dataSource: getIt<OpponentRemoteDataSource>(),
      )..add(const OpponentsLoaded()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Opponents"),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Create opponent',
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => const CreateOpponentDialog(),
              ),
            ),
          ],
        ),
        body: BlocBuilder<OpponentBloc, OpponentState>(
          builder: (context, state) {
            if (state is OpponentLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OpponentError) {
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
                          context.read<OpponentBloc>().add(const OpponentsLoaded());
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is OpponentLoadedState) {
              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: const [
                        Tab(text: "Comparison"),
                        Tab(text: "Preparation"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 300,
                                child: OpponentList(
                                  opponents: state.opponents,
                                  selectedId: state.selectedOpponent?.id,
                                  onOpponentSelected: (opponentId) {
                                    context.read<OpponentBloc>().add(
                                          OpponentSelected(
                                            opponentId: opponentId,
                                            teamId: teamId,
                                          ),
                                        );
                                  },
                                  onCreateOpponent: () => showDialog<void>(
                                        context: context,
                                        builder: (context) => const CreateOpponentDialog(),
                                      ),
                                  onEditOpponent: (opponent) {
                                    showDialog<void>(
                                      context: context,
                                      builder: (context) => EditOpponentDialog(
                                        opponentId: opponent.id,
                                        initialName: opponent.name,
                                        initialRegion: opponent.region,
                                        initialNotes: opponent.notes,
                                      ),
                                    );
                                  },
                                  onDeleteOpponent: (id) {
                                    context.read<OpponentBloc>().add(OpponentDeleted(id));
                                  },
                                  onViewMatches: (opponent) {
                                    context.go('/matches?opponentId=${opponent.id}');
                                  },
                                ),
                              ),
                              const VerticalDivider(width: 1, color: Colors.white24),
                              Expanded(
                                child: state.selectedOpponent != null
                                    ? OpponentComparison(
                                        teamProfile: state.teamProfile!,
                                        opponentProfile: state.selectedOpponent!,
                                        matchup: state.matchup,
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.compare_arrows, size: 40, color: Colors.white24),
                                            const SizedBox(height: 8),
                                            const Text(
                                              "Select an opponent to view comparison",
                                              style: TextStyle(color: Colors.white54),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          state.selectedOpponent != null
                              ? PreparationPage(
                                  opponentId: state.selectedOpponent!.id,
                                  opponentName: state.selectedOpponent!.name,
                                  teamId: teamId,
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.tips_and_updates_outlined, size: 40, color: Colors.white24),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Select an opponent to view preparation",
                                        style: TextStyle(color: Colors.white54),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
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

