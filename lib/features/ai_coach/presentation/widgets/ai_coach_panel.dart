import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../infrastructure/datasources/ai_coach_remote_data_source.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/ai_coach_response.dart';
import '../bloc/ai_coach_bloc.dart';
import '../bloc/ai_coach_event.dart';
import '../bloc/ai_coach_state.dart';
import '../../../workspace/presentation/bloc/workspace_state.dart';

class AiCoachPanel extends StatelessWidget {
  final String matchId;
  final WorkspaceLoadedState workspaceState;

  const AiCoachPanel({
    super.key,
    required this.matchId,
    required this.workspaceState,
  });

  Map<String, dynamic> _buildCompressedContext() {
    return {
      "matchSummary": {
        "aggression": workspaceState.matchIntel?.aggression ?? 0,
        "structure": workspaceState.matchIntel?.structure ?? 0,
        "variety": workspaceState.matchIntel?.variety ?? 0,
        "overall": workspaceState.matchIntel?.overall ?? 0,
        "risk": workspaceState.matchRisk?.risk ?? 0,
        "volatility": workspaceState.matchRisk?.volatility ?? 0,
      },
      "recentRounds": workspaceState.rounds
          .take(5)
          .map((r) {
            final events = workspaceState.tacticalEvents[r.id] ?? [];
            return {
              "number": r.roundNumber,
              "side": r.side,
              "buy": workspaceState.buyTypes[r.id]?.name,
              "events": events.map((e) => e.eventType).toList(),
            };
          })
          .toList(),
      "opponent": workspaceState.matchup != null
          ? {
              "predictedAdvantage": workspaceState.matchup!.predictedAdvantage,
              "confidence": workspaceState.matchup!.confidence,
            }
          : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AiCoachBloc(
        dataSource: AiCoachRemoteDataSource(getIt<ApiClient>()),
      ),
      child: _AiCoachPanelContent(
        matchId: matchId,
        buildContext: _buildCompressedContext,
      ),
    );
  }
}

class _AiCoachPanelContent extends StatefulWidget {
  final String matchId;
  final Map<String, dynamic> Function() buildContextFn;

  const _AiCoachPanelContent({
    required this.matchId,
    required Map<String, dynamic> Function() buildContext,
  }) : buildContextFn = buildContext;

  @override
  State<_AiCoachPanelContent> createState() => _AiCoachPanelContentState();
}

class _AiCoachPanelContentState extends State<_AiCoachPanelContent> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _submitQuestion(String question, List<ChatMessage> history) {
    if (question.trim().isEmpty) return;

    context.read<AiCoachBloc>().add(
          AiQuestionSubmitted(
            question.trim(),
            widget.matchId,
            widget.buildContextFn(),
            history,
          ),
        );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            border: Border(
              bottom: BorderSide(color: Colors.white24, width: 1),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                "AI Coach",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<AiCoachBloc>().add(const ChatCleared());
                },
                tooltip: "Reset conversation",
              ),
            ],
          ),
        ),
        // Chat History
        Expanded(
          child: BlocListener<AiCoachBloc, AiCoachState>(
            listener: (context, state) {
              if (state is AiCoachLoaded && !state.isLoading) {
                // Auto-scroll after new message
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
              }
            },
            child: BlocBuilder<AiCoachBloc, AiCoachState>(
              builder: (context, state) {
                if (state is AiCoachError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<AiCoachBloc>().add(const ChatCleared());
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is AiCoachLoaded) {
                  if (state.messages.isEmpty && !state.isLoading) {
                    return const Center(
                      child: Text(
                        "Ask me anything about this match...",
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.messages.length && state.isLoading) {
                        // Loading indicator
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "AI Coach is thinking...",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final msg = state.messages[index];
                      return _ChatMessageBubble(message: msg);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        // Follow-up Suggestions
        BlocBuilder<AiCoachBloc, AiCoachState>(
          builder: (context, state) {
            if (state is AiCoachLoaded &&
                state.lastResponse != null &&
                !state.isLoading) {
              final followUps = _generateFollowUps(state.lastResponse!);
              if (followUps.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    border: Border(
                      top: BorderSide(color: Colors.white24, width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "You may also ask:",
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: followUps.map((followUp) {
                          return ActionChip(
                            label: Text(
                              followUp,
                              style: const TextStyle(fontSize: 11),
                            ),
                            onPressed: () {
                              final history = state.messages;
                              _submitQuestion(followUp, history);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),
        // Suggested Adjustments
        BlocBuilder<AiCoachBloc, AiCoachState>(
          builder: (context, state) {
            if (state is AiCoachLoaded && state.lastResponse != null) {
              final response = state.lastResponse!;
              if (response.suggestions.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    border: Border(
                      top: BorderSide(color: Colors.white24, width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Suggested Adjustments:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...response.suggestions.map((s) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              "Round ${s.roundNumber}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            subtitle: Text(
                              s.recommendation,
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.open_in_new, size: 16),
                              onPressed: () {
                                // TODO: Navigate to round
                              },
                            ),
                          )),
                    ],
                  ),
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),
        // Confidence Indicator
        BlocBuilder<AiCoachBloc, AiCoachState>(
          builder: (context, state) {
            if (state is AiCoachLoaded && state.lastResponse != null) {
              final confidence = state.lastResponse!.confidence;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  border: Border(
                    top: BorderSide(color: Colors.white24, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          "AI Confidence: ",
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          "$confidence%",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: confidence > 70 ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: confidence / 100,
                      backgroundColor: Colors.grey.shade700,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        confidence > 70 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        // Quick Prompts
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            border: Border(
              top: BorderSide(color: Colors.white24, width: 1),
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _QuickPrompt("Explain risk", widget.matchId, widget.buildContextFn),
              _QuickPrompt("Suggest safer plan", widget.matchId, widget.buildContextFn),
              _QuickPrompt("Improve eco strategy", widget.matchId, widget.buildContextFn),
              _QuickPrompt("Counter aggression", widget.matchId, widget.buildContextFn),
            ],
          ),
        ),
        // Input Field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            border: Border(
              top: BorderSide(color: Colors.white24, width: 1),
            ),
          ),
          child: BlocBuilder<AiCoachBloc, AiCoachState>(
            builder: (context, state) {
              final isLoading = state is AiCoachLoaded && state.isLoading;
              return TextField(
                controller: _controller,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: isLoading
                      ? "AI Coach is thinking..."
                      : "Ask AI Coach about this match...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: isLoading
                        ? null
                        : () {
                            final question = _controller.text.trim();
                            if (question.isNotEmpty) {
                              final history = state is AiCoachLoaded
                                  ? state.messages
                                  : <ChatMessage>[];
                              _submitQuestion(question, history);
                            }
                          },
                  ),
                ),
                onSubmitted: isLoading
                    ? null
                    : (value) {
                        if (value.trim().isNotEmpty) {
                          final history = state is AiCoachLoaded
                              ? state.messages
                              : <ChatMessage>[];
                          _submitQuestion(value.trim(), history);
                        }
                      },
              );
            },
          ),
        ),
      ],
    );
  }

  List<String> _generateFollowUps(AiCoachResponse response) {
    // Simple follow-up suggestions based on response
    return [
      "How does this affect risk?",
      "Can we adapt this for eco rounds?",
      "What if opponent slows tempo?",
    ];
  }
}

class _QuickPrompt extends StatelessWidget {
  final String text;
  final String matchId;
  final Map<String, dynamic> Function() buildContextFn;

  const _QuickPrompt(
    this.text,
    this.matchId,
    this.buildContextFn,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiCoachBloc, AiCoachState>(
      builder: (context, state) {
        final isLoading = state is AiCoachLoaded && state.isLoading;
        return OutlinedButton(
          onPressed: isLoading
              ? null
              : () {
                  final history = state is AiCoachLoaded
                      ? state.messages
                      : <ChatMessage>[];
                  context.read<AiCoachBloc>().add(
                        AiQuestionSubmitted(
                          text,
                          matchId,
                          buildContextFn(),
                          history,
                        ),
                      );
                },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        );
      },
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: message.fromUser
              ? Colors.blueAccent
              : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
