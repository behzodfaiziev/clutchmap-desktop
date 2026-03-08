import 'package:equatable/equatable.dart';

class MetaTrendPoint extends Equatable {
  final DateTime date;
  final int aggression;
  final int risk;

  const MetaTrendPoint({
    required this.date,
    required this.aggression,
    required this.risk,
  });

  factory MetaTrendPoint.fromJson(Map<String, dynamic> json) {
    return MetaTrendPoint(
      date: DateTime.parse(json['date'] as String),
      aggression: (json['avgAggression'] as num?)?.toInt() ?? 0,
      risk: (json['avgRisk'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [date, aggression, risk];
}



