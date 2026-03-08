import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/workspace_bloc.dart';
import '../../bloc/workspace_state.dart';
import '../../../domain/entities/activity_item.dart';

class ActivityFeedPanel extends StatelessWidget {
  const ActivityFeedPanel({super.key});

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceBloc, WorkspaceState>(
      builder: (context, state) {
        if (state is! WorkspaceLoadedState) {
          return const SizedBox.shrink();
        }

        final activities = state.activities;

        return Container(
          color: Colors.grey.shade900,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Activity Feed",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              Expanded(
                child: activities.isEmpty
                    ? const Center(
                        child: Text(
                          "No activity yet",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        reverse: false,
                        itemCount: activities.length,
                        itemBuilder: (context, index) {
                          final item = activities[index];
                          return ListTile(
                            dense: true,
                            title: Text(
                              item.message,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              _formatTime(item.timestamp),
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
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

