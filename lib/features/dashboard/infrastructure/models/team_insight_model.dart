import '../../domain/entities/team_insight.dart';

class TeamInsightModel {
  final String id;
  final String category;
  final int severity;
  final String headline;
  final String description;
  final String status;
  final DateTime createdAt;

  TeamInsightModel({
    required this.id,
    required this.category,
    required this.severity,
    required this.headline,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory TeamInsightModel.fromJson(Map<String, dynamic> json) {
    return TeamInsightModel(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      severity: (json['severity'] as num?)?.toInt() ?? 0,
      headline: json['headline'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  TeamInsight toEntity() => TeamInsight(
        id: id,
        category: category,
        severity: severity,
        headline: headline,
        description: description,
        status: status,
        createdAt: createdAt,
      );
}
