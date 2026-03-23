import 'package:dio/dio.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/team/active_team_service.dart';
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
    final teamId = getIt<ActiveTeamService>().activeTeamId;
    if (teamId == null || teamId.isEmpty) {
      return _mockResponse();
    }
    final gameType = context['gameType'] as String? ?? 'VALORANT';
    try {
      final response = await api.post(
        "/ai/coach",
        {
          "teamId": teamId,
          "gameType": gameType,
          "scope": "MATCH_PLAN",
          "scopeId": matchId,
          "question": question,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final responseData = data['data'] as Map<String, dynamic>? ?? data;
      return _mapBackendResponse(responseData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _mockResponse();
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  AiCoachResponse _mapBackendResponse(Map<String, dynamic> json) {
    final headline = json['headline'] as String? ?? '';
    final bullets = json['bullets'] as List<dynamic>? ?? [];
    final confidenceDouble = (json['confidence'] as num?)?.toDouble() ?? 0.0;
    final confidence = (confidenceDouble.clamp(0.0, 1.0) * 100).round();
    final citationsList = json['citations'] as List<dynamic>? ?? [];
    final citations = citationsList.map((e) => e.toString()).toList();
    final suggestions = bullets
        .map((b) => RoundSuggestionModel(roundNumber: 0, recommendation: b.toString()))
        .toList();
    return AiCoachResponse(
      answer: headline,
      suggestions: suggestions.map((s) => s.toEntity()).toList(),
      confidence: confidence,
      citations: citations,
    );
  }

  AiCoachResponse _mockResponse() {
    return const AiCoachResponse(
      answer: "I'm currently in development. This is a mock response. The backend AI coach endpoint will be implemented soon.",
      suggestions: [],
      confidence: 50,
    );
  }

  /// Vector retrieval search over team knowledge (round notes, reports). Returns evidence snippets.
  Future<RetrievalSearchResult> retrievalSearch({
    required String teamId,
    required String gameType,
    required String query,
    int limit = 8,
  }) async {
    final response = await api.post(
      "/ai/retrieval/search",
      {
        "teamId": teamId,
        "gameType": gameType,
        "query": query,
        "limit": limit,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    final evidenceList = responseData['evidence'] as List<dynamic>? ?? [];
    final evidence = evidenceList
        .map((e) => RetrievalEvidenceItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return RetrievalSearchResult(evidence: evidence);
  }

  /// Ingest match round notes into the vector store for retrieval.
  Future<IngestMatchResult> ingestMatch({
    required String matchId,
    required String teamId,
    required String gameType,
  }) async {
    final response = await api.post(
      "/ai/retrieval/ingest-match",
      {
        "matchId": matchId,
        "teamId": teamId,
        "gameType": gameType,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    final saved = (responseData['chunksSaved'] as num?)?.toInt() ?? 0;
    return IngestMatchResult(chunksSaved: saved);
  }
}

class RetrievalSearchResult {
  final List<RetrievalEvidenceItem> evidence;

  RetrievalSearchResult({required this.evidence});
}

class RetrievalEvidenceItem {
  final String id;
  final String evidenceId;
  final String text;
  final String metadata;
  final double similarity;

  RetrievalEvidenceItem({
    required this.id,
    required this.evidenceId,
    required this.text,
    required this.metadata,
    required this.similarity,
  });

  static RetrievalEvidenceItem fromJson(Map<String, dynamic> json) {
    return RetrievalEvidenceItem(
      id: (json['id'] as String?) ?? '',
      evidenceId: (json['evidenceId'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
      metadata: (json['metadata'] as String?) ?? '{}',
      similarity: (json['similarity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class IngestMatchResult {
  final int chunksSaved;

  IngestMatchResult({required this.chunksSaved});
}

