/// Summary of a game map returned by GET /games/config/{gameType}/maps.
class GameMapSummary {
  final String id;
  final String name;

  const GameMapSummary({required this.id, required this.name});

  factory GameMapSummary.fromJson(Map<String, dynamic> json) {
    return GameMapSummary(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
