import 'package:equatable/equatable.dart';

class MatchIntelligenceSummary extends Equatable {
  final int aggression;
  final int structure;
  final int variety;
  final int overall;
  final int risk;
  final int volatility;

  const MatchIntelligenceSummary({
    required this.aggression,
    required this.structure,
    required this.variety,
    required this.overall,
    required this.risk,
    required this.volatility,
  });

  @override
  List<Object?> get props => [
        aggression,
        structure,
        variety,
        overall,
        risk,
        volatility,
      ];
}


