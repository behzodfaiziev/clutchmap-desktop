import '../../../../core/network/api_client.dart';

class BenchmarkRemoteDataSource {
  final ApiClient api;

  BenchmarkRemoteDataSource(this.api);

  Future<Map<String, dynamic>> getTeamIntelligence(String teamId) async {
    final response = await api.get("/teams/$teamId/intelligence");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }

  Future<Map<String, dynamic>> getBenchmark(String teamId) async {
    final response = await api.get("/teams/$teamId/benchmark");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }

  Future<Map<String, dynamic>> getMetaAlignment(String teamId) async {
    final response = await api.get("/teams/$teamId/meta-alignment");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }

  Future<Map<String, dynamic>> getMetaTrends({int window = 30}) async {
    final response = await api.get("/meta/trends?window=$window");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }

  Future<List<Map<String, dynamic>>> getTeamSnapshots(String teamId, {int window = 30}) async {
    final response = await api.get("/teams/$teamId/evolution");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    final history = responseData['history'] as List<dynamic>? ?? [];

    // Backend TeamEvolutionView.SnapshotHistoryView has date + overallScore only.
    // Map to TeamSnapshot shape (date, aggression, structure, variety, risk).
    final out = <Map<String, dynamic>>[];
    for (final item in history) {
      final map = item as Map<String, dynamic>;
      final date = map['date'] as String? ?? map['snapshotDate'] as String?;
      if (date == null || date.isEmpty) continue;
      final overall = (map['overallScore'] as num?)?.toInt() ?? 0;
      out.add({
        'date': date,
        'aggression': overall,
        'structure': overall,
        'variety': overall,
        'risk': overall,
      });
    }
    return out;
  }
}

