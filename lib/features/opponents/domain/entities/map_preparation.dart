import 'package:equatable/equatable.dart';

class MapPreparation extends Equatable {
  final String mapId;
  final String mapName;
  final String notes;
  final String predictedAdvantage;
  final int confidence;

  const MapPreparation({
    required this.mapId,
    required this.mapName,
    required this.notes,
    required this.predictedAdvantage,
    required this.confidence,
  });

  factory MapPreparation.fromJson(Map<String, dynamic> json) {
    return MapPreparation(
      mapId: json['mapId'] as String,
      mapName: json['mapName'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      predictedAdvantage: json['predictedAdvantage'] as String? ?? 'EVEN_MATCH',
      confidence: json['confidence'] as int? ?? 0,
    );
  }

  MapPreparation copyWith({
    String? mapId,
    String? mapName,
    String? notes,
    String? predictedAdvantage,
    int? confidence,
  }) {
    return MapPreparation(
      mapId: mapId ?? this.mapId,
      mapName: mapName ?? this.mapName,
      notes: notes ?? this.notes,
      predictedAdvantage: predictedAdvantage ?? this.predictedAdvantage,
      confidence: confidence ?? this.confidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mapId': mapId,
      'mapName': mapName,
      'notes': notes,
      'predictedAdvantage': predictedAdvantage,
      'confidence': confidence,
    };
  }

  @override
  List<Object?> get props => [mapId, mapName, notes, predictedAdvantage, confidence];
}



