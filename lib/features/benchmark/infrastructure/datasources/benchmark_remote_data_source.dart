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
    // For now, we'll use the evolution endpoint and extract snapshots
    // In a real implementation, there would be a dedicated snapshots endpoint
    final response = await api.get("/teams/$teamId/evolution");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    final history = responseData['history'] as List<dynamic>? ?? [];
    
    // Convert evolution history to snapshot format
    // We'll need to get full snapshot data from the evolution endpoint
    // For now, return empty list - will be populated when backend adds snapshots endpoint
    return [];
  }
}

