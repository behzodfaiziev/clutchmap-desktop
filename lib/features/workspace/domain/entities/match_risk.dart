import 'package:equatable/equatable.dart';

class MatchRisk extends Equatable {
  final int risk;
  final int volatility;

  const MatchRisk({
    required this.risk,
    required this.volatility,
  });

  factory MatchRisk.fromJson(Map<String, dynamic> json) {
    return MatchRisk(
      risk: json['riskScore'] as int? ?? 0,
      volatility: json['volatilityIndex'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [risk, volatility];
}



