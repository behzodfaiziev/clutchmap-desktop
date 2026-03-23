import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  final String? gameType;
  final String? mapCode;
  final String? pattern;
  final List<String>? scope;

  const SearchQueryChanged(
    this.query, {
    this.gameType,
    this.mapCode,
    this.pattern,
    this.scope,
  });

  @override
  List<Object?> get props => [query, gameType, mapCode, pattern, scope];
}

class SearchResultSelected extends SearchEvent {
  final String resultId;
  final String resultType;
  final String? matchId;
  const SearchResultSelected({
    required this.resultId,
    required this.resultType,
    this.matchId,
  });

  @override
  List<Object?> get props => [resultId, resultType, matchId];
}

/// Move selection up (-1) or down (+1). Used for arrow keys.
class SearchSelectionMoved extends SearchEvent {
  final int delta;
  const SearchSelectionMoved(this.delta);

  @override
  List<Object?> get props => [delta];
}



