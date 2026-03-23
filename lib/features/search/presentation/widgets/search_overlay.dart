import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/team/active_team_service.dart';
import '../../infrastructure/datasources/search_remote_data_source.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../../domain/entities/search_result.dart';
import 'search_result_tile.dart';

class SearchOverlay extends StatefulWidget {
  const SearchOverlay({super.key});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late SearchBloc _searchBloc;
  String? _filterMapCode;
  String? _filterPattern;

  @override
  void initState() {
    super.initState();
    _searchBloc = SearchBloc(
      dataSource: getIt<SearchRemoteDataSource>(),
      activeTeamService: getIt<ActiveTeamService>(),
    );
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _searchBloc.close();
    super.dispose();
  }

  void _navigateToResult(SearchResult result) {
    Navigator.of(context).pop();

    final matchId = result.matchId ?? result.scopeId;
    if (result.type == "MATCH_PLAN" || result.type == "MATCH") {
      context.go("/match/${result.id}");
    } else if (matchId != null && matchId.isNotEmpty) {
      context.go("/match/$matchId");
      // Round selection can be done by workspace when roundNumber is in metadata
    } else {
      context.go("/match/${result.id}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchBloc,
      child: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.escape): DismissSearchIntent(),
          SingleActivator(LogicalKeyboardKey.arrowUp): SearchMoveSelectionIntent(-1),
          SingleActivator(LogicalKeyboardKey.arrowDown): SearchMoveSelectionIntent(1),
        },
        child: Actions(
          actions: {
            DismissSearchIntent: CallbackAction<DismissSearchIntent>(
              onInvoke: (_) {
                Navigator.of(context).pop();
                return null;
              },
            ),
            SearchMoveSelectionIntent: CallbackAction<SearchMoveSelectionIntent>(
              onInvoke: (SearchMoveSelectionIntent intent) {
                _searchBloc.add(SearchSelectionMoved(intent.delta));
                return null;
              },
            ),
          },
          child: Dialog(
            backgroundColor: Colors.black87,
            child: Container(
              width: 600,
              height: 500,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                controller: _searchController,
                focusNode: _focusNode,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search matches, rounds, tactics...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  _searchBloc.add(SearchQueryChanged(
                    value,
                    gameType: 'VALORANT',
                    mapCode: _filterMapCode,
                    pattern: _filterPattern,
                  ));
                },
                onSubmitted: (value) {
                  final state = _searchBloc.state;
                  if (state is SearchLoadedState && state.results.isNotEmpty) {
                    final selected = state.results[state.selectedIndex];
                    _navigateToResult(selected);
                  }
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  FilterChip(
                    label: const Text('Map'),
                    selected: _filterMapCode != null,
                    onSelected: (selected) {
                      setState(() {
                        _filterMapCode = selected ? 'ascent' : null;
                        if (_searchController.text.trim().isNotEmpty) {
                          _searchBloc.add(SearchQueryChanged(
                            _searchController.text,
                            gameType: 'VALORANT',
                            mapCode: _filterMapCode,
                            pattern: _filterPattern,
                          ));
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Pattern'),
                    selected: _filterPattern != null,
                    onSelected: (selected) {
                      setState(() {
                        _filterPattern = selected ? 'FAST_EXECUTE' : null;
                        if (_searchController.text.trim().isNotEmpty) {
                          _searchBloc.add(SearchQueryChanged(
                            _searchController.text,
                            gameType: 'VALORANT',
                            mapCode: _filterMapCode,
                            pattern: _filterPattern,
                          ));
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '↑↓ to select • Enter to open • Esc to close',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  bloc: _searchBloc,
                  builder: (context, state) {
                    if (state is SearchInitial) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 48, color: Colors.white24),
                            const SizedBox(height: 12),
                            const Text(
                              "Start typing to search...",
                              style: TextStyle(color: Colors.white54),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Matches, rounds, tactics",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is SearchError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                state.message,
                                style: const TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is SearchLoadedState) {
                      if (state.results.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 48, color: Colors.white24),
                              const SizedBox(height: 12),
                              const Text(
                                "No results found",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Try a different search for \"${state.query}\"",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: state.results.length,
                        itemBuilder: (context, index) {
                          final result = state.results[index];
                          final isSelected = index == state.selectedIndex;
                          return SearchResultTile(
                            result: result,
                            isSelected: isSelected,
                            onTap: () => _navigateToResult(result),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    ),
  );
  }
}

class DismissSearchIntent extends Intent {
  const DismissSearchIntent();
}

class SearchMoveSelectionIntent extends Intent {
  final int delta;
  const SearchMoveSelectionIntent(this.delta);
}

