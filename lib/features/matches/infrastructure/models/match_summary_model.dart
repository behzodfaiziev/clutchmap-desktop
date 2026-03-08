import '../../domain/entities/match_summary.dart';

class MatchSummaryModel {
  final String id;
  final String title;
  final String? mapName;
  final bool archived;
  final String updatedAt;

  MatchSummaryModel({
    required this.id,
    required this.title,
    this.mapName,
    required this.archived,
    required this.updatedAt,
  });

  factory MatchSummaryModel.fromJson(Map<String, dynamic> json) {
    return MatchSummaryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      mapName: json['mapName'] as String?,
      archived: json['archived'] as bool? ?? false,
      updatedAt: json['updatedAt'] as String? ?? json['createdAt'] as String? ?? '',
    );
  }

  MatchSummary toEntity() {
    return MatchSummary(
      id: id,
      title: title,
      mapName: mapName,
      archived: archived,
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
    );
  }
}



