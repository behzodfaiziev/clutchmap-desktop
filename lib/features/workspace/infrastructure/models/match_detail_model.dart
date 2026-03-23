import '../../domain/entities/match_detail.dart';
import 'round_entity_model.dart';

class MatchDetailModel {
  final String id;
  final String title;
  final String? mapId;
  final String? mapName;
  final bool archived;
  final String? gameId;
  final String? gameCode;
  final String? gameName;
  final String? startingSide;
  final String? opponentId;
  final String? opponentName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<RoundEntityModel>? rounds;

  MatchDetailModel({
    required this.id,
    required this.title,
    this.mapId,
    this.mapName,
    required this.archived,
    this.gameId,
    this.gameCode,
    this.gameName,
    this.startingSide,
    this.opponentId,
    this.opponentName,
    this.createdAt,
    this.updatedAt,
    this.rounds,
  });

  factory MatchDetailModel.fromJson(Map<String, dynamic> json) {
    DateTime? createdAt;
    final c = json['createdAt'];
    if (c != null) {
      if (c is String) createdAt = DateTime.tryParse(c);
    }
    DateTime? updatedAt;
    final u = json['updatedAt'];
    if (u != null) {
      if (u is String) updatedAt = DateTime.tryParse(u);
    }
    List<RoundEntityModel>? rounds;
    final r = json['rounds'];
    if (r is List) {
      rounds = r
          .map((e) => RoundEntityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return MatchDetailModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      mapId: json['mapId']?.toString(),
      mapName: json['mapName'] as String?,
      archived: json['archived'] as bool? ?? false,
      gameId: json['gameId']?.toString(),
      gameCode: json['gameCode'] as String?,
      gameName: json['gameName'] as String?,
      startingSide: json['startingSide'] as String?,
      opponentId: json['opponentId']?.toString(),
      opponentName: json['opponentName'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
      rounds: rounds,
    );
  }

  MatchDetail toEntity() {
    return MatchDetail(
      id: id,
      title: title,
      mapId: mapId,
      mapName: mapName,
      archived: archived,
      gameId: gameId,
      gameCode: gameCode,
      gameName: gameName,
      startingSide: startingSide,
      opponentId: opponentId,
      opponentName: opponentName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}



