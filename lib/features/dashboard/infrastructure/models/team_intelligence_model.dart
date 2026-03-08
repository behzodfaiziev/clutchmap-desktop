import '../../domain/entities/team_intelligence.dart';

class TeamIntelligenceModel {
  final int aggression;
  final int structure;
  final int variety;
  final int overall;
  final String playstyle;

  TeamIntelligenceModel({
    required this.aggression,
    required this.structure,
    required this.variety,
    required this.overall,
    required this.playstyle,
  });

  factory TeamIntelligenceModel.fromJson(Map<String, dynamic> json) {
    // Handle ApiResponse wrapper
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return TeamIntelligenceModel(
      aggression: data['avgAggressionScore'] as int? ?? 0,
      structure: data['avgStructureScore'] as int? ?? 0,
      variety: data['avgVarietyScore'] as int? ?? 0,
      overall: data['overallScore'] as int? ?? 0,
      playstyle: data['playstyle'] as String? ?? 'Unknown',
    );
  }

  TeamIntelligence toEntity() {
    return TeamIntelligence(
      aggression: aggression,
      structure: structure,
      variety: variety,
      overall: overall,
      playstyle: playstyle,
    );
  }
}

