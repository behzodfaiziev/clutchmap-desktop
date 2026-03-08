import 'package:equatable/equatable.dart';

class RoundEntity extends Equatable {
  final String id;
  final int roundNumber;
  final String side; // ATTACK / DEFENSE
  final String? notes;

  const RoundEntity({
    required this.id,
    required this.roundNumber,
    required this.side,
    this.notes,
  });

  RoundEntity copyWith({
    String? id,
    int? roundNumber,
    String? side,
    String? notes,
  }) {
    return RoundEntity(
      id: id ?? this.id,
      roundNumber: roundNumber ?? this.roundNumber,
      side: side ?? this.side,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, roundNumber, side, notes];
}



