import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../infrastructure/datasources/opponent_remote_data_source.dart';
import '../bloc/opponent_bloc.dart';
import '../bloc/opponent_event.dart';
import '../bloc/opponent_state.dart';
import '../widgets/opponent_list.dart';
import '../widgets/opponent_comparison.dart';
import '../widgets/preparation/preparation_page.dart';

class OpponentsPage extends StatelessWidget {
  final String teamId;

  const OpponentsPage({
    super.key,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OpponentBloc(
        dataSource: OpponentRemoteDataSource(getIt<ApiClient>()),
      )..add(const OpponentsLoaded()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Opponents"),
        ),
        body: BlocBuilder<OpponentBloc, OpponentState>(
          builder: (context, state) {
            if (state is OpponentLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OpponentError) {
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
                        context.read<OpponentBloc>().add(const OpponentsLoaded());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
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
                                    : const Center(
                                        child: Text(
                                          "Select an opponent to view comparison",
                                          style: TextStyle(color: Colors.white54),
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
                              : const Center(
                                  child: Text(
                                    "Select an opponent to view preparation",
                                    style: TextStyle(color: Colors.white54),
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

