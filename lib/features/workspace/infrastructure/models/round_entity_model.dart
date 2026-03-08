import '../../domain/entities/round_entity.dart';

class RoundEntityModel {
  final String id;
  final int roundNumber;
  final String side;
  final String? notes;

  RoundEntityModel({
    required this.id,
    required this.roundNumber,
    required this.side,
    this.notes,
  });

  factory RoundEntityModel.fromJson(Map<String, dynamic> json) {
    return RoundEntityModel(
      id: json['id'] as String? ?? '',
      roundNumber: json['roundNumber'] as int? ?? 0,
      side: json['side'] as String? ?? 'ATTACK',
      notes: json['notes'] as String?,
    );
  }

  RoundEntity toEntity() {
    return RoundEntity(
      id: id,
      roundNumber: roundNumber,
      side: side,
      notes: notes,
    );
  }
}



