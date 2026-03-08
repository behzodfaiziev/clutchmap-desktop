import '../../domain/entities/match_summary.dart';

class MatchSummaryModel {
  final String id;
  final String title;
  final String? mapName;
  final String updatedAt;

  MatchSummaryModel({
    required this.id,
    required this.title,
    this.mapName,
    required this.updatedAt,
  });

  factory MatchSummaryModel.fromJson(Map<String, dynamic> json) {
    return MatchSummaryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      mapName: json['mapName'] as String?,
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  MatchSummary toEntity() {
    return MatchSummary(
      id: id,
      title: title,
      mapName: mapName,
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
    );
  }
}



