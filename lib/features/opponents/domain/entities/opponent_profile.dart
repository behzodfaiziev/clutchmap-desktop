import 'package:equatable/equatable.dart';

class OpponentProfile extends Equatable {
  final String id;
  final String name;
  final int aggression;
  final int structure;
  final int variety;
  final int risk;

  const OpponentProfile({
    required this.id,
    required this.name,
    required this.aggression,
    required this.structure,
    required this.variety,
    required this.risk,
  });

  factory OpponentProfile.fromJson(Map<String, dynamic> json) {
    // Opponent profile might come from tactical profile endpoint
    // For now, we'll extract from matchup data or opponent view
    return OpponentProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      aggression: json['aggression'] as int? ?? json['avgAggressionScore'] as int? ?? 0,
      structure: json['structure'] as int? ?? json['avgStructureScore'] as int? ?? 0,
      variety: json['variety'] as int? ?? json['avgVarietyScore'] as int? ?? 0,
      risk: json['risk'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, aggression, structure, variety, risk];
}



