import 'package:equatable/equatable.dart';

abstract class MatchesEvent extends Equatable {
  const MatchesEvent();

  @override
  List<Object?> get props => [];
}

class MatchesLoaded extends MatchesEvent {
  final String? filter;

  const MatchesLoaded({this.filter});

  @override
  List<Object?> get props => [filter];
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



