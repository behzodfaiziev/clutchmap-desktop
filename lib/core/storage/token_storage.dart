import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: "auth_token", value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: "auth_token");
  }

  Future<void> clear() async {
    await _storage.delete(key: "auth_token");
  }
}



