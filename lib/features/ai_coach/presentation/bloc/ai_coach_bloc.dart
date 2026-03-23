import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/backend_error_helper.dart';
import '../../infrastructure/datasources/ai_coach_remote_data_source.dart';
import '../../domain/entities/chat_message.dart';
import '../bloc/ai_coach_event.dart';
import '../bloc/ai_coach_state.dart';

class AiCoachBloc extends Bloc<AiCoachEvent, AiCoachState> {
  final AiCoachRemoteDataSource dataSource;

  AiCoachBloc({required this.dataSource}) : super(AiCoachInitial()) {
    on<AiQuestionSubmitted>(_onQuestionSubmitted);
    on<ChatCleared>(_onChatCleared);
  }

  Future<void> _onQuestionSubmitted(
    AiQuestionSubmitted event,
    Emitter<AiCoachState> emit,
  ) async {
    // Prevent spam
    if (state is AiCoachLoaded && (state as AiCoachLoaded).isLoading) {
      return;
    }

    // Add user message
    final userMessage = ChatMessage(
      text: event.question,
      fromUser: true,
      timestamp: DateTime.now(),
    );

    List<ChatMessage> currentMessages = [];
    if (state is AiCoachLoaded) {
      currentMessages = (state as AiCoachLoaded).messages;
    }

    emit(AiCoachLoaded(
      messages: [...currentMessages, userMessage],
      isLoading: true,
    ));

    try {
      // Get AI response with history
      final response = await dataSource.askQuestion(
        matchId: event.matchId,
        question: event.question,
        context: event.context,
        history: event.history,
      );

      // Add AI message
      final aiMessage = ChatMessage(
        text: response.answer,
        fromUser: false,
        timestamp: DateTime.now(),
      );

      emit(AiCoachLoaded(
        messages: [...currentMessages, userMessage, aiMessage],
        lastResponse: response,
        isLoading: false,
      ));
    } catch (e) {
      emit(AiCoachError(messageFromException(e, fallback: 'Failed to get AI response')));
    }
  }

  void _onChatCleared(
    ChatCleared event,
    Emitter<AiCoachState> emit,
  ) {
    emit(const AiCoachLoaded(messages: []));
  }
}

