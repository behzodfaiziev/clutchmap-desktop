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



