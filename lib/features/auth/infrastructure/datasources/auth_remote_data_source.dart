import '../../../../core/network/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient api;

  AuthRemoteDataSource(this.api);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await api.post(
      "/auth/login",
      {
        "email": email,
        "password": password,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await api.get("/auth/me");
    return response.data as Map<String, dynamic>;
  }
}

