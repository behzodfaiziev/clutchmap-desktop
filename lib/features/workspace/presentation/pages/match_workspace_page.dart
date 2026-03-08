import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
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
import '../../infrastructure/services/export_service.dart';
import '../../infrastructure/datasources/share_remote_data_source.dart';
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
  StreamSubscription<bool>? _wsConnectionSubscription;
  bool _isReconnecting = false;
  final GlobalKey _canvasKey = GlobalKey();
  final ExportService _exportService = ExportService();
  late final ShareRemoteDataSource _shareDataSource;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated
        ? authState.user.id
        : '';

    _workspaceBloc = WorkspaceBloc(
      dataSource: WorkspaceRemoteDataSource(
        getIt<ApiClient>(),
      ),
      currentUserId: currentUserId,
    )..add(WorkspaceLoaded(widget.id));

    _shareDataSource = ShareRemoteDataSource(getIt<ApiClient>());

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
    // Release lock for currently selected round
    final state = _workspaceBloc.state;
    if (state is WorkspaceLoadedState) {
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
            dataSource: TemplateRemoteDataSource(getIt<ApiClient>()),
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
                // Toolbar with Create Template button and Unsaved Changes indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    border: Border(
                      bottom: BorderSide(color: Colors.white24, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Unsaved Changes Indicator
                      if (state.hasUnsavedChanges) const UnsavedChangesIndicator(),
                      const Spacer(),
                      // Export Menu
                      ExportMenu(
                        state: state,
                        canvasKey: _canvasKey,
                        shareDataSource: _shareDataSource,
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
                // Main Content
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 220,
                        child: RoundNavigation(),
                      ),
                      const VerticalDivider(width: 1, color: Colors.white24),
                      Expanded(
                        child: RoundEditor(canvasKey: _canvasKey),
                      ),
                      const VerticalDivider(width: 1, color: Colors.white24),
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
                                    ),
                                  ],
                                ),
                              ),
                              const VerticalDivider(width: 1, color: Colors.white24),
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

