import '../../../../core/network/api_client.dart';

class ShareRemoteDataSource {
  final ApiClient api;

  ShareRemoteDataSource(this.api);

  Future<Map<String, dynamic>> createShare(String matchId, {int? expiresInDays}) async {
    final response = await api.post(
      "/match-plans/$matchId/share",
      {
        if (expiresInDays != null) "expiresInDays": expiresInDays,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }

  Future<Map<String, dynamic>> getPublicMatch(String token) async {
    final response = await api.getPublic("/public/v1/match/$token");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }
}


