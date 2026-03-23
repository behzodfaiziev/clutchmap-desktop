import 'package:flutter/material.dart';
import 'tactical_object.dart';

class TacticalBoardPainter extends CustomPainter {
  final List<TacticalObject> objects;
  final String? selectedObjectId;

  TacticalBoardPainter({
    required this.objects,
    this.selectedObjectId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Render by layer order
    for (var layer in TacticalLayerType.values) {
      final layerObjects = objects.where((o) => o.layer == layer).toList();
      
      for (var obj in layerObjects) {
        if (!obj.locked) {
          obj.draw(canvas, size);
        }
      }
    }

    // Draw selection highlight
    if (selectedObjectId != null) {
      final selected = objects.firstWhere(
        (o) => o.id == selectedObjectId,
        orElse: () => objects.first,
      );
      
      if (selected.id == selectedObjectId) {
        _drawSelectionHighlight(canvas, size, selected);
      }
    }
  }

  void _drawSelectionHighlight(Canvas canvas, Size size, TacticalObject obj) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (obj is PlayerMarker) {
      final actualPosition = Offset(
        obj.position.dx * size.width,
        obj.position.dy * size.height,
      );
      canvas.drawCircle(actualPosition, obj.size / 2 + 4, paint);
    } else if (obj is ZoneCircle) {
      final actualCenter = Offset(
        obj.center.dx * size.width,
        obj.center.dy * size.height,
      );
      final actualRadius = obj.radius * (size.width + size.height) / 2;
      canvas.drawCircle(actualCenter, actualRadius + 4, paint);
    }
  }

  @override
  bool shouldRepaint(TacticalBoardPainter oldDelegate) {
    return oldDelegate.objects != objects ||
        oldDelegate.selectedObjectId != selectedObjectId;
  }
}
