import '../../../../core/network/api_client.dart';

class TemplateRemoteDataSource {
  final ApiClient api;

  TemplateRemoteDataSource(this.api);

  Future<List<Map<String, dynamic>>> getTemplates({
    int page = 0,
    int size = 20,
  }) async {
    final response = await api.get(
      "/templates?page=$page&size=$size",
    );
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    final items = responseData['items'] as List<dynamic>? ?? [];
    return items.map((item) => item as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> getTemplate(String templateId) async {
    final response = await api.get("/templates/$templateId");
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>? ?? data;
  }

  Future<Map<String, dynamic>> createTemplateFromMatch(
    String templateName,
    String matchId, {
    String? category,
    List<String>? tags,
  }) async {
    final response = await api.post(
      "/match-plans/$matchId/template",
      {
        "description": templateName,
        if (category != null) "category": category,
        if (tags != null) "tags": tags,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>? ?? data;
  }

  Future<Map<String, dynamic>> applyTemplate(
    String templateId,
    String title,
    String? folderId,
  ) async {
    final response = await api.post(
      "/templates/$templateId/create-match",
      {
        "title": title,
        if (folderId != null) "folderId": folderId,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>? ?? data;
  }
}

