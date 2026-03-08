import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/ai_coach_response.dart';

abstract class AiCoachState extends Equatable {
  const AiCoachState();

  @override
  List<Object?> get props => [];
}

class AiCoachInitial extends AiCoachState {}

class AiCoachLoading extends AiCoachState {}

class AiCoachLoaded extends AiCoachState {
  final List<ChatMessage> messages;
  final AiCoachResponse? lastResponse;
  final bool isLoading;

  const AiCoachLoaded({
    required this.messages,
    this.lastResponse,
    this.isLoading = false,
  });

  AiCoachLoaded copyWith({
    List<ChatMessage>? messages,
    AiCoachResponse? lastResponse,
    bool? isLoading,
  }) {
    return AiCoachLoaded(
      messages: messages ?? this.messages,
      lastResponse: lastResponse ?? this.lastResponse,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [messages, lastResponse, isLoading];
}

class AiCoachError extends AiCoachState {
  final String message;

  const AiCoachError(this.message);

  @override
  List<Object?> get props => [message];
}

