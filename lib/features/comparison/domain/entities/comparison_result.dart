import 'package:equatable/equatable.dart';

class ComparisonResult extends Equatable {
  final int overallDelta;
  final int aggressionDelta;
  final int structureDelta;
  final int varietyDelta;
  final int riskDelta;
  final List<RoundDiff> roundDiffs;

  const ComparisonResult({
    required this.overallDelta,
    required this.aggressionDelta,
    required this.structureDelta,
    required this.varietyDelta,
    required this.riskDelta,
    required this.roundDiffs,
  });

  @override
  List<Object?> get props => [
        overallDelta,
        aggressionDelta,
        structureDelta,
        varietyDelta,
        riskDelta,
        roundDiffs,
      ];
}

class RoundDiff extends Equatable {
  final int roundNumber;
  final bool notesChanged;
  final bool buyChanged;
  final List<String> eventsAdded;
  final List<String> eventsRemoved;

  const RoundDiff({
    required this.roundNumber,
    required this.notesChanged,
    required this.buyChanged,
    required this.eventsAdded,
    required this.eventsRemoved,
  });

  @override
  List<Object?> get props => [
        roundNumber,
        notesChanged,
        buyChanged,
        eventsAdded,
        eventsRemoved,
      ];
}


