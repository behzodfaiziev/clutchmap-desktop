import 'package:equatable/equatable.dart';

class Recommendation extends Equatable {
  final String id;
  final int deltaAggression;
  final int deltaStructure;
  final int deltaVariety;
  final int projectedAdvantage;
  final int riskImpact;
  final int robustnessImpact;
  final int? confidence;
  final int? riskScore;
  final int? robustnessScore;
  final int? adjustmentCost;

  const Recommendation({
    required this.id,
    required this.deltaAggression,
    required this.deltaStructure,
    required this.deltaVariety,
    required this.projectedAdvantage,
    required this.riskImpact,
    required this.robustnessImpact,
    this.confidence,
    this.riskScore,
    this.robustnessScore,
    this.adjustmentCost,
  });

  factory Recommendation.fromOptimizedSolution(Map<String, dynamic> json, int rank) {
    final adjustments = json['adjustments'] as Map<String, dynamic>? ?? {};
    final comparison = json['comparison'] as Map<String, dynamic>? ?? {};
    
    return Recommendation(
      id: json['recommendationId'] as String? ?? 'temp_$rank',
      deltaAggression: adjustments['aggressionDelta'] as int? ?? 0,
      deltaStructure: adjustments['structureDelta'] as int? ?? 0,
      deltaVariety: adjustments['varietyDelta'] as int? ?? 0,
      projectedAdvantage: _parseAdvantageToInt(json['predictedAdvantage'] as String? ?? 'EVEN_MATCH'),
      riskImpact: comparison['riskReduction'] as int? ?? 0,
      robustnessImpact: json['robustnessScore'] as int? ?? 0,
      confidence: json['confidence'] as int?,
      riskScore: json['riskScore'] as int?,
      robustnessScore: json['robustnessScore'] as int?,
      adjustmentCost: json['adjustmentCost'] as int?,
    );
  }

  static int _parseAdvantageToInt(String advantage) {
    switch (advantage) {
      case 'CONTROL_ADVANTAGE':
        return 80;
      case 'PACE_ADVANTAGE':
        return 70;
      case 'EVEN_MATCH':
        return 50;
      case 'UNCERTAIN':
        return 30;
      default:
        return 50;
    }
  }

  @override
  List<Object?> get props => [
        id,
        deltaAggression,
        deltaStructure,
        deltaVariety,
        projectedAdvantage,
        riskImpact,
        robustnessImpact,
        confidence,
        riskScore,
        robustnessScore,
        adjustmentCost,
      ];
}



