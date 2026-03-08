import 'package:equatable/equatable.dart';
import '../../domain/entities/opponent_profile.dart';
import '../../domain/entities/matchup_analysis.dart';

abstract class OpponentState extends Equatable {
  const OpponentState();

  @override
  List<Object?> get props => [];
}

class OpponentLoading extends OpponentState {}

class OpponentLoadedState extends OpponentState {
  final List<OpponentProfile> opponents;
  final OpponentProfile? selectedOpponent;
  final OpponentProfile? teamProfile;
  final MatchupAnalysis? matchup;
  final String? selectedMapId;

  const OpponentLoadedState({
    required this.opponents,
    this.selectedOpponent,
    this.teamProfile,
    this.matchup,
    this.selectedMapId,
  });

  OpponentLoadedState copyWith({
    List<OpponentProfile>? opponents,
    OpponentProfile? selectedOpponent,
    OpponentProfile? teamProfile,
    MatchupAnalysis? matchup,
    String? selectedMapId,
  }) {
    return OpponentLoadedState(
      opponents: opponents ?? this.opponents,
      selectedOpponent: selectedOpponent ?? this.selectedOpponent,
      teamProfile: teamProfile ?? this.teamProfile,
      matchup: matchup ?? this.matchup,
      selectedMapId: selectedMapId ?? this.selectedMapId,
    );
  }

  @override
  List<Object?> get props => [
        opponents,
        selectedOpponent,
        teamProfile,
        matchup,
        selectedMapId,
      ];
}

class OpponentError extends OpponentState {
  final String message;

  const OpponentError(this.message);

  @override
  List<Object?> get props => [message];
}



