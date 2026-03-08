import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String text;
  final bool fromUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.fromUser,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [text, fromUser, timestamp];
}

