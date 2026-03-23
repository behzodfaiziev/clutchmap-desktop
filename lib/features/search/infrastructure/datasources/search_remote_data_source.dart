import '../../../../core/network/api_client.dart';

class SearchRemoteDataSource {
  final ApiClient api;

  SearchRemoteDataSource(this.api);

  /// GET search (match plans only). Used when no active team.
  Future<List<Map<String, dynamic>>> search(String query, {int page = 0, int size = 20}) async {
    final path = '/search?q=${Uri.encodeComponent(query)}&page=$page&size=$size';
    final response = await api.get(path);
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    final items = responseData['items'] as List<dynamic>? ?? [];
    return items.map((item) => item as Map<String, dynamic>).toList();
  }

  /// POST hybrid search (chunks: round notes, VOD tags, etc.). Requires teamId.
  Future<List<Map<String, dynamic>>> hybridSearch({
    required String teamId,
    required String gameType,
    required String query,
    String? mapCode,
    String? pattern,
    List<String>? scope,
  }) async {
    final body = <String, dynamic>{
      'teamId': teamId,
      'gameType': gameType,
      'query': query.trim().isEmpty ? ' ' : query.trim(),
    };
    if (mapCode != null || pattern != null || (scope != null && scope.isNotEmpty)) {
      body['filters'] = <String, dynamic>{
        if (mapCode != null) 'mapCode': mapCode,
        if (pattern != null) 'pattern': pattern,
        if (scope != null && scope.isNotEmpty) 'scope': scope,
      };
    }
    final response = await api.post('/search', body);
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    final results = responseData['results'] as List<dynamic>? ?? [];
    return results.map((r) => r as Map<String, dynamic>).toList();
  }
}



