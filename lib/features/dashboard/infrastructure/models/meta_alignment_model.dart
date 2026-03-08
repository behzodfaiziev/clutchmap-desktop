import '../../domain/entities/meta_alignment.dart';

class MetaAlignmentModel {
  final int alignmentScore;
  final int aggressionGap;
  final int structureGap;
  final int varietyGap;
  final int riskGap;

  MetaAlignmentModel({
    required this.alignmentScore,
    required this.aggressionGap,
    required this.structureGap,
    required this.varietyGap,
    required this.riskGap,
  });

  factory MetaAlignmentModel.fromJson(Map<String, dynamic> json) {
    // Handle ApiResponse wrapper
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final gaps = data['gaps'] as Map<String, dynamic>? ?? {};
    return MetaAlignmentModel(
      alignmentScore: data['alignmentScore'] as int? ?? 0,
      aggressionGap: gaps['aggressionGap'] as int? ?? 0,
      structureGap: gaps['structureGap'] as int? ?? 0,
      varietyGap: gaps['varietyGap'] as int? ?? 0,
      riskGap: gaps['riskGap'] as int? ?? 0,
    );
  }

  MetaAlignment toEntity() {
    return MetaAlignment(
      alignmentScore: alignmentScore,
      aggressionGap: aggressionGap,
      structureGap: structureGap,
      varietyGap: varietyGap,
      riskGap: riskGap,
    );
  }
}

