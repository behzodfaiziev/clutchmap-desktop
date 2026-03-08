import 'package:flutter/material.dart';

enum CanvasTool {
  brush,
  arrow,
  icon,
  erase,
}

class CanvasStroke {
  final List<Offset> points;
  final Color color;
  final double width;

  const CanvasStroke({
    required this.points,
    required this.color,
    required this.width,
  });

  Map<String, dynamic> toJson() => {
        "points": points
            .map((p) => {"x": p.dx, "y": p.dy})
            .toList(),
        "color": color.toARGB32(),
        "width": width,
      };

  static CanvasStroke fromJson(Map<String, dynamic> json) {
    return CanvasStroke(
      points: (json["points"] as List)
          .map((p) => Offset(
                (p["x"] as num).toDouble(),
                (p["y"] as num).toDouble(),
              ))
          .toList(),
      color: Color(json["color"] as int),
      width: (json["width"] as num).toDouble(),
    );
  }
}

class CanvasArrow {
  final Offset start;
  final Offset end;
  final Color color;
  final double width;

  const CanvasArrow({
    required this.start,
    required this.end,
    required this.color,
    required this.width,
  });

  Map<String, dynamic> toJson() => {
        "start": {"x": start.dx, "y": start.dy},
        "end": {"x": end.dx, "y": end.dy},
        "color": color.toARGB32(),
        "width": width,
      };

  static CanvasArrow fromJson(Map<String, dynamic> json) {
    return CanvasArrow(
      start: Offset(
        (json["start"]["x"] as num).toDouble(),
        (json["start"]["y"] as num).toDouble(),
      ),
      end: Offset(
        (json["end"]["x"] as num).toDouble(),
        (json["end"]["y"] as num).toDouble(),
      ),
      color: Color(json["color"] as int),
      width: (json["width"] as num).toDouble(),
    );
  }
}

class CanvasObject {
  final String id;
  Offset position;
  final String type; // "ATTACKER" / "DEFENDER"

  CanvasObject({
    required this.id,
    required this.position,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "position": {"x": position.dx, "y": position.dy},
        "type": type,
      };

  static CanvasObject fromJson(Map<String, dynamic> json) {
    return CanvasObject(
      id: json["id"] as String,
      position: Offset(
        (json["position"]["x"] as num).toDouble(),
        (json["position"]["y"] as num).toDouble(),
      ),
      type: json["type"] as String,
    );
  }
}

