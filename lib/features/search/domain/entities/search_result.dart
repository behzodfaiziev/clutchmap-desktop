import 'package:equatable/equatable.dart';

class SearchResult extends Equatable {
  final String type;
  final String id;
  final String label;
  final String? matchId;
  final int? roundNumber;
  /// Chunk result: snippet text (may equal label).
  final String? textSnippet;
  /// Chunk result: ROUND_NOTE, VOD_TAG, etc.
  final String? sourceType;
  /// Chunk result: scopeId (match or report id).
  final String? scopeId;
  /// Chunk result: score 0..1.
  final double? score;
  /// Chunk result: metadata for jump-to-context.
  final Map<String, dynamic>? metadata;

  const SearchResult({
    required this.type,
    required this.id,
    required this.label,
    this.matchId,
    this.roundNumber,
    this.textSnippet,
    this.sourceType,
    this.scopeId,
    this.score,
    this.metadata,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    // Backend GET returns: id, title, mapName, type
    final type = json['type'] as String? ?? 'MATCH_PLAN';
    final id = json['id'] as String? ?? '';
    final title = json['title'] as String? ?? '';
    final mapName = json['mapName'] as String? ?? '';
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

  /// From hybrid search (POST) chunk result: id, textSnippet, sourceType, scopeId, scope, metadata, score.
  factory SearchResult.fromHybridJson(Map<String, dynamic> json) {
    final id = (json['id'] as Object?).toString();
    final textSnippet = json['textSnippet'] as String? ?? '';
    final sourceType = json['sourceType'] as String? ?? 'ROUND_NOTE';
    final scopeId = json['scopeId'] != null ? (json['scopeId'] as Object).toString() : null;
    final meta = json['metadata'] as Map<String, dynamic>? ?? {};
    final matchId = meta['matchId']?.toString();
    final round = meta['round'];
    final roundNumber = round is int ? round : (round is num ? round.toInt() : null);
    final score = (json['score'] as num?)?.toDouble();
    final label = textSnippet.length > 80 ? '${textSnippet.substring(0, 77)}...' : textSnippet;
    return SearchResult(
      type: sourceType,
      id: id,
      label: label,
      matchId: matchId,
      roundNumber: roundNumber,
      textSnippet: textSnippet,
      sourceType: sourceType,
      scopeId: scopeId,
      score: score,
      metadata: meta.isNotEmpty ? meta : null,
    );
  }

  @override
  List<Object?> get props => [type, id, label, matchId, roundNumber, textSnippet, sourceType, scopeId, score];
}

