import 'package:equatable/equatable.dart';

abstract class MatchesEvent extends Equatable {
  const MatchesEvent();

  @override
  List<Object?> get props => [];
}

class MatchesLoaded extends MatchesEvent {
  final String? filter;
  /// Text search (backend param q).
  final String? query;
  /// Optional backend filters for GET /match-plans.
  final String? folderId;
  final String? gameId;
  final String? mapId;
  final String? opponentId;
  /// When set, emitted state will include this as [MatchesLoadedState.lastCreatedMatchId].
  final String? createdMatchId;
  /// True when [createdMatchId] is from duplicating a match (for UI feedback).
  final bool createdWasDuplicate;

  const MatchesLoaded({
    this.filter,
    this.query,
    this.folderId,
    this.gameId,
    this.mapId,
    this.opponentId,
    this.createdMatchId,
    this.createdWasDuplicate = false,
  });

  @override
  List<Object?> get props => [filter, query, folderId, gameId, mapId, opponentId, createdMatchId, createdWasDuplicate];
}

class MatchCreated extends MatchesEvent {
  final String title;
  final String? mapId;
  final String? gameId;
  final String? folderId;
  final String? opponentId;
  final String? startingSide;

  const MatchCreated({
    required this.title,
    this.mapId,
    this.gameId,
    this.folderId,
    this.opponentId,
    this.startingSide,
  });

  @override
  List<Object?> get props => [title, mapId, gameId, folderId, opponentId, startingSide];
}

class MatchArchived extends MatchesEvent {
  final String matchId;

  const MatchArchived(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class MatchRestored extends MatchesEvent {
  final String matchId;

  const MatchRestored(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class MatchDeleted extends MatchesEvent {
  final String matchId;

  const MatchDeleted(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class MatchDuplicated extends MatchesEvent {
  final String matchId;

  const MatchDuplicated(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class ClearCreatedMatchId extends MatchesEvent {
  const ClearCreatedMatchId();
}



