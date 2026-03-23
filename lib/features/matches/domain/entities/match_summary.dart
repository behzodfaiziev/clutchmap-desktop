import 'package:equatable/equatable.dart';

class MatchSummary extends Equatable {
  final String id;
  final String title;
  final String? mapName;
  final String? gameId;
  final String? gameName;
  final String? startingSide;
  final String? opponentId;
  final String? folderName;
  final bool archived;
  final DateTime updatedAt;

  const MatchSummary({
    required this.id,
    required this.title,
    this.mapName,
    this.gameId,
    this.gameName,
    this.startingSide,
    this.opponentId,
    this.folderName,
    required this.archived,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, mapName, gameId, gameName, startingSide, opponentId, folderName, archived, updatedAt];
}



