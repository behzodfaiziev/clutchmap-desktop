import 'package:equatable/equatable.dart';

class MatchDetail extends Equatable {
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

  const MatchDetail({
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
  });

  @override
  List<Object?> get props => [id, title, mapId, mapName, archived, gameId, gameCode, gameName, startingSide, opponentId, opponentName, createdAt, updatedAt];
}



