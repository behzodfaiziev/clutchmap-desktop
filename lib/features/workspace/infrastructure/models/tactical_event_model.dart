import '../../domain/entities/tactical_event.dart';

class TacticalEventModel extends TacticalEvent {
  const TacticalEventModel({
    required super.id,
    required super.eventType,
    super.timestampSec,
    super.payload,
  });

  factory TacticalEventModel.fromJson(Map<String, dynamic> json) {
    return TacticalEventModel(
      id: json['id'] as String,
      eventType: json['eventType'] as String,
      timestampSec: json['timestampSec'] as int?,
      payload: json['payload'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventType': eventType,
      'timestampSec': timestampSec,
      'payload': payload,
    };
  }
}



