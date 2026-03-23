import '../../domain/entities/match_summary.dart';

class MatchSummaryModel {
  final String id;
  final String title;
  final String? mapName;
  final String? gameId;
  final String? gameName;
  final String? startingSide;
  final String? opponentId;
  final String? folderName;
  final bool archived;
  final String updatedAt;

  MatchSummaryModel({
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

  factory MatchSummaryModel.fromJson(Map<String, dynamic> json) {
    return MatchSummaryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      mapName: json['mapName'] as String?,
      gameId: json['gameId']?.toString(),
      gameName: json['gameName'] as String?,
      startingSide: json['startingSide'] as String?,
      opponentId: json['opponentId']?.toString(),
      folderName: json['folderName'] as String?,
      archived: json['archived'] as bool? ?? false,
      updatedAt: json['updatedAt'] as String? ?? json['createdAt'] as String? ?? '',
    );
  }

  MatchSummary toEntity() {
    return MatchSummary(
      id: id,
      title: title,
      mapName: mapName,
      gameId: gameId,
      gameName: gameName,
      startingSide: startingSide,
      opponentId: opponentId,
      folderName: folderName,
      archived: archived,
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
    );
  }
}



