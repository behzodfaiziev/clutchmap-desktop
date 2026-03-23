import 'package:equatable/equatable.dart';
import '../../domain/entities/match_summary.dart';

abstract class MatchesState extends Equatable {
  const MatchesState();

  @override
  List<Object?> get props => [];
}

class MatchesLoading extends MatchesState {}

class MatchesLoadedState extends MatchesState {
  final List<MatchSummary> matches;
  /// Set when a match was just created (e.g. for navigation); clear after use.
  final String? lastCreatedMatchId;
  /// True when [lastCreatedMatchId] came from duplicate (for showing "Match duplicated" snackbar).
  final bool lastCreatedWasDuplicate;
  /// Last search query used (for empty-state message when no results).
  final String? lastQuery;
  /// Last filter used (active/archived) so UI can e.g. clear search with same filter.
  final String? lastFilter;
  /// Last opponent filter (from e.g. "View matches" on Opponents page).
  final String? lastOpponentId;
  /// Last folder filter.
  final String? lastFolderId;
  /// Last game filter.
  final String? lastGameId;
  /// Last map filter.
  final String? lastMapId;
  /// ID of match currently being duplicated (for showing loading on that item).
  final String? duplicatingMatchId;
  /// Opponent id -> name for displaying "vs Name" in the list.
  final Map<String, String> opponentNamesById;

  const MatchesLoadedState(
    this.matches, {
    this.lastCreatedMatchId,
    this.lastCreatedWasDuplicate = false,
    this.lastQuery,
    this.lastFilter,
    this.lastOpponentId,
    this.lastFolderId,
    this.lastGameId,
    this.lastMapId,
    this.duplicatingMatchId,
    this.opponentNamesById = const {},
  });

  MatchesLoadedState copyWith({
    List<MatchSummary>? matches,
    String? lastCreatedMatchId,
    bool? lastCreatedWasDuplicate,
    String? lastQuery,
    String? lastFilter,
    String? lastOpponentId,
    String? lastFolderId,
    String? lastGameId,
    String? lastMapId,
    String? duplicatingMatchId,
    bool clearDuplicatingMatchId = false,
    Map<String, String>? opponentNamesById,
  }) {
    return MatchesLoadedState(
      matches ?? this.matches,
      lastCreatedMatchId: lastCreatedMatchId ?? this.lastCreatedMatchId,
      lastCreatedWasDuplicate: lastCreatedWasDuplicate ?? this.lastCreatedWasDuplicate,
      lastQuery: lastQuery ?? this.lastQuery,
      lastFilter: lastFilter ?? this.lastFilter,
      lastOpponentId: lastOpponentId ?? this.lastOpponentId,
      lastFolderId: lastFolderId ?? this.lastFolderId,
      lastGameId: lastGameId ?? this.lastGameId,
      lastMapId: lastMapId ?? this.lastMapId,
      duplicatingMatchId: clearDuplicatingMatchId ? null : (duplicatingMatchId ?? this.duplicatingMatchId),
      opponentNamesById: opponentNamesById ?? this.opponentNamesById,
    );
  }

  @override
  List<Object?> get props => [matches, lastCreatedMatchId, lastCreatedWasDuplicate, lastQuery, lastFilter, lastOpponentId, lastFolderId, lastGameId, lastMapId, duplicatingMatchId, opponentNamesById];
}

class MatchesError extends MatchesState {
  final String message;
  /// Last filter/query/filters so Retry can reload with same criteria.
  final String? lastFilter;
  final String? lastQuery;
  final String? lastOpponentId;
  final String? lastFolderId;
  final String? lastGameId;
  final String? lastMapId;

  const MatchesError(this.message, {
    this.lastFilter,
    this.lastQuery,
    this.lastOpponentId,
    this.lastFolderId,
    this.lastGameId,
    this.lastMapId,
  });

  @override
  List<Object?> get props => [message, lastFilter, lastQuery, lastOpponentId, lastFolderId, lastGameId, lastMapId];
}



