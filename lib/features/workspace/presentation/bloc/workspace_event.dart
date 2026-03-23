import 'package:equatable/equatable.dart';
import '../../domain/entities/lock_status.dart';
import '../../domain/entities/buy_type.dart';

abstract class WorkspaceEvent extends Equatable {
  const WorkspaceEvent();

  @override
  List<Object?> get props => [];
}

class WorkspaceLoaded extends WorkspaceEvent {
  final String matchId;

  const WorkspaceLoaded(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class RoundSelected extends WorkspaceEvent {
  final int index;

  const RoundSelected(this.index);

  @override
  List<Object?> get props => [index];
}

class RoundNotesUpdated extends WorkspaceEvent {
  final String roundId;
  final String notes;

  const RoundNotesUpdated({
    required this.roundId,
    required this.notes,
  });

  @override
  List<Object?> get props => [roundId, notes];
}

class AcquireLock extends WorkspaceEvent {
  final String roundId;
  const AcquireLock(this.roundId);

  @override
  List<Object?> get props => [roundId];
}

class ReleaseLock extends WorkspaceEvent {
  final String roundId;
  const ReleaseLock(this.roundId);

  @override
  List<Object?> get props => [roundId];
}

class LockStatusUpdated extends WorkspaceEvent {
  final String roundId;
  final LockStatus status;
  const LockStatusUpdated({required this.roundId, required this.status});

  @override
  List<Object?> get props => [roundId, status];
}

/// Extend current user's lock on a round (keep-alive). Backend: POST .../lock/renew.
class LockRenewRequested extends WorkspaceEvent {
  final String roundId;
  const LockRenewRequested(this.roundId);

  @override
  List<Object?> get props => [roundId];
}

class TacticalEventAdded extends WorkspaceEvent {
  final String roundId;
  final String eventType;
  const TacticalEventAdded({required this.roundId, required this.eventType});

  @override
  List<Object?> get props => [roundId, eventType];
}

class TacticalEventRemoved extends WorkspaceEvent {
  final String roundId;
  final String eventId;
  const TacticalEventRemoved({required this.roundId, required this.eventId});

  @override
  List<Object?> get props => [roundId, eventId];
}

class TacticalEventsLoaded extends WorkspaceEvent {
  final String roundId;
  const TacticalEventsLoaded(this.roundId);

  @override
  List<Object?> get props => [roundId];
}

class CanvasDrawingUpdated extends WorkspaceEvent {
  final String roundId;
  final List<Map<String, dynamic>> strokesJson;
  final List<Map<String, dynamic>> arrowsJson;
  final List<Map<String, dynamic>> objectsJson;
  const CanvasDrawingUpdated({
    required this.roundId,
    required this.strokesJson,
    required this.arrowsJson,
    required this.objectsJson,
  });

  @override
  List<Object?> get props => [roundId, strokesJson, arrowsJson, objectsJson];
}

class CanvasDrawingLoaded extends WorkspaceEvent {
  final String roundId;
  const CanvasDrawingLoaded(this.roundId);

  @override
  List<Object?> get props => [roundId];
}

class BuyTypeChanged extends WorkspaceEvent {
  final String roundId;
  final BuyType buyType;
  const BuyTypeChanged({
    required this.roundId,
    required this.buyType,
  });

  @override
  List<Object?> get props => [roundId, buyType];
}

class PlayerBuyChanged extends WorkspaceEvent {
  final String roundId;
  final String playerId;
  final String weapon;
  const PlayerBuyChanged({
    required this.roundId,
    required this.playerId,
    required this.weapon,
  });

  @override
  List<Object?> get props => [roundId, playerId, weapon];
}

class BuyPlanLoaded extends WorkspaceEvent {
  final String roundId;
  const BuyPlanLoaded(this.roundId);

  @override
  List<Object?> get props => [roundId];
}

class RoundIntelligenceLoaded extends WorkspaceEvent {
  final String roundId;
  const RoundIntelligenceLoaded(this.roundId);

  @override
  List<Object?> get props => [roundId];
}

class MatchIntelligenceRequested extends WorkspaceEvent {
  final String matchId;
  const MatchIntelligenceRequested(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class SimulateRequested extends WorkspaceEvent {
  final String matchId;
  const SimulateRequested(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class OptimizeRequested extends WorkspaceEvent {
  final String matchId;
  final String mode;
  const OptimizeRequested({
    required this.matchId,
    required this.mode,
  });

  @override
  List<Object?> get props => [matchId, mode];
}

class RecommendationApplied extends WorkspaceEvent {
  final String recommendationId;
  const RecommendationApplied(this.recommendationId);

  @override
  List<Object?> get props => [recommendationId];
}

class PreviewApplyRequested extends WorkspaceEvent {
  final String recommendationId;
  const PreviewApplyRequested(this.recommendationId);

  @override
  List<Object?> get props => [recommendationId];
}

class ClearRecommendationPreview extends WorkspaceEvent {
  const ClearRecommendationPreview();
}

class RecommendationsLoaded extends WorkspaceEvent {
  final String matchId;
  const RecommendationsLoaded(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class ActivityAdded extends WorkspaceEvent {
  final String message;
  final String? userId;
  final String? eventType;
  const ActivityAdded({
    required this.message,
    this.userId,
    this.eventType,
  });

  @override
  List<Object?> get props => [message, userId, eventType];
}

class PresenceUserJoined extends WorkspaceEvent {
  final String userId;
  final String email;
  final String? name;
  const PresenceUserJoined({
    required this.userId,
    required this.email,
    this.name,
  });

  @override
  List<Object?> get props => [userId, email, name];
}

class PresenceUserLeft extends WorkspaceEvent {
  final String userId;
  const PresenceUserLeft(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RecommendationHistoryRequested extends WorkspaceEvent {
  final String matchId;
  const RecommendationHistoryRequested(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class ImpactRequested extends WorkspaceEvent {
  final String recommendationId;
  const ImpactRequested(this.recommendationId);

  @override
  List<Object?> get props => [recommendationId];
}

class DraftRecoveryRequested extends WorkspaceEvent {
  final String roundId;
  const DraftRecoveryRequested(this.roundId);

  @override
  List<Object?> get props => [roundId];
}

class DraftRestored extends WorkspaceEvent {
  final String roundId;
  const DraftRestored(this.roundId);

  @override
  List<Object?> get props => [roundId];
}

class DraftDiscarded extends WorkspaceEvent {
  final String roundId;
  const DraftDiscarded(this.roundId);

  @override
  List<Object?> get props => [roundId];
}

class VersionConflictDetected extends WorkspaceEvent {
  final String roundId;
  const VersionConflictDetected(this.roundId);

  @override
  List<Object?> get props => [roundId];
}

class ConflictResolved extends WorkspaceEvent {
  final String roundId;
  final bool keepDraft;
  const ConflictResolved({
    required this.roundId,
    required this.keepDraft,
  });

  @override
  List<Object?> get props => [roundId, keepDraft];
}

class WebSocketDisconnected extends WorkspaceEvent {
  const WebSocketDisconnected();
}

class WebSocketReconnected extends WorkspaceEvent {
  const WebSocketReconnected();
}

/// User requested to archive the current match (from workspace toolbar).
class MatchArchiveRequested extends WorkspaceEvent {
  const MatchArchiveRequested();
}

/// User requested to restore (unarchive) the current match (from workspace toolbar).
class MatchUnarchiveRequested extends WorkspaceEvent {
  const MatchUnarchiveRequested();
}

