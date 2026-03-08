import 'package:equatable/equatable.dart';

class TeamSnapshot extends Equatable {
  final DateTime date;
  final int aggression;
  final int structure;
  final int variety;
  final int risk;

  const TeamSnapshot({
    required this.date,
    required this.aggression,
    required this.structure,
    required this.variety,
    required this.risk,
  });

  factory TeamSnapshot.fromJson(Map<String, dynamic> json) {
    return TeamSnapshot(
      date: DateTime.parse(json['date'] as String),
      aggression: json['aggression'] as int? ?? 0,
      structure: json['structure'] as int? ?? 0,
      variety: json['variety'] as int? ?? 0,
      risk: json['risk'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [date, aggression, structure, variety, risk];
}



