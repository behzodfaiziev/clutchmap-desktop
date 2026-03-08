class GameConfig {
  final int rounds;
  final List<String> buyTypes;
  final List<String> tacticalEvents;
  final List<String> weapons;

  const GameConfig({
    required this.rounds,
    required this.buyTypes,
    required this.tacticalEvents,
    required this.weapons,
  });

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    return GameConfig(
      rounds: json['regulationRounds'] as int? ?? 25,
      buyTypes: (json['buyTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tacticalEvents: (json['tacticalEvents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      weapons: (json['weapons'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}


