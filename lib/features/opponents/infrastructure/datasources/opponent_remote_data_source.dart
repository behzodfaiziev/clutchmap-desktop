import '../../../../core/network/api_client.dart';

class OpponentRemoteDataSource {
  final ApiClient api;

  OpponentRemoteDataSource(this.api);

  Future<List<Map<String, dynamic>>> getOpponents() async {
    final response = await api.get("/opponents");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as List<dynamic>? ?? data['items'] as List<dynamic>? ?? [];
    return responseData.map((item) => item as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> getOpponentProfile(String opponentId) async {
    // For now, we'll need to construct from matchup data
    // In production, there would be a dedicated endpoint
    return {};
  }

  Future<Map<String, dynamic>> getMatchup(String teamId, String opponentId) async {
    final response = await api.get("/teams/$teamId/matchup/$opponentId");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }

  Future<Map<String, dynamic>> getMapMatchup(
    String teamId,
    String opponentId,
    String mapId,
  ) async {
    final response = await api.get("/teams/$teamId/matchup/$opponentId/map/$mapId");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }

  Future<Map<String, dynamic>> getTeamIntelligence(String teamId) async {
    final response = await api.get("/teams/$teamId/intelligence");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }
}



