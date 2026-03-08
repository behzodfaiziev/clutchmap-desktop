import 'package:equatable/equatable.dart';

class BenchmarkData extends Equatable {
  final int aggression;
  final int structure;
  final int variety;
  final int risk;
  final int aggressionPercentile;
  final int structurePercentile;
  final int varietyPercentile;
  final int riskPercentile;

  const BenchmarkData({
    required this.aggression,
    required this.structure,
    required this.variety,
    required this.risk,
    required this.aggressionPercentile,
    required this.structurePercentile,
    required this.varietyPercentile,
    required this.riskPercentile,
  });

  factory BenchmarkData.fromJson(Map<String, dynamic> json) {
    final aggression = json['aggression'] as Map<String, dynamic>? ?? {};
    final structure = json['structure'] as Map<String, dynamic>? ?? {};
    final variety = json['variety'] as Map<String, dynamic>? ?? {};
    final risk = json['risk'] as Map<String, dynamic>? ?? {};

    return BenchmarkData(
      aggression: aggression['score'] as int? ?? 0,
      structure: structure['score'] as int? ?? 0,
      variety: variety['score'] as int? ?? 0,
      risk: risk['score'] as int? ?? 0,
      aggressionPercentile: aggression['percentile'] as int? ?? 0,
      structurePercentile: structure['percentile'] as int? ?? 0,
      varietyPercentile: variety['percentile'] as int? ?? 0,
      riskPercentile: risk['percentile'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        aggression,
        structure,
        variety,
        risk,
        aggressionPercentile,
        structurePercentile,
        varietyPercentile,
        riskPercentile,
      ];
}



