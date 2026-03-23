import 'package:equatable/equatable.dart';

class OpponentProfile extends Equatable {
  final String id;
  final String name;
  final int aggression;
  final int structure;
  final int variety;
  final int risk;
  final String? region;
  final String? notes;

  const OpponentProfile({
    required this.id,
    required this.name,
    required this.aggression,
    required this.structure,
    required this.variety,
    required this.risk,
    this.region,
    this.notes,
  });

  factory OpponentProfile.fromJson(Map<String, dynamic> json) {
    return OpponentProfile(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      aggression: json['aggression'] as int? ?? json['avgAggressionScore'] as int? ?? 0,
      structure: json['structure'] as int? ?? json['avgStructureScore'] as int? ?? 0,
      variety: json['variety'] as int? ?? json['avgVarietyScore'] as int? ?? 0,
      risk: json['risk'] as int? ?? 0,
      region: json['region'] as String?,
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, aggression, structure, variety, risk, region, notes];
}



