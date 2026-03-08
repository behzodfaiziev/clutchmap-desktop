import 'package:equatable/equatable.dart';

class MatchupAnalysis extends Equatable {
  final String predictedAdvantage;
  final int teamAdvantageScore;
  final int opponentAdvantageScore;
  final int aggressionGap;
  final int structureGap;
  final int varietyGap;

  const MatchupAnalysis({
    required this.predictedAdvantage,
    required this.teamAdvantageScore,
    required this.opponentAdvantageScore,
    required this.aggressionGap,
    required this.structureGap,
    required this.varietyGap,
  });

  factory MatchupAnalysis.fromJson(Map<String, dynamic> json) {
    return MatchupAnalysis(
      predictedAdvantage: json['predictedAdvantage'] as String? ?? 'EVEN_MATCH',
      teamAdvantageScore: json['teamAdvantageScore'] as int? ?? 0,
      opponentAdvantageScore: json['opponentAdvantageScore'] as int? ?? 0,
      aggressionGap: json['aggressionGap'] as int? ?? 0,
      structureGap: json['structureGap'] as int? ?? 0,
      varietyGap: json['varietyGap'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        predictedAdvantage,
        teamAdvantageScore,
        opponentAdvantageScore,
        aggressionGap,
        structureGap,
        varietyGap,
      ];
}



