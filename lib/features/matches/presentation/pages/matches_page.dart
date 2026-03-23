import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_radius.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/team/active_team_service.dart';
import '../../domain/entities/match_summary.dart';
import '../../../../features/game/domain/entities/game_type.dart';
import '../../../../features/game/domain/entities/game_map_summary.dart';
import '../../../../features/game/infrastructure/datasources/game_config_remote_data_source.dart';
import '../../../../features/library/infrastructure/datasources/folder_remote_data_source.dart';
import '../../../../features/opponents/infrastructure/datasources/opponent_remote_data_source.dart';
import '../../infrastructure/datasources/matches_remote_data_source.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_event.dart';
import '../bloc/matches_state.dart';
import '../widgets/create_match_dialog.dart';

enum MatchFilter { active, archived }

class MatchesPage extends StatefulWidget {
  /// When set (e.g. from /matches?opponentId=xxx), list is filtered to matches vs this opponent.
  final String? opponentId;

  const MatchesPage({super.key, this.opponentId});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
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
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !(snapshot.data ?? false)) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                snapshot.hasError
                    ? 'Could not load team. Check backend connection.'
                    : 'No team found. Create or join a team to view matches.',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return BlocProvider(
          create: (_) => MatchesBloc(
            dataSource: getIt<MatchesRemoteDataSource>(),
            opponentDataSource: getIt<OpponentRemoteDataSource>(),
          )..add(MatchesLoaded(opponentId: widget.opponentId)),
          child: BlocListener<MatchesBloc, MatchesState>(
            listenWhen: (previous, current) {
              if (current is MatchesLoadedState) {
                return current.lastCreatedMatchId != null;
              }
              return false;
            },
            listener: (context, state) {
              final loaded = state as MatchesLoadedState;
              final id = loaded.lastCreatedMatchId;
              if (id != null && id.isNotEmpty) {
                context.read<MatchesBloc>().add(const ClearCreatedMatchId());
                if (loaded.lastCreatedWasDuplicate) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Match duplicated'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                context.go('/match/$id');
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TacticsLibraryHero(),
                  const SizedBox(height: 32),
                  _FilterBar(),
                  const SizedBox(height: 32),
                  Expanded(child: _MatchesList()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Hero section for My Tactics Library (ui_stitch clutch_map_my_tactics_library).
class _TacticsLibraryHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchesBloc, MatchesState>(
      buildWhen: (prev, curr) =>
          prev is MatchesLoadedState != curr is MatchesLoadedState ||
          (prev is MatchesLoadedState && curr is MatchesLoadedState && prev.matches.length != curr.matches.length),
      builder: (context, state) {
        final count = state is MatchesLoadedState ? state.matches.length : 0;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Tactics Library',
                    style: GoogleFonts.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Central command for your team\'s tactical playbook.',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  'Total Tactics: $count',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white38,
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_open, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Manage Folders',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const CreateMatchDialog(),
                    );
                  },
                  icon: const Icon(Icons.add_circle, size: 20),
                  label: Text(
                    'Create Tactic',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.backgroundDark,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.backgroundDark,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _FilterBar extends StatefulWidget {
  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  MatchFilter _currentFilter = MatchFilter.active;
  final TextEditingController _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounceTimer;
  void _onSearchChanged() => setState(() {});

  String? _selectedFolderId;
  String? _selectedGameId;
  String? _selectedMapId;
  String? _selectedOpponentId;
  List<FolderItem> _folders = [];
  List<Map<String, dynamic>> _opponents = [];
  List<GameMapSummary> _maps = [];
  bool _loadingFolders = false;
  bool _loadingOpponents = false;
  bool _loadingMaps = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    setState(() {
      _loadingFolders = true;
      _loadingOpponents = true;
    });
    try {
      final folderDs = getIt<FolderRemoteDataSource>();
      final folders = await folderDs.getFolderTree();
      final flat = folders.expand((f) => f.flatten()).toList();
      setState(() {
        _folders = flat;
        _loadingFolders = false;
      });
    } catch (_) {
      setState(() => _loadingFolders = false);
    }
    try {
      final opponentDs = getIt<OpponentRemoteDataSource>();
      final opponents = await opponentDs.getOpponents();
      setState(() {
        _opponents = opponents;
        _loadingOpponents = false;
      });
    } catch (_) {
      setState(() => _loadingOpponents = false);
    }
    if (_selectedGameId != null) {
      _loadMapsForGame(_selectedGameId!);
    }
  }

  Future<void> _loadMapsForGame(String gameId) async {
    setState(() => _loadingMaps = true);
    try {
      GameType? gameType;
      if (gameId.contains('VALORANT') || gameId == 'valorant') {
        gameType = GameType.valorant;
      } else if (gameId.contains('CS2') || gameId == 'cs2') {
        gameType = GameType.cs2;
      }
      if (gameType != null) {
        final gameDs = getIt<GameConfigRemoteDataSource>();
        final maps = await gameDs.getMapsByGameType(gameType);
        setState(() {
          _maps = maps;
          _loadingMaps = false;
        });
      } else {
        setState(() {
          _maps = [];
          _loadingMaps = false;
        });
      }
    } catch (_) {
      setState(() => _loadingMaps = false);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _runSearch() {
    _debounceTimer?.cancel();
    final query = _searchController.text.trim();
    context.read<MatchesBloc>().add(
          MatchesLoaded(
            filter: _currentFilter == MatchFilter.active ? 'active' : 'archived',
            query: query.isEmpty ? null : query,
            folderId: _selectedFolderId,
            gameId: _selectedGameId,
            mapId: _selectedMapId,
            opponentId: _selectedOpponentId,
          ),
        );
  }

  void _scheduleSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), _runSearch);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MatchesBloc, MatchesState>(
      listenWhen: (prev, curr) {
        if (curr is! MatchesLoadedState) return false;
        if (prev is MatchesLoadedState && prev.lastQuery != null && curr.lastQuery == null) return true;
        if (curr.lastFilter != null && (prev is! MatchesLoadedState || prev.lastFilter != curr.lastFilter)) return true;
        return false;
      },
      listener: (context, state) {
        final s = state as MatchesLoadedState;
        if (s.lastQuery == null) _searchController.clear();
        if (s.lastFilter != null && mounted) {
          final want = s.lastFilter == 'archived' ? MatchFilter.archived : MatchFilter.active;
          if (_currentFilter != want) setState(() => _currentFilter = want);
        }
        if (mounted) {
          setState(() {
            _selectedFolderId = s.lastFolderId;
            _selectedGameId = s.lastGameId;
            _selectedMapId = s.lastMapId;
            _selectedOpponentId = s.lastOpponentId;
          });
          if (s.lastGameId != _selectedGameId && s.lastGameId != null) {
            _loadMapsForGame(s.lastGameId!);
          }
        }
      },
      builder: (context, state) => _buildFilterRow(context, state),
    );
  }

  Widget _buildFilterRow(BuildContext context, MatchesState state) {
    final loadedState = state is MatchesLoadedState ? state : null;
    final hasFilters = _selectedFolderId != null ||
        _selectedGameId != null ||
        _selectedMapId != null ||
        _selectedOpponentId != null ||
        loadedState?.lastOpponentId != null;
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): const _FocusSearchIntent(),
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): const _FocusSearchIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _FocusSearchIntent: CallbackAction<_FocusSearchIntent>(onInvoke: (_) {
            _searchFocus.requestFocus();
            return null;
          }),
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.neutralSurface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.neutralBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      message: 'Search tactics (Ctrl+K)',
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        decoration: InputDecoration(
                          hintText: 'Search tactics by name, map, or keywords...',
                          hintStyle: GoogleFonts.inter(color: Colors.white38),
                          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.white38),
                          filled: true,
                          fillColor: AppColors.neutralSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            borderSide: BorderSide(color: AppColors.neutralBorder),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (_) => _scheduleSearch(),
                        onSubmitted: (_) => _runSearch(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildFilterDropdown(
                    label: 'Game',
                    value: _selectedGameId,
                    items: [
                      {'id': 'VALORANT', 'name': 'VALORANT'},
                      {'id': 'CS2', 'name': 'CS2'},
                    ],
                    onChanged: (id) {
                      setState(() {
                        _selectedGameId = id;
                        _selectedMapId = null;
                      });
                      if (id != null) {
                        _loadMapsForGame(id);
                      } else {
                        setState(() => _maps = []);
                      }
                      _runSearch();
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildFilterDropdown(
                    label: 'Map',
                    value: _selectedMapId,
                    items: _maps.map((m) => {'id': m.id, 'name': m.name}).toList(),
                    onChanged: (id) {
                      setState(() => _selectedMapId = id);
                      _runSearch();
                    },
                    isLoading: _loadingMaps,
                    enabled: _selectedGameId != null,
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 140,
                    child: DropdownButtonFormField<String>(
                      value: null,
                      decoration: InputDecoration(
                        labelText: 'Side',
                        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                        filled: true,
                        fillColor: AppColors.neutralSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: BorderSide(color: AppColors.neutralBorder),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      dropdownColor: AppColors.neutralSurface,
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Any', style: TextStyle(color: Colors.white70))),
                      ],
                      onChanged: (_) {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.filter_list, color: Colors.white54),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.neutralSurface,
                      side: BorderSide(color: AppColors.neutralBorder),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Status: ', style: GoogleFonts.inter(color: Colors.white54, fontSize: 14)),
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
                              query: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
                              folderId: _selectedFolderId,
                              gameId: _selectedGameId,
                              mapId: _selectedMapId,
                              opponentId: _selectedOpponentId,
                            ),
                          );
                    },
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Active')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Archived')),
                    ],
                  ),
                  const SizedBox(width: 16),
                  _buildFilterDropdown(
                    label: 'Folder',
                    value: _selectedFolderId,
                    items: _folders.map((f) => {'id': f.id, 'name': f.name}).toList(),
                    onChanged: (id) {
                      setState(() {
                        _selectedFolderId = id;
                        _selectedMapId = null;
                      });
                      _runSearch();
                    },
                    isLoading: _loadingFolders,
                  ),
                  const SizedBox(width: 12),
                  _buildFilterDropdown(
                    label: 'Opponent',
                    value: _selectedOpponentId ?? loadedState?.lastOpponentId,
                    items: _opponents.map((o) => {'id': o['id']?.toString() ?? '', 'name': o['name'] as String? ?? ''}).toList(),
                    onChanged: (id) {
                      setState(() => _selectedOpponentId = id);
                      _runSearch();
                    },
                    isLoading: _loadingOpponents,
                  ),
                ],
              ),
              if (hasFilters) ...[
                const SizedBox(height: 12),
                Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_selectedFolderId != null)
                    _buildFilterChip(
                      label: 'Folder: ${_folders.firstWhere((f) => f.id == _selectedFolderId, orElse: () => FolderItem(id: '', name: 'Unknown')).name}',
                      onClear: () {
                        setState(() => _selectedFolderId = null);
                        _runSearch();
                      },
                    ),
                  if (_selectedGameId != null)
                    _buildFilterChip(
                      label: 'Game: $_selectedGameId',
                      onClear: () {
                        setState(() {
                          _selectedGameId = null;
                          _selectedMapId = null;
                          _maps = [];
                        });
                        _runSearch();
                      },
                    ),
                  if (_selectedMapId != null)
                    _buildFilterChip(
                      label: 'Map: ${_maps.firstWhere((m) => m.id == _selectedMapId, orElse: () => GameMapSummary(id: '', name: 'Unknown')).name}',
                      onClear: () {
                        setState(() => _selectedMapId = null);
                        _runSearch();
                      },
                    ),
                  if (_selectedOpponentId != null || loadedState?.lastOpponentId != null)
                    _buildFilterChip(
                      label: 'Opponent: ${_opponents.firstWhere((o) => (o['id']?.toString() ?? '') == (_selectedOpponentId ?? loadedState?.lastOpponentId ?? ''), orElse: () => {'name': 'Unknown'})['name']}',
                      onClear: () {
                        setState(() => _selectedOpponentId = null);
                        context.read<MatchesBloc>().add(MatchesLoaded(
                          filter: loadedState?.lastFilter ?? 'active',
                          query: loadedState?.lastQuery,
                          folderId: _selectedFolderId,
                          gameId: _selectedGameId,
                          mapId: _selectedMapId,
                        ));
                        context.go('/matches');
                      },
                    ),
                ],
              ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    String? value,
    required List<Map<String, String>> items,
    required void Function(String?) onChanged,
    bool isLoading = false,
    bool enabled = true,
  }) {
    return SizedBox(
      width: 140,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
        ),
        style: const TextStyle(color: Colors.white, fontSize: 13),
        dropdownColor: Colors.grey.shade900,
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('All', style: TextStyle(color: Colors.white70)),
          ),
          ...items.map((item) => DropdownMenuItem<String>(
            value: item['id'],
            child: Text(item['name'] ?? '', style: const TextStyle(color: Colors.white)),
          )),
        ],
        onChanged: enabled && !isLoading ? onChanged : null,
        isExpanded: true,
      ),
    );
  }

  Widget _buildFilterChip({required String label, required VoidCallback onClear}) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white70),
      onDeleted: onClear,
      backgroundColor: Colors.grey.shade800,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _FocusSearchIntent extends Intent {
  const _FocusSearchIntent();
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
                      context.read<MatchesBloc>().add(MatchesLoaded(
                        filter: state.lastFilter,
                        query: state.lastQuery,
                        opponentId: state.lastOpponentId,
                      ));
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is MatchesLoadedState) {
          if (state.matches.isEmpty) {
            final hadSearch = state.lastQuery != null && state.lastQuery!.isNotEmpty;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_esports_outlined,
                      size: 64,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      hadSearch ? 'No matches found for "${state.lastQuery}"' : 'No matches found',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hadSearch
                          ? 'Try a different search or clear the search to see all matches.'
                          : 'Create a match to get started',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (hadSearch) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          context.read<MatchesBloc>().add(
                                MatchesLoaded(
                                  filter: state.lastFilter ?? 'active',
                                  query: null,
                                ),
                              );
                        },
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Clear search'),
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      TextButton.icon(
                        onPressed: () {
                          context.read<MatchesBloc>().add(
                                const MatchesLoaded(filter: 'archived'),
                              );
                        },
                        icon: const Icon(Icons.archive_outlined, size: 18),
                        label: const Text('View archived matches'),
                      ),
                      const SizedBox(height: 12),
                    ],
                    FilledButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const CreateMatchDialog(),
                        );
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Create match'),
                    ),
                  ],
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.only(top: 8),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: 0.75,
            ),
            itemCount: state.matches.length,
            itemBuilder: (context, index) {
              final match = state.matches[index];
              return _TacticCard(
                match: match,
                opponentName: state.opponentNamesById[match.opponentId ?? ''] ?? (match.opponentId != null ? 'Opponent' : null),
                onTap: () => context.go('/match/${match.id}'),
                onEdit: () => context.go('/match/${match.id}'),
                onShare: () {},
                onDuplicate: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Duplicating "${match.title}"...'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                  context.read<MatchesBloc>().add(MatchDuplicated(match.id));
                },
                onArchive: match.archived
                    ? null
                    : () {
                        context.read<MatchesBloc>().add(MatchArchived(match.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Match archived')),
                        );
                      },
                onRestore: match.archived
                    ? () {
                        context.read<MatchesBloc>().add(MatchRestored(match.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Match restored')),
                        );
                      }
                    : null,
                onDelete: () => _showDeleteConfirmation(context, match.id, match.title),
                duplicating: state.duplicatingMatchId == match.id,
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

}

/// Tactic card for My Tactics Library grid (ui_stitch clutch_map_my_tactics_library).
class _TacticCard extends StatefulWidget {
  final MatchSummary match;
  final String? opponentName;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDuplicate;
  final VoidCallback? onArchive;
  final VoidCallback? onRestore;
  final VoidCallback onDelete;
  final bool duplicating;

  const _TacticCard({
    required this.match,
    this.opponentName,
    required this.onTap,
    required this.onEdit,
    required this.onShare,
    required this.onDuplicate,
    this.onArchive,
    this.onRestore,
    required this.onDelete,
    required this.duplicating,
  });

  @override
  State<_TacticCard> createState() => _TacticCardState();
}

class _TacticCardState extends State<_TacticCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final gameLabel = widget.match.gameName ?? 'Tactic';
    final mapName = widget.match.mapName ?? 'No map';
    final side = widget.match.startingSide ?? 'Any';
    final meta = [mapName, side].join(' • ');
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.neutralSurface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: _hover ? AppColors.primary.withValues(alpha: 0.5) : AppColors.neutralBorder,
            ),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 15,
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    Container(
                      color: AppColors.neutral900,
                      child: CustomPaint(
                        painter: _TacticGridPainter(),
                        size: Size.infinite,
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDark.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          gameLabel.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    if (_hover)
                      Positioned.fill(
                        child: Material(
                          color: AppColors.backgroundDark.withValues(alpha: 0.7),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _OverlayButton(
                                  icon: Icons.edit,
                                  primary: true,
                                  onPressed: widget.onEdit,
                                ),
                                const SizedBox(width: 12),
                                _OverlayButton(
                                  icon: Icons.share,
                                  onPressed: widget.onShare,
                                ),
                                const SizedBox(width: 12),
                                _OverlayButton(
                                  icon: widget.duplicating ? null : Icons.copy,
                                  loading: widget.duplicating,
                                  onPressed: widget.duplicating ? () {} : widget.onDuplicate,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.match.title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          meta.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white54,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          _formatTacticTime(widget.match.updatedAt),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                    if (widget.match.archived)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Archived',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white38,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.onArchive != null)
                      TextButton(
                        onPressed: widget.onArchive,
                        child: Text('Archive', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
                      ),
                    if (widget.onRestore != null)
                      TextButton(
                        onPressed: widget.onRestore,
                        child: Text('Restore', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
                      ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 20, color: Colors.white54),
                      color: AppColors.neutralSurface,
                      onSelected: (v) {
                        if (v == 'delete') widget.onDelete();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.white70))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTacticTime(DateTime updatedAt) {
    final d = DateTime.now().difference(updatedAt);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${updatedAt.month}/${updatedAt.day}';
  }
}

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    this.icon,
    this.primary = false,
    this.loading = false,
    required this.onPressed,
  });

  final IconData? icon;
  final bool primary;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(
                  icon ?? Icons.copy,
                  size: 20,
                  color: primary ? AppColors.backgroundDark : Colors.white,
                ),
        ),
      ),
    );
  }
}

class _TacticGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const step = 20.0;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _showDeleteConfirmation(BuildContext context, String matchId, String matchTitle) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete match'),
        content: Text(
          'Delete "${matchTitle}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<MatchesBloc>().add(MatchDeleted(matchId));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Match deleted')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
