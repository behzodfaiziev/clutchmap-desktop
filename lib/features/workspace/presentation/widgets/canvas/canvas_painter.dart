import 'package:flutter/material.dart';
import 'canvas_models.dart';

class CanvasPainter extends CustomPainter {
  final List<CanvasStroke> strokes;

  CanvasPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (var stroke in strokes) {
      if (stroke.points.length < 2) continue;

      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(
          stroke.points[i],
          stroke.points[i + 1],
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    if (oldDelegate.strokes.length != strokes.length) {
      return true;
    }
    // Compare strokes for equality
    for (int i = 0; i < strokes.length; i++) {
      if (oldDelegate.strokes[i] != strokes[i]) {
        return true;
      }
    }
    return false;
  }
}


