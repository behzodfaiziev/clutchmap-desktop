import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
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



