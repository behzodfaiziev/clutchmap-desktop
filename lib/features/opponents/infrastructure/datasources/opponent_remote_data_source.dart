import '../../../../core/network/api_client.dart';

class OpponentRemoteDataSource {
  final ApiClient api;

  OpponentRemoteDataSource(this.api);

  /// POST /opponents — create opponent for the active team (X-Team-Id).
  Future<Map<String, dynamic>> createOpponent({
    required String name,
    String? region,
    String? notes,
    List<String>? tags,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      if (region != null && region.isNotEmpty) 'region': region,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (tags != null && tags.isNotEmpty) 'tags': tags,
    };
    final response = await api.post("/opponents", body);
    final data = response.data as Map<String, dynamic>;
    final inner = data['data'] as Map<String, dynamic>? ?? data;
    return inner;
  }

  /// PUT /opponents/{opponentId} — update opponent (X-Team-Id).
  Future<Map<String, dynamic>> updateOpponent(
    String opponentId, {
    required String name,
    String? region,
    String? notes,
    List<String>? tags,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      if (region != null && region.isNotEmpty) 'region': region,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (tags != null && tags.isNotEmpty) 'tags': tags,
    };
    final response = await api.put("/opponents/$opponentId", body);
    final data = response.data as Map<String, dynamic>;
    final inner = data['data'] as Map<String, dynamic>? ?? data;
    return inner;
  }

  /// DELETE /opponents/{opponentId} — requires X-Team-Id. Fails if matches are linked.
  Future<void> deleteOpponent(String opponentId) async {
    await api.delete("/opponents/$opponentId");
  }

  Future<List<Map<String, dynamic>>> getOpponents() async {
    final response = await api.get("/opponents");
    final data = response.data as Map<String, dynamic>;
    final inner = data['data'];
    final List<dynamic> items = inner is List
        ? inner
        : (inner is Map && inner['items'] != null)
            ? (inner['items'] as List<dynamic>)
            : (data['items'] as List<dynamic>? ?? []);
    return items.map((item) => item as Map<String, dynamic>).toList();
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



