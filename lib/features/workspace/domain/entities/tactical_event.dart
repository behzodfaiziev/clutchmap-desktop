import 'package:equatable/equatable.dart';

class TacticalEvent extends Equatable {
  final String id;
  final String eventType;
  final int? timestampSec;
  final String? payload;

  const TacticalEvent({
    required this.id,
    required this.eventType,
    this.timestampSec,
    this.payload,
  });

  @override
  List<Object?> get props => [id, eventType, timestampSec, payload];
}



