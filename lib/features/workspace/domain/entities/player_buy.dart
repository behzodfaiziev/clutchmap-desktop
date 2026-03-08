import 'package:equatable/equatable.dart';

class PlayerBuy extends Equatable {
  final String playerId;
  final String weapon;

  const PlayerBuy({
    required this.playerId,
    required this.weapon,
  });

  Map<String, dynamic> toJson() => {
        "playerId": playerId,
        "weapon": weapon,
      };

  static PlayerBuy fromJson(Map<String, dynamic> json) {
    return PlayerBuy(
      playerId: json["playerId"] as String,
      weapon: json["weapon"] as String,
    );
  }

  @override
  List<Object?> get props => [playerId, weapon];
}



