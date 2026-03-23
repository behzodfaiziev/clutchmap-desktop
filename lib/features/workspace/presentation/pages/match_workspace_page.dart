import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_radius.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../infrastructure/datasources/workspace_remote_data_source.dart';
import '../bloc/workspace_bloc.dart';
import '../bloc/workspace_event.dart';
import '../bloc/workspace_state.dart';
import '../widgets/round_navigation.dart';
import '../widgets/round_editor.dart';
import '../widgets/tactical_events_panel.dart';
import '../widgets/round_intelligence_panel.dart';
import '../widgets/match_intelligence_panel.dart';
import '../widgets/advisory_panel.dart';
import '../widgets/presence/presence_avatars.dart';
import '../widgets/activity/activity_feed_panel.dart';
import '../widgets/unsaved_changes_indicator.dart';
import '../widgets/offline_banner.dart';
import '../widgets/websocket_reconnecting_banner.dart';
import '../widgets/dialogs/unsaved_changes_dialog.dart';
import '../widgets/dialogs/version_conflict_dialog.dart';
import '../widgets/export_menu.dart';
import '../../../../core/websocket/websocket_service.dart';
import '../../infrastructure/datasources/share_remote_data_source.dart';
import '../../infrastructure/datasources/export_remote_data_source.dart';
import '../../infrastructure/services/export_service.dart';
import '../../../templates/presentation/widgets/create_template_dialog.dart';
import '../../../templates/presentation/bloc/template_bloc.dart';
import '../../../templates/infrastructure/datasources/template_remote_data_source.dart';
import '../../../ai_coach/presentation/widgets/ai_coach_panel.dart';

class MatchWorkspacePage extends StatefulWidget {
  final String id;

  const MatchWorkspacePage({super.key, required this.id});

  @override
  State<MatchWorkspacePage> createState() => _MatchWorkspacePageState();
}

class _MatchWorkspacePageState extends State<MatchWorkspacePage> {
  late WorkspaceBloc _workspaceBloc;
  late String _currentUserId;
  StreamSubscription<WorkspaceState>? _workspaceSubscription;
  Timer? _lockRenewTimer;
  StreamSubscription<bool>? _wsConnectionSubscription;
  bool _isReconnecting = false;
  final GlobalKey _canvasKey = GlobalKey();
  final ExportService _exportService = ExportService();
  late final ShareRemoteDataSource _shareDataSource;
  late final ExportRemoteDataSource _exportDataSource;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _currentUserId = authState is AuthAuthenticated
        ? authState.user.id
        : '';

    _workspaceBloc = WorkspaceBloc(
      dataSource: getIt<WorkspaceRemoteDataSource>(),
      currentUserId: _currentUserId,
    )..add(WorkspaceLoaded(widget.id));

    _shareDataSource = getIt<ShareRemoteDataSource>();
    _exportDataSource = getIt<ExportRemoteDataSource>();

    // Listen for draft recovery requests
    _workspaceBloc.stream.listen((state) {
      if (state is WorkspaceLoadedState && state.rounds.isNotEmpty) {
        final currentRound = state.rounds[state.selectedIndex];
        _workspaceBloc.add(DraftRecoveryRequested(currentRound.id));
      }
    });

    // Listen for version conflicts
    _workspaceBloc.stream.listen((state) {
      if (state is WorkspaceLoadedState && state.versionConflict) {
        final currentRound = state.rounds[state.selectedIndex];
        _handleVersionConflict(context, currentRound.id);
      }
    });

    // Lock renew keep-alive when current user holds the round lock
    _workspaceSubscription = _workspaceBloc.stream.listen((state) {
      _lockRenewTimer?.cancel();
      if (state is WorkspaceLoadedState &&
          state.rounds.isNotEmpty &&
          state.isRoundLockedByCurrentUser(
            state.rounds[state.selectedIndex].id,
            _currentUserId,
          )) {
        _lockRenewTimer = Timer.periodic(
          const Duration(seconds: 45),
          (_) {
            if (!_workspaceBloc.isClosed) {
              final s = _workspaceBloc.state;
              if (s is WorkspaceLoadedState &&
                  s.rounds.isNotEmpty &&
                  s.isRoundLockedByCurrentUser(
                    s.rounds[s.selectedIndex].id,
                    _currentUserId,
                  )) {
                _workspaceBloc.add(LockRenewRequested(s.rounds[s.selectedIndex].id));
              }
            }
          },
        );
      }
    });

    // Listen for WebSocket connection status
    final wsService = getIt<WebSocketService>();
    _wsConnectionSubscription = wsService.connectionStream.listen((connected) {
      setState(() {
        _isReconnecting = !connected;
      });
    });
  }

  Future<void> _handleVersionConflict(BuildContext context, String roundId) async {
    final resolution = await showVersionConflictDialog(context);
    if (resolution != null) {
      _workspaceBloc.add(ConflictResolved(
        roundId: roundId,
        keepDraft: resolution == ConflictResolution.keepDraft,
      ));
    }
  }

  String _workspaceTitle(WorkspaceLoadedState state) {
    final parts = <String>[];
    if (state.match.gameName != null && state.match.gameName!.isNotEmpty) {
      parts.add(state.match.gameName!);
    }
    if (state.match.mapName != null && state.match.mapName!.isNotEmpty) {
      parts.add(state.match.mapName!);
    }
    parts.add(state.match.title);
    if (state.match.opponentName != null && state.match.opponentName!.isNotEmpty) {
      parts.add('vs ${state.match.opponentName!}');
    }
    return parts.join(' • ');
  }

  static String _formatUpdated(DateTime updatedAt) {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
    if (diff.inDays < 7) return 'Updated ${diff.inDays}d ago';
    return 'Updated ${updatedAt.month}/${updatedAt.day}';
  }

  Future<bool> _onWillPop() async {
    final state = _workspaceBloc.state;
    if (state is WorkspaceLoadedState && state.hasUnsavedChanges) {
      final shouldLeave = await showUnsavedChangesDialog(context);
      return shouldLeave;
    }
    return true;
  }

  @override
  void dispose() {
    _lockRenewTimer?.cancel();
    _workspaceSubscription?.cancel();
    // Release lock for currently selected round
    final state = _workspaceBloc.state;
    if (state is WorkspaceLoadedState && state.rounds.isNotEmpty) {
      final selectedRound = state.rounds[state.selectedIndex];
      _workspaceBloc.add(ReleaseLock(selectedRound.id));
    }
    _wsConnectionSubscription?.cancel();
    _workspaceBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _workspaceBloc),
        BlocProvider(
          create: (context) => TemplateBloc(
            dataSource: getIt<TemplateRemoteDataSource>(),
          ),
        ),
      ],
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: BlocBuilder<WorkspaceBloc, WorkspaceState>(
          builder: (context, state) {
          if (state is WorkspaceLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is WorkspaceError) {
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
                      context.read<WorkspaceBloc>().add(WorkspaceLoaded(widget.id));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is WorkspaceLoadedState) {
            return Column(
              children: [
                // Offline Banner
                if (state.offlineMode) const OfflineBanner(),
                // WebSocket Reconnecting Banner
                if (_isReconnecting) const WebSocketReconnectingBanner(),
                // Presence Avatars
                const PresenceAvatars(),
                // Toolbar (ui_stitch tactical editor: primary, panel-dark)
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.neutralSurface.withValues(alpha: 0.9),
                    border: Border(
                      bottom: BorderSide(color: AppColors.neutralBorder, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Match title and opponent
                      Expanded(
                        child: Row(
                          children: [
                            if (state.hasUnsavedChanges) const UnsavedChangesIndicator(),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _workspaceTitle(state),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (state.match.archived) ...[
                              const SizedBox(width: 8),
                              Chip(
                                label: const Text(
                                  'Archived',
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                                backgroundColor: Colors.white12,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () {
                                  _workspaceBloc.add(const MatchUnarchiveRequested());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Match restored')),
                                  );
                                },
                                icon: const Icon(Icons.restore, size: 18, color: Colors.white70),
                                label: const Text('Restore', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ),
                            ] else ...[
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () {
                                  _workspaceBloc.add(const MatchArchiveRequested());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Match archived')),
                                  );
                                },
                                icon: const Icon(Icons.archive_outlined, size: 18, color: Colors.white70),
                                label: const Text('Archive', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ),
                            ],
                            if (state.match.updatedAt != null) ...[
                              const SizedBox(width: 12),
                              Text(
                                _formatUpdated(state.match.updatedAt!),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white38,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Export Menu
                      ExportMenu(
                        state: state,
                        canvasKey: _canvasKey,
                        shareDataSource: _shareDataSource,
                        exportDataSource: _exportDataSource,
                        exportService: _exportService,
                      ),
                      const SizedBox(width: 8),
                      // Create Template button
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => CreateTemplateDialog(
                              matchId: widget.id,
                            ),
                          );
                        },
                        icon: const Icon(Icons.bookmark_add),
                        label: const Text('Save as Template'),
                      ),
                    ],
                  ),
                ),
                // Main Content: left toolstrip (ui_stitch) + round nav + canvas + right panel
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _EditorToolstrip(),
                      Container(width: 1, color: AppColors.neutralBorder),
                      SizedBox(
                        width: 220,
                        child: RoundNavigation(),
                      ),
                      Container(width: 1, color: AppColors.neutralBorder),
                      Expanded(
                        child: RoundEditor(canvasKey: _canvasKey),
                      ),
                      Container(width: 1, color: AppColors.neutralBorder),
                      SizedBox(
                        width: 300,
                        child: DefaultTabController(
                          length: 4,
                          child: Column(
                            children: [
                              TabBar(
                                tabs: const [
                                  Tab(text: 'Round'),
                                  Tab(text: 'Match'),
                                  Tab(text: 'Advisory'),
                                  Tab(text: 'AI Coach'),
                                ],
                                labelColor: Theme.of(context).colorScheme.secondary,
                                unselectedLabelColor: Colors.white70,
                                indicatorColor: Theme.of(context).colorScheme.secondary,
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    // Round Intelligence Tab
                                    RoundIntelligencePanel(
                                      roundId: state.rounds[state.selectedIndex].id,
                                    ),
                                    // Match Intelligence Tab
                                    MatchIntelligencePanel(
                                      matchId: widget.id,
                                    ),
                                    // Advisory Tab
                                    AdvisoryPanel(
                                      matchId: widget.id,
                                    ),
                                    // AI Coach Tab
                                    AiCoachPanel(
                                      matchId: widget.id,
                                      workspaceState: state,
                                      onNavigateToRound: (roundNumber) {
                                        final st = _workspaceBloc.state;
                                        if (st is WorkspaceLoadedState) {
                                          final idx = st.rounds
                                              .indexWhere((r) => r.roundNumber == roundNumber);
                                          if (idx >= 0) {
                                            _workspaceBloc.add(RoundSelected(idx));
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Container(width: 1, color: AppColors.neutralBorder),
                              SizedBox(
                                height: 200,
                                child: TacticalEventsPanel(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Activity Feed
                const SizedBox(
                  height: 150,
                  child: ActivityFeedPanel(),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
        ),
      ),
    );
  }
}

/// Left slim toolbar for tactical editor (ui_stitch clutch_map_tactical_editor_canvas).
class _EditorToolstrip extends StatelessWidget {
  const _EditorToolstrip();

  static const double width = 64;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: AppColors.neutralSurface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _ToolButton(icon: Icons.near_me, title: 'Selection'),
          _ToolButton(icon: Icons.person_pin_circle_outlined, title: 'Player Markers', active: true),
          _ToolButton(icon: Icons.gesture, title: 'Path Tool'),
          _ToolButton(icon: Icons.trending_flat, title: 'Arrow Tool'),
          _ToolButton(icon: Icons.cloud_outlined, title: 'Smoke/Utility'),
          const Spacer(),
          _ToolButton(icon: Icons.sticky_note_2_outlined, title: 'Strategy Notes'),
          _ToolButton(icon: Icons.auto_fix_high, title: 'Eraser', color: Colors.red),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.title,
    this.active = false,
    this.color,
  });

  final IconData icon;
  final String title;
  final bool active;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Tooltip(
        message: title,
        child: Material(
          color: active
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                size: 24,
                color: active
                    ? AppColors.primary
                    : (color ?? Colors.white54),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

