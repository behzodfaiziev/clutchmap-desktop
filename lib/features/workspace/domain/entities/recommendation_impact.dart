import 'package:equatable/equatable.dart';

class RecommendationImpact extends Equatable {
  final int beforeScore;
  final int afterScore;
  final int impactScore;
  final int riskChange;
  final int robustnessChange;

  const RecommendationImpact({
    required this.beforeScore,
    required this.afterScore,
    required this.impactScore,
    required this.riskChange,
    required this.robustnessChange,
  });

  factory RecommendationImpact.fromJson(Map<String, dynamic> json) {
    return RecommendationImpact(
      beforeScore: json['beforeScore'] as int? ?? 0,
      afterScore: json['afterScore'] as int? ?? 0,
      impactScore: json['impactScore'] as int? ?? 0,
      riskChange: json['riskChange'] as int? ?? 0,
      robustnessChange: json['robustnessChange'] as int? ?? 0,
    );
  }

  factory RecommendationImpact.fromMetrics(
    Map<String, dynamic> beforeMetrics,
    Map<String, dynamic> afterMetrics,
    int impactScore,
  ) {
    final beforeConfidence = beforeMetrics['confidence'] as int? ?? 0;
    final afterConfidence = afterMetrics['confidence'] as int? ?? 0;
    final beforeRisk = beforeMetrics['risk'] as int? ?? 0;
    final afterRisk = afterMetrics['risk'] as int? ?? 0;
    final beforeRobustness = beforeMetrics['robustness'] as int? ?? 0;
    final afterRobustness = afterMetrics['robustness'] as int? ?? 0;

    return RecommendationImpact(
      beforeScore: beforeConfidence,
      afterScore: afterConfidence,
      impactScore: impactScore,
      riskChange: afterRisk - beforeRisk,
      robustnessChange: afterRobustness - beforeRobustness,
    );
  }

  @override
  List<Object?> get props => [
        beforeScore,
        afterScore,
        impactScore,
        riskChange,
        robustnessChange,
      ];
}



