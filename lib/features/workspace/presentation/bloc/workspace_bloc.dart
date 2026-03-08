import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/websocket/websocket_service.dart';
import '../../domain/entities/lock_status.dart';
import '../../domain/entities/tactical_event.dart';
import '../../domain/entities/buy_type.dart';
import '../../domain/entities/player_buy.dart';
import '../../domain/entities/round_intelligence.dart';
import '../../domain/entities/match_intelligence.dart';
import '../../domain/entities/match_risk.dart';
import '../../domain/entities/match_robustness.dart';
import '../../domain/entities/matchup_summary.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/recommendation_history_item.dart';
import '../../domain/entities/recommendation_impact.dart';
import '../../domain/entities/advisor_performance.dart';
import '../../domain/entities/activity_item.dart';
import '../../domain/entities/presence_user.dart';
import '../../infrastructure/datasources/workspace_remote_data_source.dart';
import '../../infrastructure/datasources/draft_local_data_source.dart';
import '../../domain/entities/round_draft.dart';
import '../../../../core/telemetry/telemetry.dart';
import '../../../../core/di/injection.dart';
import '../widgets/canvas/canvas_models.dart';
import 'workspace_event.dart';
import 'workspace_state.dart';

class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final WorkspaceRemoteDataSource dataSource;
  final String currentUserId;
  Timer? _debounceTimer;
  Timer? _autoSaveTimer;
  Timer? _intelligenceDebounce;
  StreamSubscription? _webSocketSubscription;
  final DraftLocalDataSource _draftDataSource = DraftLocalDataSource();
  final Telemetry _telemetry = getIt<Telemetry>();

  WorkspaceBloc({
    required this.dataSource,
    required this.currentUserId,
  }) : super(WorkspaceLoading()) {
    on<WorkspaceLoaded>(_onWorkspaceLoaded);
    on<RoundSelected>(_onRoundSelected);
    on<RoundNotesUpdated>(_onRoundNotesUpdated);
    on<AcquireLock>(_onAcquireLock);
    on<ReleaseLock>(_onReleaseLock);
    on<LockStatusUpdated>(_onLockStatusUpdated);
    on<TacticalEventAdded>(_onTacticalEventAdded);
    on<TacticalEventRemoved>(_onTacticalEventRemoved);
    on<TacticalEventsLoaded>(_onTacticalEventsLoaded);
    on<CanvasDrawingUpdated>(_onCanvasDrawingUpdated);
    on<CanvasDrawingLoaded>(_onCanvasDrawingLoaded);
    on<BuyTypeChanged>(_onBuyTypeChanged);
    on<PlayerBuyChanged>(_onPlayerBuyChanged);
    on<BuyPlanLoaded>(_onBuyPlanLoaded);
    on<RoundIntelligenceLoaded>(_onRoundIntelligenceLoaded);
    on<MatchIntelligenceRequested>(_onMatchIntelligenceRequested);
    on<SimulateRequested>(_onSimulateRequested);
    on<OptimizeRequested>(_onOptimizeRequested);
    on<RecommendationApplied>(_onRecommendationApplied);
    on<RecommendationsLoaded>(_onRecommendationsLoaded);
    on<RecommendationHistoryRequested>(_onRecommendationHistoryRequested);
    on<ImpactRequested>(_onImpactRequested);
    on<ActivityAdded>(_onActivityAdded);
    on<PresenceUserJoined>(_onPresenceUserJoined);
    on<PresenceUserLeft>(_onPresenceUserLeft);
    on<DraftRecoveryRequested>(_onDraftRecoveryRequested);
    on<DraftRestored>(_onDraftRestored);
    on<DraftDiscarded>(_onDraftDiscarded);
    on<VersionConflictDetected>(_onVersionConflictDetected);
    on<ConflictResolved>(_onConflictResolved);
    on<WebSocketDisconnected>(_onWebSocketDisconnected);
    on<WebSocketReconnected>(_onWebSocketReconnected);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _autoSaveTimer?.cancel();
    _intelligenceDebounce?.cancel();
    _webSocketSubscription?.cancel();
    return super.close();
  }

  void _scheduleAutoSave(String roundId) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 1200), () {
      _saveRoundToBackend(roundId);
    });
  }

  void _scheduleIntelligenceRefresh(String matchId) {
    _intelligenceDebounce?.cancel();
    _intelligenceDebounce = Timer(const Duration(milliseconds: 800), () {
      add(MatchIntelligenceRequested(matchId));
    });
  }

  Future<void> _saveRoundToBackend(String roundId) async {
    final state = this.state;
    if (state is! WorkspaceLoadedState) return;

    try {
      // Get current round data
      final round = state.rounds.firstWhere((r) => r.id == roundId);
      final notes = round.notes ?? "";
      final buyType = state.buyTypes[roundId];
      final playerBuys = state.playerBuys[roundId] ?? [];
      final canvasStrokes = state.canvasStrokes[roundId] ?? [];
      final canvasArrows = state.canvasArrows[roundId] ?? [];
      final canvasObjects = state.canvasObjects[roundId] ?? [];

      // Update notes
      if (notes.isNotEmpty) {
        await dataSource.updateRoundNotes(roundId, notes);
      }

      // Update canvas (strategy)
      final canvasJson = {
        "strokes": canvasStrokes.map((s) => s.toJson()).toList(),
        "arrows": canvasArrows.map((a) => a.toJson()).toList(),
        "objects": canvasObjects.map((o) => o.toJson()).toList(),
      };
      await dataSource.updateRoundStrategy(roundId, jsonEncode(canvasJson));

      // Update buy plan
      final buyJson = {
        "buyType": buyType?.name,
        "playerBuys": playerBuys.map((b) => b.toJson()).toList(),
      };
      await dataSource.updateBuyPlan(roundId, jsonEncode(buyJson));

      // Clear draft on success
      await _draftDataSource.deleteDraft(roundId);

      // Update state
      emit(state.copyWith(hasUnsavedChanges: false, versionConflict: false));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        // Version conflict
        add(VersionConflictDetected(roundId));
      } else {
        // Save draft on error
        await _saveDraftLocally(roundId, state);
        emit(state.copyWith(offlineMode: true));
      }
    } catch (e) {
      // Save draft on error
      await _saveDraftLocally(roundId, state);
      emit(state.copyWith(offlineMode: true));
    }
  }

  Future<void> _saveDraftLocally(String roundId, WorkspaceLoadedState state) async {
    final round = state.rounds.firstWhere((r) => r.id == roundId);
    final notes = round.notes ?? "";
    final playerBuys = state.playerBuys[roundId] ?? [];
    final canvasStrokes = state.canvasStrokes[roundId] ?? [];
    final canvasArrows = state.canvasArrows[roundId] ?? [];
    final canvasObjects = state.canvasObjects[roundId] ?? [];

    final canvasJson = {
      "strokes": canvasStrokes.map((s) => s.toJson()).toList(),
      "arrows": canvasArrows.map((a) => a.toJson()).toList(),
      "objects": canvasObjects.map((o) => o.toJson()).toList(),
    };

    final draft = RoundDraft(
      roundId: roundId,
      notes: notes,
      drawingJson: canvasJson,
      buys: playerBuys,
    );

    await _draftDataSource.saveDraft(draft);
  }

  Future<void> _onWorkspaceLoaded(
    WorkspaceLoaded event,
    Emitter<WorkspaceState> emit,
  ) async {
    emit(WorkspaceLoading());

    try {
      final match = await dataSource.getMatchDetail(event.matchId);
      final rounds = await dataSource.getRounds(event.matchId);

      final loadedState = WorkspaceLoadedState(
        match: match.toEntity(),
        rounds: rounds.map((r) => r.toEntity()).toList(),
        selectedIndex: 0,
      );

      // Check for drafts on first round
      if (loadedState.rounds.isNotEmpty) {
        final firstRoundId = loadedState.rounds[0].id;
        final draft = await _draftDataSource.getDraft(firstRoundId);
        if (draft != null) {
          add(DraftRecoveryRequested(firstRoundId));
        }
      }

      emit(loadedState);

      // Connect WebSocket
      final token = await getIt<TokenStorage>().getToken();
      if (token != null) {
        final webSocketService = getIt<WebSocketService>();
        webSocketService.connect(token);

        // Listen to WebSocket messages with throttling
        _webSocketSubscription?.cancel();
        final stream = webSocketService.stream;
        if (stream != null) {
          DateTime? lastEventTime;
          _webSocketSubscription = stream.listen(
            (message) {
              // Simple throttling: only process if 200ms have passed since last event
              final now = DateTime.now();
              if (lastEventTime == null || 
                  now.difference(lastEventTime!).inMilliseconds >= 200) {
                lastEventTime = now;
                try {
                  final data = jsonDecode(message);
                  final eventType = data['type'] as String?;
                  
                  if (eventType == 'LOCK_STATUS') {
                    final roundId = data['roundId'] as String;
                    final lockStatus = LockStatus.fromJson({
                      'lockedBy': data['lockedBy'],
                      'expiresAt': data['expiresAt'],
                    });
                    add(LockStatusUpdated(roundId: roundId, status: lockStatus));
                  } else if (eventType == 'TACTICAL_EVENT_ADDED' || eventType == 'TACTICAL_EVENT_REMOVED') {
                    final roundId = data['roundId'] as String?;
                    if (roundId != null) {
                      add(TacticalEventsLoaded(roundId));
                    }
                  } else if (eventType == 'ROUND_UPDATED') {
                    final user = data['user'] as String? ?? 'Unknown';
                    final roundNumber = data['roundNumber'] as int?;
                    final msg = roundNumber != null
                        ? "$user updated Round $roundNumber"
                        : "$user updated a round";
                    add(ActivityAdded(
                      message: msg,
                      userId: data['userId'] as String?,
                      eventType: eventType,
                    ));
                  } else if (eventType == 'LOCK_ACQUIRED') {
                    final user = data['user'] as String? ?? 'Unknown';
                    add(ActivityAdded(
                      message: "$user acquired edit lock",
                      userId: data['userId'] as String?,
                      eventType: eventType,
                    ));
                  } else if (eventType == 'LOCK_RELEASED') {
                    final user = data['user'] as String? ?? 'Unknown';
                    add(ActivityAdded(
                      message: "$user released edit lock",
                      userId: data['userId'] as String?,
                      eventType: eventType,
                    ));
                  } else if (eventType == 'TACTICAL_EVENT_ADDED') {
                    final user = data['user'] as String? ?? 'Unknown';
                    final eventTypeName = data['eventType'] as String? ?? 'event';
                    add(ActivityAdded(
                      message: "$user added $eventTypeName",
                      userId: data['userId'] as String?,
                      eventType: eventType,
                    ));
                  } else if (eventType == 'RECOMMENDATION_APPLIED') {
                    final user = data['user'] as String? ?? 'Unknown';
                    add(ActivityAdded(
                      message: "$user applied a recommendation",
                      userId: data['userId'] as String?,
                      eventType: eventType,
                    ));
                  } else if (eventType == 'USER_JOINED' || eventType == 'PRESENCE_UPDATE') {
                    final userId = data['userId'] as String? ?? '';
                    final email = data['email'] as String? ?? data['user'] as String? ?? 'Unknown';
                    final name = data['name'] as String?;
                    add(PresenceUserJoined(
                      userId: userId,
                      email: email,
                      name: name,
                    ));
                  } else if (eventType == 'USER_LEFT') {
                    final userId = data['userId'] as String? ?? '';
                    add(PresenceUserLeft(userId));
                  }
                } catch (e) {
                  // Ignore parsing errors
                }
              }
            },
          );
        }
      }

      // Load match intelligence
      add(MatchIntelligenceRequested(event.matchId));
      // Load recommendation history
      add(RecommendationHistoryRequested(event.matchId));

      // Acquire lock for first round if available
      if (loadedState.rounds.isNotEmpty) {
        final firstRound = loadedState.rounds[0];
        add(AcquireLock(firstRound.id));
        // Load tactical events for first round
        add(TacticalEventsLoaded(firstRound.id));
        // Load canvas drawing for first round
        add(CanvasDrawingLoaded(firstRound.id));
        // Load buy plan for first round
        add(BuyPlanLoaded(firstRound.id));
        // Load intelligence for first round
        add(RoundIntelligenceLoaded(firstRound.id));
      }
    } on DioException catch (e) {
      emit(WorkspaceError(
        e.response?.data?['message'] as String? ?? 'Failed to load workspace',
      ));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> _onRoundSelected(
    RoundSelected event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;

      // Release lock for previously selected round
      if (currentState.selectedIndex >= 0 &&
          currentState.selectedIndex < currentState.rounds.length) {
        final previousRound = currentState.rounds[currentState.selectedIndex];
        try {
          await dataSource.releaseLock(previousRound.id);
        } catch (e) {
          // Ignore errors on release
        }
      }

      // Update selected index
      emit(currentState.copyWith(selectedIndex: event.index));

      // Acquire lock for newly selected round
      if (event.index >= 0 && event.index < currentState.rounds.length) {
        final selectedRound = currentState.rounds[event.index];
        try {
          await dataSource.acquireLock(selectedRound.id);
          final lockData = await dataSource.getLockStatus(selectedRound.id);
          final lockStatus = LockStatus.fromJson(lockData);
          emit(currentState.copyWith(selectedIndex: event.index)
              .updateLockStatus(selectedRound.id, lockStatus));
        } on DioException catch (e) {
          // If 409 conflict, lock is held by someone else
          // Lock status will be updated via WebSocket
          if (e.response?.statusCode == 409) {
            // Try to get current lock status
            try {
              final lockData = await dataSource.getLockStatus(selectedRound.id);
              final lockStatus = LockStatus.fromJson(lockData);
              emit(currentState.copyWith(selectedIndex: event.index)
                  .updateLockStatus(selectedRound.id, lockStatus));
            } catch (_) {
              // Ignore
            }
          }
        } catch (e) {
          // Ignore other errors
        }
        // Load tactical events for selected round
        add(TacticalEventsLoaded(selectedRound.id));
        // Load canvas drawing for selected round
        add(CanvasDrawingLoaded(selectedRound.id));
        // Load buy plan for selected round
        add(BuyPlanLoaded(selectedRound.id));
        // Load intelligence for selected round
        add(RoundIntelligenceLoaded(selectedRound.id));
      }
    }
  }

  void _onRoundNotesUpdated(
    RoundNotesUpdated event,
    Emitter<WorkspaceState> emit,
  ) {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;

      // Check if round is locked by current user
      if (!currentState.isRoundLockedByCurrentUser(event.roundId, currentUserId)) {
        return; // Don't allow editing if not locked by current user
      }

      // Update local state immediately
      final updatedRounds = currentState.rounds.map((round) {
        if (round.id == event.roundId) {
          return round.copyWith(notes: event.notes);
        }
        return round;
      }).toList();

      emit(currentState.copyWith(
        rounds: updatedRounds,
        hasUnsavedChanges: true,
      ));

      // Schedule auto-save
      _scheduleAutoSave(event.roundId);
    }
  }

  Future<void> _onAcquireLock(
    AcquireLock event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      try {
        await dataSource.acquireLock(event.roundId);
        final lockData = await dataSource.getLockStatus(event.roundId);
        final lockStatus = LockStatus.fromJson(lockData);
        emit(currentState.updateLockStatus(event.roundId, lockStatus));
      } catch (e) {
        // Ignore errors - lock status will be updated via WebSocket
      }
    }
  }

  Future<void> _onReleaseLock(
    ReleaseLock event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      try {
        await dataSource.releaseLock(event.roundId);
        final currentState = state as WorkspaceLoadedState;
        emit(currentState.updateLockStatus(event.roundId, LockStatus.empty()));
      } catch (e) {
        // Ignore errors
      }
    }
  }

  void _onLockStatusUpdated(
    LockStatusUpdated event,
    Emitter<WorkspaceState> emit,
  ) {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      emit(currentState.updateLockStatus(event.roundId, event.status));
    }
  }

  Future<void> _onTacticalEventAdded(
    TacticalEventAdded event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      try {
        await dataSource.addTacticalEvent(event.roundId, event.eventType);
        // Reload events
        add(TacticalEventsLoaded(event.roundId));
        // Refresh intelligence after tactical event added
        add(RoundIntelligenceLoaded(event.roundId));
      } catch (e) {
        // Ignore errors - events will be reloaded via WebSocket
      }
    }
  }

  Future<void> _onTacticalEventRemoved(
    TacticalEventRemoved event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      try {
        await dataSource.removeTacticalEvent(event.roundId, event.eventId);
        // Reload events
        add(TacticalEventsLoaded(event.roundId));
        // Refresh intelligence after tactical event removed
        add(RoundIntelligenceLoaded(event.roundId));
        // Schedule debounced match intelligence refresh
        if (state is WorkspaceLoadedState) {
          final currentState = state as WorkspaceLoadedState;
          _scheduleIntelligenceRefresh(currentState.match.id);
        }
      } catch (e) {
        // Ignore errors - events will be reloaded via WebSocket
      }
    }
  }

  Future<void> _onTacticalEventsLoaded(
    TacticalEventsLoaded event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      try {
        final events = await dataSource.getTacticalEvents(event.roundId);
        emit(currentState.updateTacticalEvents(
          event.roundId,
          events.map((e) => e as TacticalEvent).toList(),
        ));
      } catch (e) {
        // Ignore errors
      }
    }
  }

  Future<void> _onCanvasDrawingUpdated(
    CanvasDrawingUpdated event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      
      // Update local state
      final updatedStrokes = event.strokesJson
          .map((json) => CanvasStroke.fromJson(json))
          .toList();
      final updatedArrows = event.arrowsJson
          .map((json) => CanvasArrow.fromJson(json))
          .toList();
      final updatedObjects = event.objectsJson
          .map((json) => CanvasObject.fromJson(json))
          .toList();

      emit(currentState.copyWith(
        canvasStrokes: {
          ...currentState.canvasStrokes,
          event.roundId: updatedStrokes,
        },
        canvasArrows: {
          ...currentState.canvasArrows,
          event.roundId: updatedArrows,
        },
        canvasObjects: {
          ...currentState.canvasObjects,
          event.roundId: updatedObjects,
        },
        hasUnsavedChanges: true,
      ));

      // Schedule auto-save
      _scheduleAutoSave(event.roundId);
    }
  }

  Future<void> _onCanvasDrawingLoaded(
    CanvasDrawingLoaded event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      try {
        final strategyData = await dataSource.getRoundStrategy(event.roundId);
        if (strategyData != null) {
          final canvasDoc = strategyData['canvasDoc'] as String?;
          if (canvasDoc != null && canvasDoc.isNotEmpty) {
            final canvasData = jsonDecode(canvasDoc) as Map<String, dynamic>;
            final strokesList = canvasData["strokes"] as List<dynamic>? ?? [];
            final arrowsList = canvasData["arrows"] as List<dynamic>? ?? [];
            final objectsList = canvasData["objects"] as List<dynamic>? ?? [];
            
            final strokes = strokesList
                .map((e) => CanvasStroke.fromJson(e as Map<String, dynamic>))
                .toList();
            final arrows = arrowsList
                .map((e) => CanvasArrow.fromJson(e as Map<String, dynamic>))
                .toList();
            final objects = objectsList
                .map((e) => CanvasObject.fromJson(e as Map<String, dynamic>))
                .toList();
            
            emit(currentState.updateCanvasDrawing(
              event.roundId,
              strokes: strokes,
              arrows: arrows,
              objects: objects,
            ));
          } else {
            // No drawing yet, initialize with empty lists
            emit(currentState.updateCanvasDrawing(
              event.roundId,
              strokes: [],
              arrows: [],
              objects: [],
            ));
          }
        } else {
          // Strategy doesn't exist yet, initialize with empty lists
          emit(currentState.updateCanvasDrawing(
            event.roundId,
            strokes: [],
            arrows: [],
            objects: [],
          ));
        }
      } catch (e) {
        // Ignore errors - initialize with empty list
        emit(currentState.updateCanvasStrokes(event.roundId, []));
      }
    }
  }

  Future<void> _onBuyTypeChanged(
    BuyTypeChanged event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      try {
        // Map BuyType enum to backend economy type string
        String economyType;
        switch (event.buyType) {
          case BuyType.eco:
            economyType = "ECO";
            break;
          case BuyType.halfBuy:
            economyType = "HALF_BUY";
            break;
          case BuyType.fullBuy:
            economyType = "FULL_BUY";
            break;
          case BuyType.forceBuy:
            economyType = "FORCE_BUY";
            break;
        }
        await dataSource.updateRoundEconomy(event.roundId, economyType);
        emit(currentState.updateBuyPlan(event.roundId, buyType: event.buyType).copyWith(
          hasUnsavedChanges: true,
        ));
        // Schedule auto-save
        _scheduleAutoSave(event.roundId);
        // Refresh intelligence after buy type change
        add(RoundIntelligenceLoaded(event.roundId));
        // Schedule debounced match intelligence refresh
        _scheduleIntelligenceRefresh(currentState.match.id);
      } catch (e) {
        // Ignore errors
      }
    }
  }

  Future<void> _onPlayerBuyChanged(
    PlayerBuyChanged event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      try {
        final currentBuys = List<PlayerBuy>.from(
          currentState.playerBuys[event.roundId] ?? [],
        );
        
        // Update or add player buy
        final index = currentBuys.indexWhere((b) => b.playerId == event.playerId);
        final updatedBuy = PlayerBuy(
          playerId: event.playerId,
          weapon: event.weapon,
        );
        
        if (index >= 0) {
          currentBuys[index] = updatedBuy;
        } else {
          currentBuys.add(updatedBuy);
        }
        
        // Update local state
        emit(currentState.updateBuyPlan(
          event.roundId,
          playerBuys: currentBuys,
        ).copyWith(
          hasUnsavedChanges: true,
        ));

        // Schedule auto-save
        _scheduleAutoSave(event.roundId);
        
        emit(currentState.updateBuyPlan(
          event.roundId,
          playerBuys: currentBuys,
        ));
        // Refresh intelligence after player buy change
        add(RoundIntelligenceLoaded(event.roundId));
        // Schedule debounced match intelligence refresh
        _scheduleIntelligenceRefresh(currentState.match.id);
      } catch (e) {
        // Ignore errors
      }
    }
  }

  Future<void> _onRoundIntelligenceLoaded(
    RoundIntelligenceLoaded event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      try {
        final intelligenceData = await dataSource.getRoundIntelligence(event.roundId);
        final intelligence = RoundIntelligence.fromJson(intelligenceData);
        emit(currentState.updateRoundIntelligence(event.roundId, intelligence));
      } catch (e) {
        // Ignore errors - intelligence might not be available
      }
    }
  }

  Future<void> _onBuyPlanLoaded(
    BuyPlanLoaded event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      try {
        final buyPlanData = await dataSource.getBuyPlan(event.roundId);
        if (buyPlanData != null) {
          final buyDoc = buyPlanData['buyDoc'] as String?;
          if (buyDoc != null && buyDoc.isNotEmpty) {
            final buyData = jsonDecode(buyDoc) as Map<String, dynamic>;
            
            // Parse buy type
            BuyType? buyType;
            final buyTypeStr = buyData["buyType"] as String?;
            if (buyTypeStr != null) {
              switch (buyTypeStr.toUpperCase()) {
                case "ECO":
                  buyType = BuyType.eco;
                  break;
                case "HALF_BUY":
                  buyType = BuyType.halfBuy;
                  break;
                case "FULL_BUY":
                  buyType = BuyType.fullBuy;
                  break;
                case "FORCE_BUY":
                  buyType = BuyType.forceBuy;
                  break;
              }
            }
            
            // Parse player buys
            final playerBuysList = buyData["playerBuys"] as List<dynamic>? ?? [];
            final playerBuys = playerBuysList
                .map((e) => PlayerBuy.fromJson(e as Map<String, dynamic>))
                .toList();
            
            emit(currentState.updateBuyPlan(
              event.roundId,
              buyType: buyType,
              playerBuys: playerBuys,
            ));
          } else {
            // No buy plan yet, initialize with empty
            emit(currentState.updateBuyPlan(
              event.roundId,
              buyType: null,
              playerBuys: [],
            ));
          }
        } else {
          // Buy plan doesn't exist yet, initialize with empty
          emit(currentState.updateBuyPlan(
            event.roundId,
            buyType: null,
            playerBuys: [],
          ));
        }
      } catch (e) {
        // Ignore errors - initialize with empty
        emit(currentState.updateBuyPlan(
          event.roundId,
          buyType: null,
          playerBuys: [],
        ));
      }
    }
  }

  Future<void> _onMatchIntelligenceRequested(
    MatchIntelligenceRequested event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      try {
        // Load match intelligence
        final intelligenceData = await dataSource.getMatchIntelligence(event.matchId);
        final matchIntel = MatchIntelligence.fromJson(intelligenceData);

        // Load match risk
        final riskData = await dataSource.getMatchRisk(event.matchId);
        final matchRisk = MatchRisk.fromJson(riskData);

        // Load match robustness
        final robustnessData = await dataSource.getMatchRobustness(event.matchId);
        final matchRobustness = MatchRobustness.fromJson(robustnessData);

        // Try to load matchup if match has opponent and map
        MatchupSummary? matchup;
        try {
          // We need teamId, opponentId, and mapId from match
          // For now, we'll skip matchup if not available
          // In a real implementation, you'd get these from the match entity
        } catch (e) {
          // Matchup not available
        }

        emit(currentState.copyWith(
          matchIntel: matchIntel,
          matchRisk: matchRisk,
          matchRobustness: matchRobustness,
          matchup: matchup,
        ));
      } catch (e) {
        // Ignore errors - intelligence might not be available
      }
    }
  }

  Future<void> _onSimulateRequested(
    SimulateRequested event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      emit(currentState.copyWith(advisoryLoading: true));
      
      try {
        // For now, we'll need teamId, opponentId, and mapId
        // These should come from the match detail or be passed separately
        // For this implementation, we'll show an error if not available
        // In production, you'd fetch these from the match detail endpoint
        
        // Simulate with default adjustments (0, 0, 0)
        // This is a placeholder - in production you'd get teamId, opponentId, mapId from match
        // For now, we'll just refresh match intelligence
        add(MatchIntelligenceRequested(event.matchId));
      } catch (e) {
        // Handle error
      } finally {
        emit(currentState.copyWith(advisoryLoading: false));
      }
    }
  }

  Future<void> _onOptimizeRequested(
    OptimizeRequested event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      emit(currentState.copyWith(advisoryLoading: true));
      
      try {
        // Optimize matchup
        // For now, we'll need teamId, opponentId, and mapId
        // These should come from the match detail or be passed separately
        // For this implementation, we'll show an error if not available
        
        // This is a placeholder - in production you'd get teamId, opponentId, mapId from match
        // For now, we'll just show loading and then load recommendations
        final recommendations = await dataSource.getRecommendations(''); // teamId needed
        final parsedRecommendations = recommendations
            .take(3)
            .map((json) => Recommendation.fromOptimizedSolution(json, recommendations.indexOf(json) + 1))
            .toList();
        
        emit(currentState.copyWith(
          recommendations: parsedRecommendations,
          advisoryLoading: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(advisoryLoading: false));
      }
    }
  }

  Future<void> _onRecommendationApplied(
    RecommendationApplied event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      try {
        await dataSource.applyRecommendation(event.recommendationId);
        
        // Schedule debounced match intelligence refresh after applying recommendation
        _scheduleIntelligenceRefresh(currentState.match.id);
        if (currentState.rounds.isNotEmpty) {
          final selectedRound = currentState.rounds[currentState.selectedIndex];
          add(RoundIntelligenceLoaded(selectedRound.id));
          add(TacticalEventsLoaded(selectedRound.id));
        }
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> _onRecommendationsLoaded(
    RecommendationsLoaded event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      try {
        // For now, we'll need teamId
        // This is a placeholder - in production you'd get teamId from match
        final recommendations = await dataSource.getRecommendations(''); // teamId needed
        final parsedRecommendations = recommendations
            .take(3)
            .map((json) => Recommendation.fromOptimizedSolution(json, recommendations.indexOf(json) + 1))
            .toList();
        
        emit(currentState.copyWith(recommendations: parsedRecommendations));
      } catch (e) {
        // Ignore errors
      }
    }
  }

  Future<void> _onRecommendationHistoryRequested(
    RecommendationHistoryRequested event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      try {
        // For now, we'll need teamId - this should come from match
        // For this implementation, we'll use recommendations endpoint
        // In production, you'd get teamId from match detail
        final recommendations = await dataSource.getRecommendations(''); // teamId needed
        final history = recommendations
            .map((json) => RecommendationHistoryItem.fromJson(json))
            .toList();

        // Also load advisor performance
        try {
          final performanceData = await dataSource.getAdvisorPerformance(''); // teamId needed
          final performance = AdvisorPerformance.fromJson(performanceData);
          emit(currentState.copyWith(
            recommendationHistory: history,
            advisorPerformance: performance,
          ));
        } catch (e) {
          // If performance endpoint fails, just update history
          emit(currentState.copyWith(recommendationHistory: history));
        }
      } catch (e) {
        // Ignore errors
      }
    }
  }

  Future<void> _onImpactRequested(
    ImpactRequested event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      try {
        final impactData = await dataSource.getRecommendationImpact(event.recommendationId);
        if (impactData != null) {
          final impact = RecommendationImpact.fromJson(impactData);
          emit(currentState.copyWith(selectedImpact: impact));
        } else {
          // If no dedicated endpoint, try to compute from application data
          // For now, we'll just show a placeholder
          // In production, you'd fetch from recommendation application
        }
      } catch (e) {
        // Ignore errors
      }
    }
  }

  void _onActivityAdded(
    ActivityAdded event,
    Emitter<WorkspaceState> emit,
  ) {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      final activity = ActivityItem(
        message: event.message,
        timestamp: DateTime.now(),
        userId: event.userId,
        eventType: event.eventType,
      );
      emit(currentState.addActivity(activity));
    }
  }

  void _onPresenceUserJoined(
    PresenceUserJoined event,
    Emitter<WorkspaceState> emit,
  ) {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      final user = PresenceUser(
        userId: event.userId,
        email: event.email,
        name: event.name,
      );
      emit(currentState.addPresenceUser(user));
    }
  }

  void _onPresenceUserLeft(
    PresenceUserLeft event,
    Emitter<WorkspaceState> emit,
  ) {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      emit(currentState.removePresenceUser(event.userId));
    }
  }

  Future<void> _onDraftRecoveryRequested(
    DraftRecoveryRequested event,
    Emitter<WorkspaceState> emit,
  ) async {
    // This event is handled by UI to show recovery dialog
    // The actual restoration happens via DraftRestored event
  }

  Future<void> _onDraftRestored(
    DraftRestored event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      final draft = await _draftDataSource.getDraft(event.roundId);
      if (draft != null) {
        // Restore notes
        final updatedRounds = currentState.rounds.map((round) {
          if (round.id == event.roundId) {
            return round.copyWith(notes: draft.notes);
          }
          return round;
        }).toList();

        // Restore canvas
        final drawingJson = draft.drawingJson;
        final strokes = (drawingJson['strokes'] as List<dynamic>?)
            ?.map((s) => CanvasStroke.fromJson(s as Map<String, dynamic>))
            .toList() ?? [];
        final arrows = (drawingJson['arrows'] as List<dynamic>?)
            ?.map((a) => CanvasArrow.fromJson(a as Map<String, dynamic>))
            .toList() ?? [];
        final objects = (drawingJson['objects'] as List<dynamic>?)
            ?.map((o) => CanvasObject.fromJson(o as Map<String, dynamic>))
            .toList() ?? [];

        // Restore buy plan
        final playerBuys = draft.buys;

        emit(currentState.copyWith(
          rounds: updatedRounds,
          canvasStrokes: {
            ...currentState.canvasStrokes,
            event.roundId: strokes,
          },
          canvasArrows: {
            ...currentState.canvasArrows,
            event.roundId: arrows,
          },
          canvasObjects: {
            ...currentState.canvasObjects,
            event.roundId: objects,
          },
          playerBuys: {
            ...currentState.playerBuys,
            event.roundId: playerBuys,
          },
          hasUnsavedChanges: true,
        ));

        // Schedule auto-save
        _scheduleAutoSave(event.roundId);
      }
    }
  }

  Future<void> _onDraftDiscarded(
    DraftDiscarded event,
    Emitter<WorkspaceState> emit,
  ) async {
    await _draftDataSource.deleteDraft(event.roundId);
  }

  void _onVersionConflictDetected(
    VersionConflictDetected event,
    Emitter<WorkspaceState> emit,
  ) {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      emit(currentState.copyWith(versionConflict: true));
    }
  }

  Future<void> _onConflictResolved(
    ConflictResolved event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      
      if (event.keepDraft) {
        // Keep draft - reload from server but don't overwrite local changes
        // Just clear conflict flag
        emit(currentState.copyWith(versionConflict: false));
      } else {
        // Reload from server - discard local changes
        final round = currentState.rounds.firstWhere((r) => r.id == event.roundId);
        add(RoundSelected(currentState.rounds.indexOf(round)));
        emit(currentState.copyWith(versionConflict: false, hasUnsavedChanges: false));
        // Delete draft
        await _draftDataSource.deleteDraft(event.roundId);
      }
    }
  }

  void _onWebSocketDisconnected(
    WebSocketDisconnected event,
    Emitter<WorkspaceState> emit,
  ) {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      _telemetry.track("WS_DISCONNECT");
      emit(currentState.copyWith(offlineMode: true));
      
      // Save all unsaved changes as drafts
      if (currentState.hasUnsavedChanges && currentState.rounds.isNotEmpty) {
        final currentRound = currentState.rounds[currentState.selectedIndex];
        _saveDraftLocally(currentRound.id, currentState);
      }
    }
  }

  void _onWebSocketReconnected(
    WebSocketReconnected event,
    Emitter<WorkspaceState> emit,
  ) {
    if (state is WorkspaceLoadedState) {
      final currentState = state as WorkspaceLoadedState;
      emit(currentState.copyWith(offlineMode: false));
      
      // Sync drafts when reconnected
      if (currentState.rounds.isNotEmpty) {
        final currentRound = currentState.rounds[currentState.selectedIndex];
        _scheduleAutoSave(currentRound.id);
      }
    }
  }

}
