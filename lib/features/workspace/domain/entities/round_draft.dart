import 'package:equatable/equatable.dart';
import 'player_buy.dart';

class RoundDraft extends Equatable {
  final String roundId;
  final String notes;
  final Map<String, dynamic> drawingJson; // Canvas state as JSON
  final List<PlayerBuy> buys;

  const RoundDraft({
    required this.roundId,
    required this.notes,
    required this.drawingJson,
    required this.buys,
  });

  Map<String, dynamic> toJson() => {
    "roundId": roundId,
    "notes": notes,
    "drawing": drawingJson,
    "buys": buys.map((b) => b.toJson()).toList(),
  };

  factory RoundDraft.fromJson(Map<String, dynamic> json) {
    return RoundDraft(
      roundId: json["roundId"] as String,
      notes: json["notes"] as String? ?? "",
      drawingJson: json["drawing"] as Map<String, dynamic>? ?? {},
      buys: (json["buys"] as List<dynamic>?)
          ?.map((b) => PlayerBuy.fromJson(b as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [roundId, notes, drawingJson, buys];
}

