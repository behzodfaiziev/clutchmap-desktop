import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

abstract class AiCoachEvent extends Equatable {
  const AiCoachEvent();

  @override
  List<Object?> get props => [];
}

class AiQuestionSubmitted extends AiCoachEvent {
  final String question;
  final String matchId;
  final Map<String, dynamic> context;
  final List<ChatMessage> history;

  const AiQuestionSubmitted(
    this.question,
    this.matchId,
    this.context,
    this.history,
  );

  @override
  List<Object?> get props => [question, matchId, context, history];
}

class ChatCleared extends AiCoachEvent {
  const ChatCleared();
}

