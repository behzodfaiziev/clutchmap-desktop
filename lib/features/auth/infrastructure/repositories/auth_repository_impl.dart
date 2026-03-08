import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response_model.dart';
import '../../../../core/storage/token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<AuthUser> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);
    final authResponse = AuthResponseModel.fromJson(response);
    
    await tokenStorage.saveToken(authResponse.token);
    
    // For now, return a user with email from login
    // In production, decode JWT to get user ID and other info
    return AuthUser(
      id: 'temp-id', // Will be replaced with JWT decoding
      email: email,
    );
  }

  @override
  Future<void> logout() async {
    await tokenStorage.clear();
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final token = await tokenStorage.getToken();
    if (token == null) return null;

    try {
      final userData = await remoteDataSource.getCurrentUser();
      return AuthUser(
        id: userData['id'] as String? ?? '',
        email: userData['email'] as String? ?? '',
        displayName: userData['displayName'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthUser?> validateToken() async {
    final token = await tokenStorage.getToken();
    if (token == null) return null;

    try {
      return await getCurrentUser();
    } catch (e) {
      await tokenStorage.clear();
      return null;
    }
  }
}

