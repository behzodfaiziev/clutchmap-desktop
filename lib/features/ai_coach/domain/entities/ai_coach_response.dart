import 'package:equatable/equatable.dart';
import 'round_suggestion.dart';

class AiCoachResponse extends Equatable {
  final String answer;
  final List<RoundSuggestion> suggestions;
  final int confidence;
  /// Evidence IDs cited by the AI (e.g. E1, E2) for grounding.
  final List<String> citations;

  const AiCoachResponse({
    required this.answer,
    required this.suggestions,
    required this.confidence,
    this.citations = const [],
  });

  @override
  List<Object?> get props => [answer, suggestions, confidence, citations];
}


