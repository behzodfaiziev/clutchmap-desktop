import 'dart:math';
import 'package:flutter/material.dart';
import 'canvas_models.dart';

class ArrowPainter extends CustomPainter {
  final List<CanvasArrow> arrows;

  ArrowPainter(this.arrows);

  @override
  void paint(Canvas canvas, Size size) {
    for (var arrow in arrows) {
      final paint = Paint()
        ..color = arrow.color
        ..strokeWidth = arrow.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Draw arrow line
      canvas.drawLine(arrow.start, arrow.end, paint);

      // Draw arrow head
      final angle = atan2(
        arrow.end.dy - arrow.start.dy,
        arrow.end.dx - arrow.start.dx,
      );

      final arrowHeadSize = 10.0;

      final path = Path();
      path.moveTo(arrow.end.dx, arrow.end.dy);
      path.lineTo(
        arrow.end.dx - arrowHeadSize * cos(angle - pi / 6),
        arrow.end.dy - arrowHeadSize * sin(angle - pi / 6),
      );
      path.moveTo(arrow.end.dx, arrow.end.dy);
      path.lineTo(
        arrow.end.dx - arrowHeadSize * cos(angle + pi / 6),
        arrow.end.dy - arrowHeadSize * sin(angle + pi / 6),
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) {
    if (oldDelegate.arrows.length != arrows.length) {
      return true;
    }
    // Compare arrows for equality
    for (int i = 0; i < arrows.length; i++) {
      if (oldDelegate.arrows[i] != arrows[i]) {
        return true;
      }
    }
    return false;
  }
}


