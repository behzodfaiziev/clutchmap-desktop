import 'package:flutter/material.dart';
import 'dart:math' as math;

enum TacticalLayerType {
  background, // map image
  utility, // smokes, flashes
  movement, // arrows
  positions, // player markers
  annotations, // text
  highlights, // circles, zones
}

abstract class TacticalObject {
  final String id;
  final TacticalLayerType layer;
  final bool locked;

  const TacticalObject({
    required this.id,
    required this.layer,
    this.locked = false,
  });

  void draw(Canvas canvas, Size size);
  TacticalObject copyWith();
  Map<String, dynamic> toJson();
}

class PlayerMarker extends TacticalObject {
  final Offset position; // normalized 0-1
  final String label;
  final Color color;
  final double size;

  const PlayerMarker({
    required super.id,
    required this.position,
    required this.label,
    required this.color,
    this.size = 24.0,
    super.locked = false,
  }) : super(layer: TacticalLayerType.positions);

  @override
  void draw(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final actualPosition = Offset(
      position.dx * size.width,
      position.dy * size.height,
    );
    
    canvas.drawCircle(actualPosition, this.size / 2, paint);
    
    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      actualPosition - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  TacticalObject copyWith({
    String? id,
    Offset? position,
    String? label,
    Color? color,
    double? size,
    bool? locked,
  }) {
    return PlayerMarker(
      id: id ?? this.id,
      position: position ?? this.position,
      label: label ?? this.label,
      color: color ?? this.color,
      size: size ?? this.size,
      locked: locked ?? this.locked,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "PlayerMarker",
      "id": id,
      "layer": layer.name,
      "position": {"x": position.dx, "y": position.dy},
      "label": label,
      "color": color.value,
      "size": size,
      "locked": locked,
    };
  }

  static PlayerMarker fromJson(Map<String, dynamic> json) {
    return PlayerMarker(
      id: json["id"] as String,
      position: Offset(
        (json["position"]["x"] as num).toDouble(),
        (json["position"]["y"] as num).toDouble(),
      ),
      label: json["label"] as String? ?? "",
      color: Color(json["color"] as int? ?? Colors.redAccent.value),
      size: (json["size"] as num?)?.toDouble() ?? 24.0,
      locked: json["locked"] as bool? ?? false,
    );
  }
}

class MovementArrow extends TacticalObject {
  final List<Offset> points; // normalized 0-1
  final Color color;
  final double width;

  const MovementArrow({
    required super.id,
    required this.points,
    required this.color,
    this.width = 3.0,
    super.locked = false,
  }) : super(layer: TacticalLayerType.movement);

  @override
  void draw(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final actualPoints = points.map((p) => Offset(
      p.dx * size.width,
      p.dy * size.height,
    )).toList();

    path.moveTo(actualPoints[0].dx, actualPoints[0].dy);
    for (int i = 1; i < actualPoints.length; i++) {
      path.lineTo(actualPoints[i].dx, actualPoints[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw arrowhead at the end
    if (actualPoints.length >= 2) {
      final end = actualPoints.last;
      final prev = actualPoints[actualPoints.length - 2];
      final angle = (end - prev).direction;
      
      final arrowPath = Path();
      final arrowSize = 8.0;
      final cosAngle = math.cos(angle);
      final sinAngle = math.sin(angle);
      
      arrowPath.moveTo(end.dx, end.dy);
      arrowPath.lineTo(
        end.dx - arrowSize * (cosAngle + sinAngle * 0.5),
        end.dy - arrowSize * (sinAngle - cosAngle * 0.5),
      );
      arrowPath.lineTo(
        end.dx - arrowSize * (cosAngle - sinAngle * 0.5),
        end.dy - arrowSize * (sinAngle + cosAngle * 0.5),
      );
      arrowPath.close();
      
      canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
    }
  }

  @override
  TacticalObject copyWith({
    String? id,
    List<Offset>? points,
    Color? color,
    double? width,
    bool? locked,
  }) {
    return MovementArrow(
      id: id ?? this.id,
      points: points ?? this.points,
      color: color ?? this.color,
      width: width ?? this.width,
      locked: locked ?? this.locked,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "MovementArrow",
      "id": id,
      "layer": layer.name,
      "points": points.map((p) => {"x": p.dx, "y": p.dy}).toList(),
      "color": color.value,
      "width": width,
      "locked": locked,
    };
  }

  static MovementArrow fromJson(Map<String, dynamic> json) {
    return MovementArrow(
      id: json["id"] as String,
      points: (json["points"] as List)
          .map((p) => Offset(
                (p["x"] as num).toDouble(),
                (p["y"] as num).toDouble(),
              ))
          .toList(),
      color: Color(json["color"] as int? ?? Colors.blueAccent.value),
      width: (json["width"] as num?)?.toDouble() ?? 3.0,
      locked: json["locked"] as bool? ?? false,
    );
  }
}

class ZoneCircle extends TacticalObject {
  final Offset center; // normalized 0-1
  final double radius; // normalized 0-1
  final Color fill;
  final double strokeWidth;
  final Color? strokeColor;

  const ZoneCircle({
    required super.id,
    required this.center,
    required this.radius,
    required this.fill,
    this.strokeWidth = 2.0,
    this.strokeColor,
    super.locked = false,
  }) : super(layer: TacticalLayerType.utility);

  @override
  void draw(Canvas canvas, Size size) {
    final actualCenter = Offset(
      center.dx * size.width,
      center.dy * size.height,
    );
    final actualRadius = radius * (size.width + size.height) / 2;

    final fillPaint = Paint()
      ..color = fill.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(actualCenter, actualRadius, fillPaint);

    if (strokeColor != null) {
      final strokePaint = Paint()
        ..color = strokeColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(actualCenter, actualRadius, strokePaint);
    }
  }

  @override
  TacticalObject copyWith({
    String? id,
    Offset? center,
    double? radius,
    Color? fill,
    double? strokeWidth,
    Color? strokeColor,
    bool? locked,
  }) {
    return ZoneCircle(
      id: id ?? this.id,
      center: center ?? this.center,
      radius: radius ?? this.radius,
      fill: fill ?? this.fill,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeColor: strokeColor ?? this.strokeColor,
      locked: locked ?? this.locked,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "ZoneCircle",
      "id": id,
      "layer": layer.name,
      "center": {"x": center.dx, "y": center.dy},
      "radius": radius,
      "fill": fill.value,
      "strokeWidth": strokeWidth,
      "strokeColor": strokeColor?.value,
      "locked": locked,
    };
  }

  static ZoneCircle fromJson(Map<String, dynamic> json) {
    return ZoneCircle(
      id: json["id"] as String,
      center: Offset(
        (json["center"]["x"] as num).toDouble(),
        (json["center"]["y"] as num).toDouble(),
      ),
      radius: (json["radius"] as num).toDouble(),
      fill: Color(json["fill"] as int? ?? Colors.orange.value),
      strokeWidth: (json["strokeWidth"] as num?)?.toDouble() ?? 2.0,
      strokeColor: json["strokeColor"] != null
          ? Color(json["strokeColor"] as int)
          : null,
      locked: json["locked"] as bool? ?? false,
    );
  }
}

class TextNote extends TacticalObject {
  final Offset position; // normalized 0-1
  final String text;
  final Color color;
  final double fontSize;

  const TextNote({
    required super.id,
    required this.position,
    required this.text,
    required this.color,
    this.fontSize = 14.0,
    super.locked = false,
  }) : super(layer: TacticalLayerType.annotations);

  @override
  void draw(Canvas canvas, Size size) {
    final actualPosition = Offset(
      position.dx * size.width,
      position.dy * size.height,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, actualPosition);
  }

  @override
  TacticalObject copyWith({
    String? id,
    Offset? position,
    String? text,
    Color? color,
    double? fontSize,
    bool? locked,
  }) {
    return TextNote(
      id: id ?? this.id,
      position: position ?? this.position,
      text: text ?? this.text,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      locked: locked ?? this.locked,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "TextNote",
      "id": id,
      "layer": layer.name,
      "position": {"x": position.dx, "y": position.dy},
      "text": text,
      "color": color.value,
      "fontSize": fontSize,
      "locked": locked,
    };
  }

  static TextNote fromJson(Map<String, dynamic> json) {
    return TextNote(
      id: json["id"] as String,
      position: Offset(
        (json["position"]["x"] as num).toDouble(),
        (json["position"]["y"] as num).toDouble(),
      ),
      text: json["text"] as String? ?? "",
      color: Color(json["color"] as int? ?? Colors.white.value),
      fontSize: (json["fontSize"] as num?)?.toDouble() ?? 14.0,
      locked: json["locked"] as bool? ?? false,
    );
  }
}

// Legacy support: convert old CanvasStroke to MovementArrow
class LegacyStroke extends TacticalObject {
  final List<Offset> points;
  final Color color;
  final double width;

  const LegacyStroke({
    required super.id,
    required this.points,
    required this.color,
    this.width = 3.0,
  }) : super(layer: TacticalLayerType.movement);

  @override
  void draw(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    final path = Path();
    final actualPoints = points.map((p) => Offset(
      p.dx * size.width,
      p.dy * size.height,
    )).toList();
    path.moveTo(actualPoints[0].dx, actualPoints[0].dy);
    for (int i = 1; i < actualPoints.length; i++) {
      path.lineTo(actualPoints[i].dx, actualPoints[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  TacticalObject copyWith() => this;

  @override
  Map<String, dynamic> toJson() => {};
}

// Factory for deserialization
class TacticalObjectFactory {
  static TacticalObject? fromJson(Map<String, dynamic> json) {
    final type = json["type"] as String?;
    switch (type) {
      case "PlayerMarker":
        return PlayerMarker.fromJson(json);
      case "MovementArrow":
        return MovementArrow.fromJson(json);
      case "ZoneCircle":
        return ZoneCircle.fromJson(json);
      case "TextNote":
        return TextNote.fromJson(json);
      default:
        return null;
    }
  }
}
