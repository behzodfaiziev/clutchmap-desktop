import 'package:flutter/material.dart';
import '../../domain/entities/opponent_profile.dart';

class OpponentList extends StatelessWidget {
  final List<OpponentProfile> opponents;
  final String? selectedId;
  final ValueChanged<String> onOpponentSelected;
  final VoidCallback? onCreateOpponent;
  final void Function(OpponentProfile opponent)? onEditOpponent;
  final ValueChanged<String>? onDeleteOpponent;
  /// When set, shows "View matches" for each opponent (navigate to matches filtered by this opponent).
  final void Function(OpponentProfile opponent)? onViewMatches;

  const OpponentList({
    super.key,
    required this.opponents,
    this.selectedId,
    required this.onOpponentSelected,
    this.onCreateOpponent,
    this.onEditOpponent,
    this.onDeleteOpponent,
    this.onViewMatches,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Opponents",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (onCreateOpponent != null)
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Create opponent',
                    onPressed: onCreateOpponent,
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(color: Colors.white24),
          Expanded(
            child: opponents.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.groups_outlined,
                            size: 56,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No opponents yet",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Opponents will appear here when added to your team",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (onCreateOpponent != null) ...[
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: onCreateOpponent,
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('Create opponent'),
                            ),
                          ],
                        ],
                      ),
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
                        trailing: (onEditOpponent != null || onDeleteOpponent != null || onViewMatches != null)
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (onViewMatches != null)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.sports_esports_outlined,
                                        size: 20,
                                        color: Colors.white54,
                                      ),
                                      tooltip: 'View matches vs this opponent',
                                      onPressed: () => onViewMatches!(opponent),
                                    ),
                                  if (onEditOpponent != null)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 20,
                                        color: Colors.white54,
                                      ),
                                      tooltip: 'Edit opponent',
                                      onPressed: () =>
                                          onEditOpponent!(opponent),
                                    ),
                                  if (onDeleteOpponent != null)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                        color: Colors.white54,
                                      ),
                                      tooltip: 'Delete opponent',
                                      onPressed: () async {
                                        final confirmed =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text(
                                                'Delete opponent'),
                                            content: Text(
                                              'Delete "${opponent.name}"? This cannot be undone.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('Cancel'),
                                              ),
                                              FilledButton(
                                                style: FilledButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.red,
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed == true &&
                                            context.mounted) {
                                          onDeleteOpponent!(opponent.id);
                                        }
                                      },
                                    ),
                                ],
                              )
                            : null,
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



