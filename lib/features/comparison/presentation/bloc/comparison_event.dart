import 'package:equatable/equatable.dart';

abstract class ComparisonEvent extends Equatable {
  const ComparisonEvent();

  @override
  List<Object?> get props => [];
}

class MatchASelected extends ComparisonEvent {
  final String matchId;

  const MatchASelected(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class MatchBSelected extends ComparisonEvent {
  final String matchId;

  const MatchBSelected(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class ComparisonRequested extends ComparisonEvent {
  const ComparisonRequested();
}

class MatchesListLoaded extends ComparisonEvent {
  const MatchesListLoaded();
}


