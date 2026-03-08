import 'package:equatable/equatable.dart';

class MetaAlignment extends Equatable {
  final int alignmentScore;
  final int aggressionGap;
  final int structureGap;
  final int varietyGap;
  final int riskGap;
  final String explanation;

  const MetaAlignment({
    required this.alignmentScore,
    required this.aggressionGap,
    required this.structureGap,
    required this.varietyGap,
    required this.riskGap,
    required this.explanation,
  });

  factory MetaAlignment.fromJson(Map<String, dynamic> json) {
    final gaps = json['gaps'] as Map<String, dynamic>? ?? {};
    return MetaAlignment(
      alignmentScore: json['alignmentScore'] as int? ?? 0,
      aggressionGap: gaps['aggressionGap'] as int? ?? 0,
      structureGap: gaps['structureGap'] as int? ?? 0,
      varietyGap: gaps['varietyGap'] as int? ?? 0,
      riskGap: gaps['riskGap'] as int? ?? 0,
      explanation: json['interpretation'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
        alignmentScore,
        aggressionGap,
        structureGap,
        varietyGap,
        riskGap,
        explanation,
      ];
}



