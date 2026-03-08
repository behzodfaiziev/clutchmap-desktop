import '../../domain/entities/match_detail.dart';

class MatchDetailModel {
  final String id;
  final String title;
  final String? mapName;
  final bool archived;

  MatchDetailModel({
    required this.id,
    required this.title,
    this.mapName,
    required this.archived,
  });

  factory MatchDetailModel.fromJson(Map<String, dynamic> json) {
    return MatchDetailModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      mapName: json['mapName'] as String?,
      archived: json['archived'] as bool? ?? false,
    );
  }

  MatchDetail toEntity() {
    return MatchDetail(
      id: id,
      title: title,
      mapName: mapName,
      archived: archived,
    );
  }
}



