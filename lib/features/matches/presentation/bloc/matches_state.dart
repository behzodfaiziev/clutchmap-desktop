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

  const MatchesLoadedState(this.matches);

  @override
  List<Object?> get props => [matches];
}

class MatchesError extends MatchesState {
  final String message;

  const MatchesError(this.message);

  @override
  List<Object?> get props => [message];
}



