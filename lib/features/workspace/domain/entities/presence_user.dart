import 'package:equatable/equatable.dart';

class PresenceUser extends Equatable {
  final String userId;
  final String email;
  final String? name;

  const PresenceUser({
    required this.userId,
    required this.email,
    this.name,
  });

  factory PresenceUser.fromJson(Map<String, dynamic> json) {
    return PresenceUser(
      userId: json['userId'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String? ?? json['user'] as String? ?? '',
      name: json['name'] as String?,
    );
  }

  @override
  List<Object?> get props => [userId, email, name];
}



