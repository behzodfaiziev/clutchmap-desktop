import 'package:flutter/material.dart';
import '../../domain/entities/search_result.dart';

class SearchResultTile extends StatelessWidget {
  final SearchResult result;
  final bool isSelected;
  final VoidCallback onTap;

  const SearchResultTile({
    super.key,
    required this.result,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'MATCH_PLAN':
      case 'MATCH':
        return Icons.sports_esports;
      case 'ROUND':
        return Icons.looks_one;
      case 'TACTICAL_EVENT':
        return Icons.event;
      case 'OPPONENT':
        return Icons.people;
      default:
        return Icons.search;
    }
  }

  String _formatType(String type) {
    return type.replaceAll('_', ' ').toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.blue.shade900.withValues(alpha: 0.3),
      leading: Icon(
        _getTypeIcon(result.type),
        color: isSelected ? Colors.blueAccent : Colors.white70,
      ),
      title: Text(
        result.label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        _formatType(result.type),
        style: TextStyle(
          color: isSelected ? Colors.white54 : Colors.white38,
        ),
      ),
      trailing: result.roundNumber != null
          ? Text(
              "Round ${result.roundNumber}",
              style: TextStyle(
                color: isSelected ? Colors.white54 : Colors.white38,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}



