import 'package:equatable/equatable.dart';

class MatchRobustness extends Equatable {
  final int robustness;

  const MatchRobustness({
    required this.robustness,
  });

  factory MatchRobustness.fromJson(Map<String, dynamic> json) {
    return MatchRobustness(
      robustness: json['robustnessScore'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [robustness];
}



