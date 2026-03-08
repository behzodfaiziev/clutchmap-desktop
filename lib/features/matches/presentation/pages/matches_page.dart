import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../infrastructure/datasources/matches_remote_data_source.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_event.dart';
import '../bloc/matches_state.dart';
import '../widgets/create_match_dialog.dart';

enum MatchFilter { active, archived }

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MatchesBloc(
        dataSource: MatchesRemoteDataSource(
          getIt<ApiClient>(),
        ),
      )..add(const MatchesLoaded()),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            const SizedBox(height: 20),
            _FilterBar(),
            const SizedBox(height: 20),
            Expanded(child: _MatchesList()),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Matches',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const CreateMatchDialog(),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('New Match'),
        ),
      ],
    );
  }
}

class _FilterBar extends StatefulWidget {
  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  MatchFilter _currentFilter = MatchFilter.active;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Filter: ',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(width: 8),
        ToggleButtons(
          isSelected: [
            _currentFilter == MatchFilter.active,
            _currentFilter == MatchFilter.archived,
          ],
          onPressed: (index) {
            setState(() {
              _currentFilter = index == 0 ? MatchFilter.active : MatchFilter.archived;
            });
            context.read<MatchesBloc>().add(
              MatchesLoaded(
                filter: _currentFilter == MatchFilter.active ? 'active' : 'archived',
              ),
            );
          },
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Active'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Archived'),
            ),
          ],
        ),
      ],
    );
  }
}

class _MatchesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchesBloc, MatchesState>(
      builder: (context, state) {
        if (state is MatchesLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is MatchesError) {
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
                    context.read<MatchesBloc>().add(const MatchesLoaded());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is MatchesLoadedState) {
          if (state.matches.isEmpty) {
            return const Center(
              child: Text(
                'No matches found',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return ListView.separated(
            itemCount: state.matches.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.white24),
            itemBuilder: (context, index) {
              final match = state.matches[index];
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ListTile(
                  leading: const Icon(Icons.map, color: Colors.white70),
                  title: Text(
                    match.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    match.mapName ?? 'No map',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!match.archived)
                        IconButton(
                          icon: const Icon(Icons.archive, color: Colors.white70),
                          tooltip: 'Archive',
                          onPressed: () {
                            context.read<MatchesBloc>().add(
                              MatchArchived(match.id),
                            );
                          },
                        ),
                      if (match.archived)
                        IconButton(
                          icon: const Icon(Icons.restore, color: Colors.white70),
                          tooltip: 'Restore',
                          onPressed: () {
                            context.read<MatchesBloc>().add(
                              MatchRestored(match.id),
                            );
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () {
                          _showDeleteConfirmation(context, match.id);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    context.go("/match/${match.id}");
                  },
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String matchId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Match'),
        content: const Text('Are you sure you want to delete this match? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MatchesBloc>().add(MatchDeleted(matchId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

