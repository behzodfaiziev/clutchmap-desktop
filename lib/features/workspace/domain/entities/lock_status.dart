import 'package:equatable/equatable.dart';

class LockStatus extends Equatable {
  final bool locked;
  final String? lockedByUserId;
  final DateTime? expiresAt;

  const LockStatus({
    required this.locked,
    this.lockedByUserId,
    this.expiresAt,
  });

  factory LockStatus.fromJson(Map<String, dynamic> json) {
    return LockStatus(
      locked: json['lockedBy'] != null,
      lockedByUserId: json['lockedBy'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  factory LockStatus.empty() {
    return const LockStatus(locked: false);
  }

  @override
  List<Object?> get props => [locked, lockedByUserId, expiresAt];
}



