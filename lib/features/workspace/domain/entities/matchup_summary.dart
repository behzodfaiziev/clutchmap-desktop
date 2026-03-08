import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MatchupSummary extends Equatable {
  final String predictedAdvantage; // CONTROL_ADVANTAGE / EVEN_MATCH / ...
  final int confidence;

  const MatchupSummary({
    required this.predictedAdvantage,
    required this.confidence,
  });

  factory MatchupSummary.fromJson(Map<String, dynamic> json) {
    return MatchupSummary(
      predictedAdvantage: json['predictedAdvantage'] as String? ?? 'UNCERTAIN',
      confidence: json['confidence'] as int? ?? 0,
    );
  }

  Color get advantageColor {
    switch (predictedAdvantage) {
      case 'CONTROL_ADVANTAGE':
        return Colors.green;
      case 'EVEN_MATCH':
        return Colors.grey;
      case 'PACE_ADVANTAGE':
        return Colors.blue;
      case 'UNCERTAIN':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  List<Object?> get props => [predictedAdvantage, confidence];
}

