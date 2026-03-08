import 'package:flutter/material.dart';
import 'canvas_models.dart';
import 'canvas_painter.dart';
import 'arrow_painter.dart';

class TacticalCanvas extends StatefulWidget {
  final List<CanvasStroke> strokes;
  final List<CanvasArrow> arrows;
  final List<CanvasObject> objects;
  final Function({
    required List<CanvasStroke> strokes,
    required List<CanvasArrow> arrows,
    required List<CanvasObject> objects,
  }) onChanged;
  final String? mapImagePath;
  final bool enabled;
  final CanvasTool currentTool;
  final Color selectedColor;

  const TacticalCanvas({
    super.key,
    required this.strokes,
    required this.arrows,
    required this.objects,
    required this.onChanged,
    this.mapImagePath,
    this.enabled = true,
    this.currentTool = CanvasTool.brush,
    this.selectedColor = Colors.redAccent,
  });

  @override
  State<TacticalCanvas> createState() => _TacticalCanvasState();
}

class _TacticalCanvasState extends State<TacticalCanvas> {
  late List<CanvasStroke> strokes;
  late List<CanvasArrow> arrows;
  late List<CanvasObject> objects;
  List<Offset> currentPoints = [];
  Offset? arrowStart;
  String? draggedObjectId;

  @override
  void initState() {
    super.initState();
    strokes = List.from(widget.strokes);
    arrows = List.from(widget.arrows);
    objects = List.from(widget.objects);
  }

  @override
  void didUpdateWidget(TacticalCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.strokes != widget.strokes ||
        oldWidget.arrows != widget.arrows ||
        oldWidget.objects != widget.objects) {
      strokes = List.from(widget.strokes);
      arrows = List.from(widget.arrows);
      objects = List.from(widget.objects);
    }
  }

  void _notifyChange() {
    widget.onChanged(
      strokes: strokes,
      arrows: arrows,
      objects: objects,
    );
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.enabled) return;

    final position = details.localPosition;

    if (widget.currentTool == CanvasTool.brush) {
      setState(() {
        currentPoints = [position];
      });
    } else if (widget.currentTool == CanvasTool.arrow) {
      setState(() {
        arrowStart = position;
      });
    } else if (widget.currentTool == CanvasTool.icon) {
      // Add new icon at tap position
      setState(() {
        objects.add(
          CanvasObject(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            position: position,
            type: "ATTACKER",
          ),
        );
        _notifyChange();
      });
    } else if (widget.currentTool == CanvasTool.erase) {
      // Find and remove object at position
      final objectToRemove = objects.firstWhere(
        (obj) => (obj.position - position).distance < 20,
        orElse: () => CanvasObject(
          id: '',
          position: Offset.zero,
          type: '',
        ),
      );
      if (objectToRemove.id.isNotEmpty) {
        setState(() {
          objects.removeWhere((obj) => obj.id == objectToRemove.id);
          _notifyChange();
        });
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;

    final position = details.localPosition;

    if (widget.currentTool == CanvasTool.brush) {
      setState(() {
        currentPoints.add(position);
      });
    } else if (widget.currentTool == CanvasTool.arrow && arrowStart != null) {
      // Arrow preview is handled in build
    } else if (widget.currentTool == CanvasTool.icon) {
      // Drag existing object
      final object = objects.firstWhere(
        (obj) => (obj.position - position).distance < 20,
        orElse: () => CanvasObject(
          id: '',
          position: Offset.zero,
          type: '',
        ),
      );
      if (object.id.isNotEmpty && draggedObjectId == null) {
        draggedObjectId = object.id;
      }
      if (draggedObjectId != null) {
        setState(() {
          final index = objects.indexWhere((obj) => obj.id == draggedObjectId);
          if (index != -1) {
            objects[index].position = position;
          }
        });
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enabled) return;

    if (widget.currentTool == CanvasTool.brush && currentPoints.length > 1) {
      setState(() {
        strokes.add(
          CanvasStroke(
            points: List.from(currentPoints),
            color: widget.selectedColor,
            width: 3,
          ),
        );
        _notifyChange();
        currentPoints = [];
      });
    } else if (widget.currentTool == CanvasTool.arrow && arrowStart != null) {
      setState(() {
        arrows.add(
          CanvasArrow(
            start: arrowStart!,
            end: details.localPosition,
            color: widget.selectedColor,
            width: 3,
          ),
        );
        _notifyChange();
        arrowStart = null;
      });
    } else if (widget.currentTool == CanvasTool.icon) {
      setState(() {
        _notifyChange();
        draggedObjectId = null;
      });
    }
  }

  void clearCanvas() {
    setState(() {
      strokes.clear();
      arrows.clear();
      objects.clear();
      currentPoints.clear();
      arrowStart = null;
      _notifyChange();
    });
  }

  void undoLast() {
    setState(() {
      if (strokes.isNotEmpty) {
        strokes.removeLast();
      } else if (arrows.isNotEmpty) {
        arrows.removeLast();
      } else if (objects.isNotEmpty) {
        objects.removeLast();
      }
      _notifyChange();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allStrokes = [
      ...strokes,
      if (currentPoints.length > 1)
        CanvasStroke(
          points: List.from(currentPoints),
          color: widget.selectedColor,
          width: 3,
        ),
    ];

    final allArrows = [
      ...arrows,
      if (arrowStart != null)
        CanvasArrow(
          start: arrowStart!,
          end: arrowStart!,
          color: widget.selectedColor,
          width: 3,
        ),
    ];

    Widget canvasWidget = Stack(
      children: [
        // Layer 1: Strokes
        RepaintBoundary(
          child: CustomPaint(
            painter: CanvasPainter(allStrokes),
            size: Size.infinite,
            child: Container(),
          ),
        ),
        // Layer 2: Arrows
        RepaintBoundary(
          child: CustomPaint(
            painter: ArrowPainter(allArrows),
            size: Size.infinite,
            child: Container(),
          ),
        ),
        // Layer 3: Objects
        ...objects.map((obj) {
          return Positioned(
            left: obj.position.dx - 12,
            top: obj.position.dy - 12,
            child: GestureDetector(
              onPanUpdate: widget.enabled && widget.currentTool == CanvasTool.icon
                  ? (details) {
                      setState(() {
                        obj.position += details.delta;
                        _notifyChange();
                      });
                    }
                  : null,
              child: Icon(
                Icons.circle,
                size: 24,
                color: obj.type == "ATTACKER"
                    ? Colors.redAccent
                    : Colors.blueAccent,
              ),
            ),
          );
        }),
      ],
    );

    final gestureDetector = GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: canvasWidget,
    );

    if (widget.mapImagePath != null) {
      return Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              widget.mapImagePath!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade900,
                  child: const Center(
                    child: Text(
                      "Map image not found",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned.fill(child: gestureDetector),
        ],
      );
    }

    return Container(
      color: Colors.grey.shade900,
      child: gestureDetector,
    );
  }
}
