import '../../../../core/network/api_client.dart';

class SearchRemoteDataSource {
  final ApiClient api;

  SearchRemoteDataSource(this.api);

  Future<List<Map<String, dynamic>>> search(String query, {int page = 0, int size = 20}) async {
    final response = await api.get("/search?q=$query&page=$page&size=$size");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    final items = responseData['items'] as List<dynamic>? ?? [];
    return items.map((item) => item as Map<String, dynamic>).toList();
  }
}



