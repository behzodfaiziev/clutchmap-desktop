import 'package:equatable/equatable.dart';

class SearchResult extends Equatable {
  final String type;
  final String id;
  final String label;
  final String? matchId;
  final int? roundNumber;

  const SearchResult({
    required this.type,
    required this.id,
    required this.label,
    this.matchId,
    this.roundNumber,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    // Backend returns: id, title, mapName, type
    final type = json['type'] as String? ?? 'MATCH_PLAN';
    final id = json['id'] as String? ?? '';
    final title = json['title'] as String? ?? '';
    final mapName = json['mapName'] as String? ?? '';
    
    // Construct label from title and mapName
    final label = mapName != null && mapName.isNotEmpty
        ? "$title ($mapName)"
        : title;
    
    return SearchResult(
      type: type,
      id: id,
      label: label,
      matchId: type == 'ROUND' ? json['matchId'] as String? : null,
      roundNumber: json['roundNumber'] as int?,
    );
  }

  @override
  List<Object?> get props => [type, id, label, matchId, roundNumber];
}

