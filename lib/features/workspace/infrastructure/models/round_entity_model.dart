import '../../domain/entities/round_entity.dart';

class RoundEntityModel {
  final String id;
  final int roundNumber;
  final String side;
  final String? notes;
  final Map<String, dynamic>? gameData;

  RoundEntityModel({
    required this.id,
    required this.roundNumber,
    required this.side,
    this.notes,
    this.gameData,
  });

  factory RoundEntityModel.fromJson(Map<String, dynamic> json) {
    final gameData = json['gameData'];
    return RoundEntityModel(
      id: json['id'] as String? ?? '',
      roundNumber: json['roundNumber'] as int? ?? 0,
      side: json['side'] as String? ?? 'ATTACK',
      notes: json['notes'] as String?,
      gameData: gameData is Map<String, dynamic> ? gameData : null,
    );
  }

  RoundEntity toEntity() {
    return RoundEntity(
      id: id,
      roundNumber: roundNumber,
      side: side,
      notes: notes,
      gameData: gameData,
    );
  }
}



