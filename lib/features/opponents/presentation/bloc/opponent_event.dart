import 'package:equatable/equatable.dart';

abstract class OpponentEvent extends Equatable {
  const OpponentEvent();

  @override
  List<Object?> get props => [];
}

class OpponentsLoaded extends OpponentEvent {
  const OpponentsLoaded();
}

class OpponentSelected extends OpponentEvent {
  final String opponentId;
  final String teamId;

  const OpponentSelected({
    required this.opponentId,
    required this.teamId,
  });

  @override
  List<Object?> get props => [opponentId, teamId];
}

class OpponentCreated extends OpponentEvent {
  final String name;
  final String? region;
  final String? notes;
  final List<String>? tags;

  const OpponentCreated({
    required this.name,
    this.region,
    this.notes,
    this.tags,
  });

  @override
  List<Object?> get props => [name, region, notes, tags];
}

class OpponentUpdated extends OpponentEvent {
  final String opponentId;
  final String name;
  final String? region;
  final String? notes;
  final List<String>? tags;

  const OpponentUpdated({
    required this.opponentId,
    required this.name,
    this.region,
    this.notes,
    this.tags,
  });

  @override
  List<Object?> get props => [opponentId, name, region, notes, tags];
}

class OpponentDeleted extends OpponentEvent {
  final String opponentId;

  const OpponentDeleted(this.opponentId);

  @override
  List<Object?> get props => [opponentId];
}



