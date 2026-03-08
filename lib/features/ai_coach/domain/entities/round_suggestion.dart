import 'package:equatable/equatable.dart';

class RoundSuggestion extends Equatable {
  final int roundNumber;
  final String recommendation;

  const RoundSuggestion({
    required this.roundNumber,
    required this.recommendation,
  });

  @override
  List<Object?> get props => [roundNumber, recommendation];
}


