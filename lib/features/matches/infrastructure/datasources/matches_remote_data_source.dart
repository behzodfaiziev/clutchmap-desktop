import '../../../../core/network/api_client.dart';
import '../models/match_summary_model.dart';

class MatchesRemoteDataSource {
  final ApiClient api;

  MatchesRemoteDataSource(this.api);

  Future<List<MatchSummaryModel>> getMatches({
    int page = 0,
    int size = 20,
    String? filter,
    String? q,
    String? folderId,
    String? gameId,
    String? mapId,
    String? opponentId,
  }) async {
    String path = "/match-plans?page=$page&size=$size";
    if (filter != null) {
      final status = filter.toLowerCase() == 'archived' ? 'ARCHIVED' : 'ACTIVE';
      path += "&status=$status";
    }
    if (q != null && q.trim().isNotEmpty) {
      path += "&q=${Uri.encodeQueryComponent(q.trim())}";
    }
    if (folderId != null && folderId.trim().isNotEmpty) path += "&folderId=$folderId";
    if (gameId != null && gameId.trim().isNotEmpty) path += "&gameId=$gameId";
    if (mapId != null && mapId.trim().isNotEmpty) path += "&mapId=$mapId";
    if (opponentId != null && opponentId.trim().isNotEmpty) path += "&opponentId=$opponentId";
    final response = await api.get(path);
    final data = response.data as Map<String, dynamic>;
    // Handle ApiResponse wrapper
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    final items = responseData['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => MatchSummaryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<MatchSummaryModel> createMatch({
    required String title,
    String? gameId,
    String? mapId,
    String? folderId,
    String? opponentId,
    String? startingSide,
  }) async {
    final response = await api.post(
      "/match-plans",
      {
        "title": title,
        ...?gameId != null ? {"gameId": gameId} : null,
        ...?mapId != null ? {"mapId": mapId} : null,
        ...?folderId != null ? {"folderId": folderId} : null,
        ...?opponentId != null ? {"opponentId": opponentId} : null,
        ...?startingSide != null ? {"startingSide": startingSide} : null,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return MatchSummaryModel.fromJson(responseData);
  }

  Future<void> archiveMatch(String matchId) async {
    await api.post("/match-plans/$matchId/archive", null);
  }

  Future<void> unarchiveMatch(String matchId) async {
    await api.post("/match-plans/$matchId/unarchive", null);
  }

  Future<void> deleteMatch(String matchId) async {
    await api.delete("/match-plans/$matchId");
  }

  /// Duplicates a match plan. Backend: POST /match-plans/{matchPlanId}/duplicate.
  /// Returns the new match summary (navigate to /match/{newId}).
  Future<MatchSummaryModel> duplicateMatch(String matchId) async {
    final response = await api.post("/match-plans/$matchId/duplicate", null);
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return MatchSummaryModel.fromJson(responseData);
  }
}

