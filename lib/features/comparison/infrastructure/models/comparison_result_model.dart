import '../../domain/entities/comparison_result.dart';

class ComparisonResultModel {
  final int overallDelta;
  final int aggressionDelta;
  final int structureDelta;
  final int varietyDelta;
  final int riskDelta;
  final List<RoundDiffModel> roundDiffs;

  ComparisonResultModel({
    required this.overallDelta,
    required this.aggressionDelta,
    required this.structureDelta,
    required this.varietyDelta,
    required this.riskDelta,
    required this.roundDiffs,
  });

  factory ComparisonResultModel.fromJson(Map<String, dynamic> json) {
    return ComparisonResultModel(
      overallDelta: json['overallDelta'] as int? ?? 0,
      aggressionDelta: json['aggressionDelta'] as int? ?? 0,
      structureDelta: json['structureDelta'] as int? ?? 0,
      varietyDelta: json['varietyDelta'] as int? ?? 0,
      riskDelta: json['riskDelta'] as int? ?? 0,
      roundDiffs: (json['roundDiffs'] as List<dynamic>?)
              ?.map((item) => RoundDiffModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  ComparisonResult toEntity() {
    return ComparisonResult(
      overallDelta: overallDelta,
      aggressionDelta: aggressionDelta,
      structureDelta: structureDelta,
      varietyDelta: varietyDelta,
      riskDelta: riskDelta,
      roundDiffs: roundDiffs.map((d) => d.toEntity()).toList(),
    );
  }
}

class RoundDiffModel {
  final int roundNumber;
  final bool notesChanged;
  final bool buyChanged;
  final List<String> eventsAdded;
  final List<String> eventsRemoved;

  RoundDiffModel({
    required this.roundNumber,
    required this.notesChanged,
    required this.buyChanged,
    required this.eventsAdded,
    required this.eventsRemoved,
  });

  factory RoundDiffModel.fromJson(Map<String, dynamic> json) {
    return RoundDiffModel(
      roundNumber: json['roundNumber'] as int? ?? 0,
      notesChanged: json['notesChanged'] as bool? ?? false,
      buyChanged: json['buyChanged'] as bool? ?? false,
      eventsAdded: (json['eventsAdded'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      eventsRemoved: (json['eventsRemoved'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  RoundDiff toEntity() {
    return RoundDiff(
      roundNumber: roundNumber,
      notesChanged: notesChanged,
      buyChanged: buyChanged,
      eventsAdded: eventsAdded,
      eventsRemoved: eventsRemoved,
    );
  }
}

