import 'package:clutchmap_desktop/core/storage/token_storage.dart';

/// In-memory [TokenStorage] for unit tests.
///
/// Does not use FlutterSecureStorage, so tests run without platform bindings.
/// Use when testing [AuthRepositoryImpl] or any code that depends on [TokenStorage].
///
/// Example:
/// ```dart
/// final tokenStorage = InMemoryTokenStorage();
/// final repository = AuthRepositoryImpl(
///   remoteDataSource: mockDataSource,
///   tokenStorage: tokenStorage,
/// );
/// ```
class InMemoryTokenStorage extends TokenStorage {
  String? _token;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<String?> getToken() async {
    return _token;
  }

  @override
  Future<void> clear() async {
    _token = null;
  }
}
