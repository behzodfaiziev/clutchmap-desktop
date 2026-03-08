import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/workspace_bloc.dart';
import '../bloc/workspace_event.dart';
import '../bloc/workspace_state.dart';
import '../../domain/entities/tactical_event.dart';

class TacticalEventsPanel extends StatelessWidget {
  const TacticalEventsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceBloc, WorkspaceState>(
      builder: (context, state) {
        if (state is! WorkspaceLoadedState) {
          return const SizedBox.shrink();
        }

        final round = state.rounds[state.selectedIndex];
        final events = state.tacticalEvents[round.id] ?? [];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            border: const Border(
              left: BorderSide(color: Colors.white24, width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tactical Events",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickEventButton(
                    type: "EXECUTE_START",
                    roundId: round.id,
                  ),
                  _QuickEventButton(
                    type: "DEFAULT_SETUP",
                    roundId: round.id,
                  ),
                  _QuickEventButton(
                    type: "FAKE_EXECUTE",
                    roundId: round.id,
                  ),
                  _QuickEventButton(
                    type: "RETAKE_PLAN",
                    roundId: round.id,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: events.isEmpty
                    ? Center(
                        child: Text(
                          "No tactical events",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return _EventListItem(
                            event: event,
                            roundId: round.id,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickEventButton extends StatelessWidget {
  final String type;
  final String roundId;

  const _QuickEventButton({required this.type, required this.roundId});

  Color _eventColor(String type) {
    switch (type) {
      case "EXECUTE_START":
        return Colors.redAccent;
      case "DEFAULT_SETUP":
        return Colors.blueAccent;
      case "FAKE_EXECUTE":
        return Colors.orangeAccent;
      case "RETAKE_PLAN":
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _eventColor(type);
    return ElevatedButton(
      onPressed: () {
        context.read<WorkspaceBloc>().add(
              TacticalEventAdded(roundId: roundId, eventType: type),
            );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        type.replaceAll("_", " "),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final TacticalEvent event;
  final String roundId;

  const _EventListItem({required this.event, required this.roundId});

  Color _eventColor(String type) {
    switch (type) {
      case "EXECUTE_START":
        return Colors.redAccent;
      case "DEFAULT_SETUP":
        return Colors.blueAccent;
      case "FAKE_EXECUTE":
        return Colors.orangeAccent;
      case "RETAKE_PLAN":
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _eventColor(event.eventType);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(
        event.eventType.replaceAll("_", " "),
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: event.timestampSec != null
          ? Text(
              "${event.timestampSec}s",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            )
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.close, color: Colors.white54, size: 18),
        onPressed: () {
          context.read<WorkspaceBloc>().add(
                TacticalEventRemoved(roundId: roundId, eventId: event.id),
              );
        },
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}



