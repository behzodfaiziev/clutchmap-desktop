import 'package:equatable/equatable.dart';
import 'strategy_template.dart';

class TemplateDetail extends Equatable {
  final StrategyTemplate template;
  final int roundsCount;
  final int? aggressionScore;
  final int? structureScore;

  const TemplateDetail({
    required this.template,
    required this.roundsCount,
    this.aggressionScore,
    this.structureScore,
  });

  @override
  List<Object?> get props => [template, roundsCount, aggressionScore, structureScore];
}


