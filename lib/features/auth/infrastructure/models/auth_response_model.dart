import '../../domain/entities/auth_user.dart';

class AuthResponseModel {
  final String token;
  final Map<String, dynamic> userData;

  AuthResponseModel({
    required this.token,
    required this.userData,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      userData: json['user'] as Map<String, dynamic>? ?? {},
    );
  }

  AuthUser toEntity() {
    return AuthUser(
      id: userData['id'] as String? ?? '',
      email: userData['email'] as String? ?? '',
      displayName: userData['displayName'] as String?,
    );
  }
}



