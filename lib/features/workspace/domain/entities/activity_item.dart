import 'package:equatable/equatable.dart';

class ActivityItem extends Equatable {
  final String message;
  final DateTime timestamp;
  final String? userId;
  final String? eventType;

  const ActivityItem({
    required this.message,
    required this.timestamp,
    this.userId,
    this.eventType,
  });

  @override
  List<Object?> get props => [message, timestamp, userId, eventType];
}



