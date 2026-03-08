import 'package:equatable/equatable.dart';

class AdvisorPerformance extends Equatable {
  final int appliedCount;
  final double averageImpact;
  final double positiveImpactRate;

  const AdvisorPerformance({
    required this.appliedCount,
    required this.averageImpact,
    required this.positiveImpactRate,
  });

  factory AdvisorPerformance.fromJson(Map<String, dynamic> json) {
    final positiveRate = json['positiveImpactRate'] as num?;
    return AdvisorPerformance(
      appliedCount: json['totalApplied'] as int? ?? 0,
      averageImpact: (json['averageImpactScore'] as num?)?.toDouble() ?? 0.0,
      positiveImpactRate: positiveRate != null ? positiveRate.toDouble() / 100.0 : 0.0,
    );
  }

  @override
  List<Object?> get props => [appliedCount, averageImpact, positiveImpactRate];
}

