import 'package:equatable/equatable.dart';

class RoundIntelligence extends Equatable {
  final int aggression;
  final int structure;
  final int risk;
  final int volatility;
  final int economyRisk;

  const RoundIntelligence({
    required this.aggression,
    required this.structure,
    required this.risk,
    required this.volatility,
    required this.economyRisk,
  });

  factory RoundIntelligence.fromJson(Map<String, dynamic> json) {
    return RoundIntelligence(
      aggression: json['aggressionScore'] as int? ?? 0,
      structure: json['structureScore'] as int? ?? 0,
      risk: json['riskScore'] as int? ?? 0,
      volatility: json['volatilityIndex'] as int? ?? 0,
      economyRisk: json['economyRisk'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [aggression, structure, risk, volatility, economyRisk];
}



