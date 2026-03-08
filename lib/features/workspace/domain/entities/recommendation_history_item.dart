import 'package:equatable/equatable.dart';

class RecommendationHistoryItem extends Equatable {
  final String id;
  final bool applied;
  final DateTime createdAt;
  final int projectedAdvantage;
  final String? mode;
  final String? kind;

  const RecommendationHistoryItem({
    required this.id,
    required this.applied,
    required this.createdAt,
    required this.projectedAdvantage,
    this.mode,
    this.kind,
  });

  factory RecommendationHistoryItem.fromJson(Map<String, dynamic> json) {
    final feedback = json['feedback'] as Map<String, dynamic>? ?? {};
    return RecommendationHistoryItem(
      id: json['id'] as String,
      applied: feedback['applied'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      projectedAdvantage: _parseAdvantageToInt(json['targetAdvantage'] as String? ?? 'EVEN_MATCH'),
      mode: json['mode'] as String?,
      kind: json['kind'] as String?,
    );
  }

  static int _parseAdvantageToInt(String advantage) {
    switch (advantage) {
      case 'CONTROL_ADVANTAGE':
        return 80;
      case 'PACE_ADVANTAGE':
        return 70;
      case 'EVEN_MATCH':
        return 50;
      case 'UNCERTAIN':
        return 30;
      default:
        return 50;
    }
  }

  @override
  List<Object?> get props => [id, applied, createdAt, projectedAdvantage, mode, kind];
}



