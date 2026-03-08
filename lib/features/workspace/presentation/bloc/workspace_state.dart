import 'package:equatable/equatable.dart';
import '../../domain/entities/match_detail.dart';
import '../../domain/entities/round_entity.dart';
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
import '../widgets/canvas/canvas_models.dart';

abstract class WorkspaceState extends Equatable {
  const WorkspaceState();

  @override
  List<Object?> get props => [];
}

class WorkspaceLoading extends WorkspaceState {}

class WorkspaceLoadedState extends WorkspaceState {
  final MatchDetail match;
  final List<RoundEntity> rounds;
  final int selectedIndex;
  final Map<String, LockStatus> lockStatuses; // roundId -> LockStatus
  final Map<String, List<TacticalEvent>> tacticalEvents; // roundId -> events
  final Map<String, List<CanvasStroke>> canvasStrokes; // roundId -> strokes
  final Map<String, List<CanvasArrow>> canvasArrows; // roundId -> arrows
  final Map<String, List<CanvasObject>> canvasObjects; // roundId -> objects
  final Map<String, BuyType?> buyTypes; // roundId -> buyType
  final Map<String, List<PlayerBuy>> playerBuys; // roundId -> playerBuys
  final Map<String, RoundIntelligence?> roundIntelligence; // roundId -> intelligence
  final Map<String, RoundIntelligence?> previousIntelligence; // roundId -> previous intelligence (for delta)
  final MatchIntelligence? matchIntel;
  final MatchRisk? matchRisk;
  final MatchRobustness? matchRobustness;
  final MatchupSummary? matchup;
  final List<Recommendation> recommendations;
  final bool advisoryLoading;
  final List<RecommendationHistoryItem> recommendationHistory;
  final RecommendationImpact? selectedImpact;
  final AdvisorPerformance? advisorPerformance;
  final List<ActivityItem> activities;
  final List<PresenceUser> activeUsers;
  final bool hasUnsavedChanges;
  final bool offlineMode;
  final bool versionConflict;

  const WorkspaceLoadedState({
    required this.match,
    required this.rounds,
    required this.selectedIndex,
    Map<String, LockStatus>? lockStatuses,
    Map<String, List<TacticalEvent>>? tacticalEvents,
    Map<String, List<CanvasStroke>>? canvasStrokes,
    Map<String, List<CanvasArrow>>? canvasArrows,
    Map<String, List<CanvasObject>>? canvasObjects,
    Map<String, BuyType?>? buyTypes,
    Map<String, List<PlayerBuy>>? playerBuys,
    Map<String, RoundIntelligence?>? roundIntelligence,
    Map<String, RoundIntelligence?>? previousIntelligence,
    MatchIntelligence? matchIntel,
    MatchRisk? matchRisk,
    MatchRobustness? matchRobustness,
    MatchupSummary? matchup,
    List<Recommendation>? recommendations,
    bool? advisoryLoading,
    List<RecommendationHistoryItem>? recommendationHistory,
    RecommendationImpact? selectedImpact,
    AdvisorPerformance? advisorPerformance,
    List<ActivityItem>? activities,
    List<PresenceUser>? activeUsers,
    bool? hasUnsavedChanges,
    bool? offlineMode,
    bool? versionConflict,
  })  : lockStatuses = lockStatuses ?? const {},
        tacticalEvents = tacticalEvents ?? const {},
        canvasStrokes = canvasStrokes ?? const {},
        canvasArrows = canvasArrows ?? const {},
        canvasObjects = canvasObjects ?? const {},
        buyTypes = buyTypes ?? const {},
        playerBuys = playerBuys ?? const {},
        roundIntelligence = roundIntelligence ?? const {},
        previousIntelligence = previousIntelligence ?? const {},
        matchIntel = matchIntel,
        matchRisk = matchRisk,
        matchRobustness = matchRobustness,
        matchup = matchup,
        recommendations = recommendations ?? const [],
        advisoryLoading = advisoryLoading ?? false,
        recommendationHistory = recommendationHistory ?? const [],
        selectedImpact = selectedImpact,
        advisorPerformance = advisorPerformance,
        activities = activities ?? const [],
        activeUsers = activeUsers ?? const [],
        hasUnsavedChanges = hasUnsavedChanges ?? false,
        offlineMode = offlineMode ?? false,
        versionConflict = versionConflict ?? false;

  LockStatus? getLockStatus(String roundId) {
    return lockStatuses[roundId] ?? LockStatus.empty();
  }

  bool isRoundLocked(String roundId) {
    final status = lockStatuses[roundId];
    return status?.locked ?? false;
  }

  bool isRoundLockedByCurrentUser(String roundId, String currentUserId) {
    final status = lockStatuses[roundId];
    return status?.locked == true && status?.lockedByUserId == currentUserId;
  }

  WorkspaceLoadedState copyWith({
    MatchDetail? match,
    List<RoundEntity>? rounds,
    int? selectedIndex,
    Map<String, LockStatus>? lockStatuses,
    Map<String, List<TacticalEvent>>? tacticalEvents,
    Map<String, List<CanvasStroke>>? canvasStrokes,
    Map<String, List<CanvasArrow>>? canvasArrows,
    Map<String, List<CanvasObject>>? canvasObjects,
    Map<String, BuyType?>? buyTypes,
    Map<String, List<PlayerBuy>>? playerBuys,
    Map<String, RoundIntelligence?>? roundIntelligence,
    Map<String, RoundIntelligence?>? previousIntelligence,
    MatchIntelligence? matchIntel,
    MatchRisk? matchRisk,
    MatchRobustness? matchRobustness,
    MatchupSummary? matchup,
    List<Recommendation>? recommendations,
    bool? advisoryLoading,
    List<RecommendationHistoryItem>? recommendationHistory,
    RecommendationImpact? selectedImpact,
    AdvisorPerformance? advisorPerformance,
    List<ActivityItem>? activities,
    List<PresenceUser>? activeUsers,
    bool? hasUnsavedChanges,
    bool? offlineMode,
    bool? versionConflict,
  }) {
    return WorkspaceLoadedState(
      match: match ?? this.match,
      rounds: rounds ?? this.rounds,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      lockStatuses: lockStatuses ?? this.lockStatuses,
      tacticalEvents: tacticalEvents ?? this.tacticalEvents,
      canvasStrokes: canvasStrokes ?? this.canvasStrokes,
      canvasArrows: canvasArrows ?? this.canvasArrows,
      canvasObjects: canvasObjects ?? this.canvasObjects,
      buyTypes: buyTypes ?? this.buyTypes,
      playerBuys: playerBuys ?? this.playerBuys,
      roundIntelligence: roundIntelligence ?? this.roundIntelligence,
      previousIntelligence: previousIntelligence ?? this.previousIntelligence,
      matchIntel: matchIntel ?? this.matchIntel,
      matchRisk: matchRisk ?? this.matchRisk,
      matchRobustness: matchRobustness ?? this.matchRobustness,
      matchup: matchup ?? this.matchup,
      recommendations: recommendations ?? this.recommendations,
      advisoryLoading: advisoryLoading ?? this.advisoryLoading,
      recommendationHistory: recommendationHistory ?? this.recommendationHistory,
      selectedImpact: selectedImpact ?? this.selectedImpact,
      advisorPerformance: advisorPerformance ?? this.advisorPerformance,
      activities: activities ?? this.activities,
      activeUsers: activeUsers ?? this.activeUsers,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      offlineMode: offlineMode ?? this.offlineMode,
      versionConflict: versionConflict ?? this.versionConflict,
    );
  }

  WorkspaceLoadedState addActivity(ActivityItem activity) {
    final updated = List<ActivityItem>.from(activities);
    updated.insert(0, activity);
    // Keep only last 20 activities
    if (updated.length > 20) {
      updated.removeRange(20, updated.length);
    }
    return copyWith(activities: updated);
  }

  WorkspaceLoadedState addPresenceUser(PresenceUser user) {
    final updated = List<PresenceUser>.from(activeUsers);
    if (!updated.any((u) => u.userId == user.userId)) {
      updated.add(user);
    }
    return copyWith(activeUsers: updated);
  }

  WorkspaceLoadedState removePresenceUser(String userId) {
    final updated = List<PresenceUser>.from(activeUsers);
    updated.removeWhere((u) => u.userId == userId);
    return copyWith(activeUsers: updated);
  }

  WorkspaceLoadedState updateLockStatus(String roundId, LockStatus status) {
    final updated = Map<String, LockStatus>.from(lockStatuses);
    updated[roundId] = status;
    return copyWith(lockStatuses: updated);
  }

  WorkspaceLoadedState updateTacticalEvents(String roundId, List<TacticalEvent> events) {
    final updated = Map<String, List<TacticalEvent>>.from(tacticalEvents);
    updated[roundId] = events;
    return copyWith(tacticalEvents: updated);
  }

  WorkspaceLoadedState updateCanvasStrokes(String roundId, List<CanvasStroke> strokes) {
    final updated = Map<String, List<CanvasStroke>>.from(canvasStrokes);
    updated[roundId] = strokes;
    return copyWith(canvasStrokes: updated);
  }

  WorkspaceLoadedState updateCanvasDrawing(
    String roundId, {
    List<CanvasStroke>? strokes,
    List<CanvasArrow>? arrows,
    List<CanvasObject>? objects,
  }) {
    final updatedStrokes = strokes != null
        ? (Map<String, List<CanvasStroke>>.from(canvasStrokes)..[roundId] = strokes)
        : canvasStrokes;
    final updatedArrows = arrows != null
        ? (Map<String, List<CanvasArrow>>.from(canvasArrows)..[roundId] = arrows)
        : canvasArrows;
    final updatedObjects = objects != null
        ? (Map<String, List<CanvasObject>>.from(canvasObjects)..[roundId] = objects)
        : canvasObjects;
    return copyWith(
      canvasStrokes: updatedStrokes,
      canvasArrows: updatedArrows,
      canvasObjects: updatedObjects,
    );
  }

  WorkspaceLoadedState updateBuyPlan(
    String roundId, {
    BuyType? buyType,
    List<PlayerBuy>? playerBuys,
  }) {
    final updatedBuyTypes = buyType != null
        ? (Map<String, BuyType?>.from(buyTypes)..[roundId] = buyType)
        : buyTypes;
    final updatedPlayerBuys = playerBuys != null
        ? (Map<String, List<PlayerBuy>>.from(this.playerBuys)..[roundId] = playerBuys)
        : this.playerBuys;
    return copyWith(
      buyTypes: updatedBuyTypes,
      playerBuys: updatedPlayerBuys,
    );
  }

  RoundIntelligence? getRoundIntelligence(String roundId) {
    return roundIntelligence[roundId];
  }

  RoundIntelligence? getPreviousIntelligence(String roundId) {
    return previousIntelligence[roundId];
  }

  WorkspaceLoadedState updateRoundIntelligence(
    String roundId,
    RoundIntelligence? intelligence,
  ) {
    // Store current as previous before updating
    final current = roundIntelligence[roundId];
    final updatedPrevious = current != null
        ? (Map<String, RoundIntelligence?>.from(previousIntelligence)..[roundId] = current)
        : previousIntelligence;

    final updated = intelligence != null
        ? (Map<String, RoundIntelligence?>.from(roundIntelligence)..[roundId] = intelligence)
        : roundIntelligence;

    return copyWith(
      roundIntelligence: updated,
      previousIntelligence: updatedPrevious,
    );
  }

  @override
  List<Object?> get props => [
        match,
        rounds,
        selectedIndex,
        lockStatuses,
        tacticalEvents,
        canvasStrokes,
        canvasArrows,
        canvasObjects,
        buyTypes,
        playerBuys,
        roundIntelligence,
        previousIntelligence,
        matchIntel,
        matchRisk,
        matchRobustness,
        matchup,
        recommendations,
        advisoryLoading,
        recommendationHistory,
        selectedImpact,
        advisorPerformance,
        activities,
        activeUsers,
        hasUnsavedChanges,
        offlineMode,
        versionConflict,
      ];
}

class WorkspaceError extends WorkspaceState {
  final String message;

  const WorkspaceError(this.message);

  @override
  List<Object?> get props => [message];
}

