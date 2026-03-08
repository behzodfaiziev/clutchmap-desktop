import '../../../../core/network/api_client.dart';

class SystemRemoteDataSource {
  final ApiClient api;

  SystemRemoteDataSource(this.api);

  Future<Map<String, dynamic>> getCapabilities() async {
    final response = await api.get("/system/capabilities");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }
}



