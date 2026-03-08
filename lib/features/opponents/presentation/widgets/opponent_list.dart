import 'package:flutter/material.dart';
import '../../domain/entities/opponent_profile.dart';

class OpponentList extends StatelessWidget {
  final List<OpponentProfile> opponents;
  final String? selectedId;
  final ValueChanged<String> onOpponentSelected;

  const OpponentList({
    super.key,
    required this.opponents,
    this.selectedId,
    required this.onOpponentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Opponents",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(color: Colors.white24),
          Expanded(
            child: opponents.isEmpty
                ? const Center(
                    child: Text(
                      "No opponents yet",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    itemCount: opponents.length,
                    itemBuilder: (context, index) {
                      final opponent = opponents[index];
                      final isSelected = opponent.id == selectedId;

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: Colors.blue.shade900.withValues(alpha: 0.3),
                        title: Text(
                          opponent.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        onTap: () => onOpponentSelected(opponent.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}



