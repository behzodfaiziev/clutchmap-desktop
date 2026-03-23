/// Response from POST /games/config/VALORANT/prediction-context. DAY_128.
class ValorantContextResponse {
  final int synergyScore;
  final int counterGap;
  final List<String> weakAgainst;
  final int retakeScore;

  const ValorantContextResponse({
    required this.synergyScore,
    required this.counterGap,
    required this.weakAgainst,
    required this.retakeScore,
  });

  factory ValorantContextResponse.fromJson(Map<String, dynamic> json) {
    final weak = json['weakAgainst'];
    return ValorantContextResponse(
      synergyScore: json['synergyScore'] as int? ?? 0,
      counterGap: json['counterGap'] as int? ?? 0,
      weakAgainst: weak is List
          ? (weak as List<dynamic>).map((e) => e.toString()).toList()
          : [],
      retakeScore: json['retakeScore'] as int? ?? 0,
    );
  }
}
