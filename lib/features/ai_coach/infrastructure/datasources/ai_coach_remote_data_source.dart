import '../../../../core/network/api_client.dart';
import '../../domain/entities/ai_coach_response.dart';
import '../../domain/entities/chat_message.dart';
import '../models/ai_coach_response_model.dart';

class AiCoachRemoteDataSource {
  final ApiClient api;

  AiCoachRemoteDataSource(this.api);

  Future<AiCoachResponse> askQuestion({
    required String matchId,
    required String question,
    required Map<String, dynamic> context,
    required List<ChatMessage> history,
  }) async {
    try {
      final response = await api.post(
        "/ai/coach",
        {
          "matchId": matchId,
          "question": question,
          "history": history.map((m) => {
            "role": m.fromUser ? "user" : "assistant",
            "content": m.text,
            "timestamp": m.timestamp.toIso8601String(),
          }).toList(),
          "context": context,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final responseData = data['data'] as Map<String, dynamic>? ?? data;
      return AiCoachResponseModel.fromJson(responseData).toEntity();
    } catch (e) {
      // If backend endpoint doesn't exist, return mock response
      return const AiCoachResponse(
        answer: "I'm currently in development. This is a mock response. The backend AI coach endpoint will be implemented soon.",
        suggestions: [],
        confidence: 50,
      );
    }
  }
}

