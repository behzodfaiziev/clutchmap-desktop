import '../../../../core/network/api_client.dart';
import '../models/match_summary_model.dart';

class MatchesRemoteDataSource {
  final ApiClient api;

  MatchesRemoteDataSource(this.api);

  Future<List<MatchSummaryModel>> getMatches({
    int page = 0,
    int size = 20,
    String? filter,
  }) async {
    String path = "/match-plans?page=$page&size=$size";
    if (filter != null) {
      path += "&filter=$filter";
    }
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
}

