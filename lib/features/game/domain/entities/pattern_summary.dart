/// Strategy pattern from GET /games/config/{gameType}/patterns. DAY_126.
class PatternSummary {
  final String code;
  final String name;

  const PatternSummary({required this.code, required this.name});

  factory PatternSummary.fromJson(Map<String, dynamic> json) {
    return PatternSummary(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
