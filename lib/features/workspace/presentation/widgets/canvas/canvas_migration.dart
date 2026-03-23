import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tactical_object.dart';
import 'canvas_models.dart';

/// Migrates old canvas format (strokes, arrows, objects) to new tactical object format
class CanvasMigration {
  static List<TacticalObject> migrateFromLegacy({
    required List<CanvasStroke> strokes,
    required List<CanvasArrow> arrows,
    required List<CanvasObject> objects,
    required Size canvasSize,
  }) {
    final tacticalObjects = <TacticalObject>[];

    // Convert strokes to MovementArrows (normalized)
    for (var stroke in strokes) {
      if (stroke.points.length < 2) continue;
      
      final normalizedPoints = stroke.points.map((p) => Offset(
        p.dx / canvasSize.width,
        p.dy / canvasSize.height,
      )).toList();

      tacticalObjects.add(
        MovementArrow(
          id: "migrated_stroke_${tacticalObjects.length}",
          points: normalizedPoints,
          color: stroke.color,
          width: stroke.width / math.min(canvasSize.width, canvasSize.height),
        ),
      );
    }

    // Convert arrows to MovementArrows (normalized)
    for (var arrow in arrows) {
      final normalizedStart = Offset(
        arrow.start.dx / canvasSize.width,
        arrow.start.dy / canvasSize.height,
      );
      final normalizedEnd = Offset(
        arrow.end.dx / canvasSize.width,
        arrow.end.dy / canvasSize.height,
      );

      tacticalObjects.add(
        MovementArrow(
          id: "migrated_arrow_${tacticalObjects.length}",
          points: [normalizedStart, normalizedEnd],
          color: arrow.color,
          width: arrow.width / math.min(canvasSize.width, canvasSize.height),
        ),
      );
    }

    // Convert objects to PlayerMarkers (normalized)
    for (var obj in objects) {
      final normalizedPosition = Offset(
        obj.position.dx / canvasSize.width,
        obj.position.dy / canvasSize.height,
      );

      tacticalObjects.add(
        PlayerMarker(
          id: obj.id,
          position: normalizedPosition,
          label: obj.type == "ATTACKER" ? "A" : "D",
          color: obj.type == "ATTACKER"
              ? Colors.redAccent
              : Colors.blueAccent,
        ),
      );
    }

    return tacticalObjects;
  }

  /// Converts new tactical objects format to legacy format (for backward compatibility)
  static Map<String, dynamic> convertToLegacyFormat(
    List<TacticalObject> objects,
    Size canvasSize,
  ) {
    final strokes = <Map<String, dynamic>>[];
    final arrows = <Map<String, dynamic>>[];
    final legacyObjects = <Map<String, dynamic>>[];

    for (var obj in objects) {
      if (obj is MovementArrow) {
        // Convert to legacy arrow format
        if (obj.points.length >= 2) {
          final denormalizedStart = Offset(
            obj.points.first.dx * canvasSize.width,
            obj.points.first.dy * canvasSize.height,
          );
          final denormalizedEnd = Offset(
            obj.points.last.dx * canvasSize.width,
            obj.points.last.dy * canvasSize.height,
          );

          arrows.add({
            "start": {"x": denormalizedStart.dx, "y": denormalizedStart.dy},
            "end": {"x": denormalizedEnd.dx, "y": denormalizedEnd.dy},
            "color": obj.color.value,
            "width": obj.width * math.min(canvasSize.width, canvasSize.height),
          });
        }
      } else if (obj is PlayerMarker) {
        // Convert to legacy object format
        final denormalizedPosition = Offset(
          obj.position.dx * canvasSize.width,
          obj.position.dy * canvasSize.height,
        );

        legacyObjects.add({
          "id": obj.id,
          "position": {
            "x": denormalizedPosition.dx,
            "y": denormalizedPosition.dy,
          },
          "type": obj.color == Colors.redAccent ? "ATTACKER" : "DEFENDER",
        });
      }
    }

    return {
      "strokes": strokes,
      "arrows": arrows,
      "objects": legacyObjects,
    };
  }

  /// Parses canvas JSON and returns tactical objects (supports both formats)
  static List<TacticalObject> parseCanvasJson(
    Map<String, dynamic> canvasData,
    Size canvasSize,
  ) {
    // Check if it's new format (has "objects" array with "type" field)
    if (canvasData.containsKey("objects") &&
        canvasData["objects"] is List) {
      final objectsList = canvasData["objects"] as List;
      if (objectsList.isNotEmpty) {
        final firstObj = objectsList.first;
        if (firstObj is Map && firstObj.containsKey("type")) {
          // New format
          return objectsList
              .map((obj) => TacticalObjectFactory.fromJson(
                    obj as Map<String, dynamic>,
                  ))
              .whereType<TacticalObject>()
              .toList();
        }
      }
    }

    // Legacy format - migrate
    final strokesList = canvasData["strokes"] as List<dynamic>? ?? [];
    final arrowsList = canvasData["arrows"] as List<dynamic>? ?? [];
    final objectsList = canvasData["objects"] as List<dynamic>? ?? [];

    final strokes = strokesList
        .map((e) => CanvasStroke.fromJson(e as Map<String, dynamic>))
        .toList();
    final arrows = arrowsList
        .map((e) => CanvasArrow.fromJson(e as Map<String, dynamic>))
        .toList();
    final objects = objectsList
        .map((e) => CanvasObject.fromJson(e as Map<String, dynamic>))
        .toList();

    return migrateFromLegacy(
      strokes: strokes,
      arrows: arrows,
      objects: objects,
      canvasSize: canvasSize,
    );
  }

  /// Serializes tactical objects to JSON (new format)
  static Map<String, dynamic> serializeToJson(List<TacticalObject> objects) {
    return {
      "version": 2,
      "objects": objects.map((obj) => obj.toJson()).toList(),
    };
  }
}
