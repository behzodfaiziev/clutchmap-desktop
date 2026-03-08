import 'package:equatable/equatable.dart';

class MatchIntelligence extends Equatable {
  final int aggression;
  final int structure;
  final int variety;
  final int overall;

  const MatchIntelligence({
    required this.aggression,
    required this.structure,
    required this.variety,
    required this.overall,
  });

  factory MatchIntelligence.fromJson(Map<String, dynamic> json) {
    return MatchIntelligence(
      aggression: json['aggressionScore'] as int? ?? 0,
      structure: json['structureScore'] as int? ?? 0,
      variety: json['varietyScore'] as int? ?? 0,
      overall: json['overallScore'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [aggression, structure, variety, overall];
}



