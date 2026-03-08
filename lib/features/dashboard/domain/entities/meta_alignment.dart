import 'package:equatable/equatable.dart';

class MetaAlignment extends Equatable {
  final int alignmentScore;
  final int aggressionGap;
  final int structureGap;
  final int varietyGap;
  final int riskGap;

  const MetaAlignment({
    required this.alignmentScore,
    required this.aggressionGap,
    required this.structureGap,
    required this.varietyGap,
    required this.riskGap,
  });

  @override
  List<Object?> get props =>
    [alignmentScore, aggressionGap, structureGap, varietyGap, riskGap];
}



