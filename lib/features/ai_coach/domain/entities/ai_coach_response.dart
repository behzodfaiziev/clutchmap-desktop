import 'package:equatable/equatable.dart';
import 'round_suggestion.dart';

class AiCoachResponse extends Equatable {
  final String answer;
  final List<RoundSuggestion> suggestions;
  final int confidence;

  const AiCoachResponse({
    required this.answer,
    required this.suggestions,
    required this.confidence,
  });

  @override
  List<Object?> get props => [answer, suggestions, confidence];
}


