import 'package:equatable/equatable.dart';

class RoundEntity extends Equatable {
  final String id;
  final int roundNumber;
  final String side; // ATTACK / DEFENSE
  final String? notes;
  /// Round game_data (e.g. Valorant: attackComp, ults, creditsPlan). DAY_128.
  final Map<String, dynamic>? gameData;

  const RoundEntity({
    required this.id,
    required this.roundNumber,
    required this.side,
    this.notes,
    this.gameData,
  });

  RoundEntity copyWith({
    String? id,
    int? roundNumber,
    String? side,
    String? notes,
    Map<String, dynamic>? gameData,
  }) {
    return RoundEntity(
      id: id ?? this.id,
      roundNumber: roundNumber ?? this.roundNumber,
      side: side ?? this.side,
      notes: notes ?? this.notes,
      gameData: gameData ?? this.gameData,
    );
  }

  @override
  List<Object?> get props => [id, roundNumber, side, notes, gameData];
}



