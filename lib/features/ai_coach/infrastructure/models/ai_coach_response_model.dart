import '../../domain/entities/ai_coach_response.dart';
import '../../domain/entities/round_suggestion.dart';

class AiCoachResponseModel {
  final String answer;
  final List<RoundSuggestionModel> suggestions;
  final int confidence;

  AiCoachResponseModel({
    required this.answer,
    required this.suggestions,
    required this.confidence,
  });

  factory AiCoachResponseModel.fromJson(Map<String, dynamic> json) {
    return AiCoachResponseModel(
      answer: json['answer'] as String? ?? '',
      suggestions: (json['suggestedAdjustments'] as List<dynamic>?)
              ?.map((item) => RoundSuggestionModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      confidence: json['confidence'] as int? ?? 0,
    );
  }

  AiCoachResponse toEntity() {
    return AiCoachResponse(
      answer: answer,
      suggestions: suggestions.map((s) => s.toEntity()).toList(),
      confidence: confidence,
    );
  }
}

class RoundSuggestionModel {
  final int roundNumber;
  final String recommendation;

  RoundSuggestionModel({
    required this.roundNumber,
    required this.recommendation,
  });

  factory RoundSuggestionModel.fromJson(Map<String, dynamic> json) {
    return RoundSuggestionModel(
      roundNumber: json['roundNumber'] as int? ?? 0,
      recommendation: json['recommendation'] as String? ?? '',
    );
  }

  RoundSuggestion toEntity() {
    return RoundSuggestion(
      roundNumber: roundNumber,
      recommendation: recommendation,
    );
  }
}


