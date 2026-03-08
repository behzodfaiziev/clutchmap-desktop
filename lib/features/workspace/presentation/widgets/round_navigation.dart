import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/workspace_bloc.dart';
import '../bloc/workspace_event.dart';
import '../bloc/workspace_state.dart';

class RoundNavigation extends StatelessWidget {
  const RoundNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WorkspaceBloc, WorkspaceState, List<dynamic>>(
      selector: (state) {
        if (state is WorkspaceLoadedState) {
          return [state.rounds, state.selectedIndex];
        }
        return [];
      },
      builder: (context, data) {
        if (data.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final rounds = data[0] as List;
        final selectedIndex = data[1] as int;

        return ListView.builder(
          itemCount: rounds.length,
          itemBuilder: (context, index) {
            final round = rounds[index];

            return ListTile(
              selected: index == selectedIndex,
              selectedTileColor: Colors.blue.withValues(alpha: 0.2),
              title: Text(
                "Round ${round.roundNumber}",
                style: TextStyle(
                  color: index == selectedIndex
                      ? Colors.white
                      : Colors.white70,
                  fontWeight: index == selectedIndex
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                round.side,
                style: TextStyle(
                  color: index == selectedIndex
                      ? Colors.white70
                      : Colors.white54,
                ),
              ),
              onTap: () {
                context.read<WorkspaceBloc>().add(
                  RoundSelected(index),
                );
              },
            );
          },
        );
      },
    );
  }
}

