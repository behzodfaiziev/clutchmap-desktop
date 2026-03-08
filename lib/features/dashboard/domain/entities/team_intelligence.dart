import 'package:equatable/equatable.dart';

class TeamIntelligence extends Equatable {
  final int aggression;
  final int structure;
  final int variety;
  final int overall;
  final String playstyle;

  const TeamIntelligence({
    required this.aggression,
    required this.structure,
    required this.variety,
    required this.overall,
    required this.playstyle,
  });

  @override
  List<Object?> get props =>
    [aggression, structure, variety, overall, playstyle];
}



