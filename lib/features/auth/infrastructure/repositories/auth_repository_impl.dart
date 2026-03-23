import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response_model.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/team/active_team_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;
  final ActiveTeamService? activeTeamService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
    this.activeTeamService,
  });

  @override
  Future<AuthUser> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);
    final authResponse = AuthResponseModel.fromJson(response);
    
    await tokenStorage.saveToken(authResponse.token);
    
    // Use the user data from the auth response
    return authResponse.toEntity();
  }

  @override
  Future<void> logout() async {
    await tokenStorage.clear();
    activeTeamService?.clear();
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

