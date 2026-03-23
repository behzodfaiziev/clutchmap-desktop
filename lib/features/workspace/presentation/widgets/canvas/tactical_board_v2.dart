import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'tactical_object.dart';
import 'tactical_board_painter.dart';
import 'board_history.dart';

enum TacticalTool {
  select,
  arrow,
  circle,
  text,
  player,
  brush, // legacy support
}

class TacticalBoardV2 extends StatefulWidget {
  final List<TacticalObject> objects;
  final Function(List<TacticalObject>) onChanged;
  final String? mapImagePath;
  final bool enabled;
  final TacticalTool currentTool;
  final Color selectedColor;
  final GlobalKey? repaintKey;

  const TacticalBoardV2({
    super.key,
    required this.objects,
    required this.onChanged,
    this.mapImagePath,
    this.enabled = true,
    this.currentTool = TacticalTool.select,
    this.selectedColor = Colors.redAccent,
    this.repaintKey,
  });

  @override
  State<TacticalBoardV2> createState() => _TacticalBoardV2State();
}

class _TacticalBoardV2State extends State<TacticalBoardV2> {
  late List<TacticalObject> objects;
  late BoardHistory history;
  String? selectedObjectId;
  Offset? dragStart;
  List<Offset>? currentPath;
  Size? canvasSize;

  @override
  void initState() {
    super.initState();
    objects = List.from(widget.objects);
    history = BoardHistory();
  }

  @override
  void didUpdateWidget(TacticalBoardV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.objects != widget.objects) {
      objects = List.from(widget.objects);
    }
  }

  Offset _normalizePosition(Offset position) {
    if (canvasSize == null) return position;
    return Offset(
      position.dx / canvasSize!.width,
      position.dy / canvasSize!.height,
    );
  }

  Offset _denormalizePosition(Offset normalized) {
    if (canvasSize == null) return normalized;
    return Offset(
      normalized.dx * canvasSize!.width,
      normalized.dy * canvasSize!.height,
    );
  }

  void _notifyChange() {
    widget.onChanged(List.from(objects));
  }

  void _saveState() {
    history.pushState(List.from(objects));
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.enabled) return;

    final position = details.localPosition;
    final normalized = _normalizePosition(position);

    switch (widget.currentTool) {
      case TacticalTool.select:
        _handleSelect(position);
        break;
      case TacticalTool.arrow:
        dragStart = normalized;
        currentPath = [normalized];
        break;
      case TacticalTool.circle:
        dragStart = normalized;
        break;
      case TacticalTool.text:
        _addTextNote(normalized);
        break;
      case TacticalTool.player:
        _addPlayerMarker(normalized);
        break;
      case TacticalTool.brush:
        currentPath = [normalized];
        break;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;

    final position = details.localPosition;
    final normalized = _normalizePosition(position);

    switch (widget.currentTool) {
      case TacticalTool.select:
        if (selectedObjectId != null && dragStart != null) {
          _moveSelectedObject(normalized);
        }
        break;
      case TacticalTool.arrow:
        if (currentPath != null) {
          setState(() {
            currentPath!.add(normalized);
          });
        }
        break;
      case TacticalTool.circle:
        // Preview handled in build
        break;
      case TacticalTool.text:
      case TacticalTool.player:
      case TacticalTool.brush:
        if (currentPath != null) {
          setState(() {
            currentPath!.add(normalized);
          });
        }
        break;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enabled) return;

    final position = details.localPosition;
    final normalized = _normalizePosition(position);

    switch (widget.currentTool) {
      case TacticalTool.select:
        dragStart = null;
        break;
      case TacticalTool.arrow:
        if (currentPath != null && currentPath!.length >= 2) {
          _saveState();
          setState(() {
            objects.add(
              MovementArrow(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                points: List.from(currentPath!),
                color: widget.selectedColor,
              ),
            );
            currentPath = null;
            _notifyChange();
          });
        }
        break;
      case TacticalTool.circle:
        if (dragStart != null) {
          _saveState();
          final radius = (normalized - dragStart!).distance;
          setState(() {
            objects.add(
              ZoneCircle(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                center: dragStart!,
                radius: radius,
                fill: widget.selectedColor,
              ),
            );
            dragStart = null;
            _notifyChange();
          });
        }
        break;
      case TacticalTool.text:
      case TacticalTool.player:
      case TacticalTool.brush:
        currentPath = null;
        break;
    }
  }

  void _handleSelect(Offset position) {
    // Find object at position
    TacticalObject? hitObject;
    double minDistance = double.infinity;

    for (var obj in objects.reversed) {
      if (obj.locked) continue;

      double? distance;
      if (obj is PlayerMarker) {
        final actualPos = _denormalizePosition(obj.position);
        distance = (position - actualPos).distance;
        if (distance < obj.size / 2) {
          if (distance < minDistance) {
            minDistance = distance;
            hitObject = obj;
          }
        }
      } else if (obj is ZoneCircle) {
        final actualCenter = _denormalizePosition(obj.center);
        final actualRadius = obj.radius * (canvasSize?.width ?? 1);
        distance = (position - actualCenter).distance;
        if (distance < actualRadius) {
          if (distance < minDistance) {
            minDistance = distance;
            hitObject = obj;
          }
        }
      }
    }

    setState(() {
      selectedObjectId = hitObject?.id;
      if (hitObject != null) {
        dragStart = position;
      }
    });
  }

  void _moveSelectedObject(Offset normalized) {
    if (selectedObjectId == null) return;

    setState(() {
      final index = objects.indexWhere((o) => o.id == selectedObjectId);
      if (index != -1) {
        final obj = objects[index];
        if (obj is PlayerMarker) {
          objects[index] = obj.copyWith(position: normalized) as PlayerMarker;
        } else if (obj is ZoneCircle) {
          objects[index] = obj.copyWith(center: normalized) as ZoneCircle;
        } else if (obj is TextNote) {
          objects[index] = obj.copyWith(position: normalized) as TextNote;
        }
        _notifyChange();
      }
    });
  }

  void _addPlayerMarker(Offset normalized) {
    _saveState();
    setState(() {
      objects.add(
        PlayerMarker(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          position: normalized,
          label: "P${objects.whereType<PlayerMarker>().length + 1}",
          color: widget.selectedColor,
        ),
      );
      _notifyChange();
    });
  }

  void _addTextNote(Offset normalized) {
    _saveState();
    setState(() {
      objects.add(
        TextNote(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          position: normalized,
          text: "Note",
          color: widget.selectedColor,
        ),
      );
      _notifyChange();
    });
  }

  void undo() {
    final previous = history.undo(objects);
    if (previous != null) {
      setState(() {
        objects = previous;
        selectedObjectId = null;
        _notifyChange();
      });
    }
  }

  void redo() {
    final next = history.redo(objects);
    if (next != null) {
      setState(() {
        objects = next;
        selectedObjectId = null;
        _notifyChange();
      });
    }
  }

  void clearBoard() {
    _saveState();
    setState(() {
      objects.clear();
      selectedObjectId = null;
      _notifyChange();
    });
  }

  void deleteSelected() {
    if (selectedObjectId == null) return;
    _saveState();
    setState(() {
      objects.removeWhere((o) => o.id == selectedObjectId);
      selectedObjectId = null;
      _notifyChange();
    });
  }

  Future<Uint8List>? exportBoardImage() {
    if (widget.repaintKey?.currentContext == null) return null;

    final boundary = widget.repaintKey!.currentContext!.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;

    return boundary.toImage(pixelRatio: 3.0).then((image) {
      return image.toByteData(format: ui.ImageByteFormat.png)
          .then((byteData) => byteData!.buffer.asUint8List());
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

        final allObjects = [
          ...objects,
          if (currentPath != null && currentPath!.length > 1)
            MovementArrow(
              id: "preview",
              points: List.from(currentPath!),
              color: widget.selectedColor.withOpacity(0.5),
            ),
          if (dragStart != null && widget.currentTool == TacticalTool.circle)
            ZoneCircle(
              id: "preview",
              center: dragStart!,
              radius: currentPath != null && currentPath!.isNotEmpty
                  ? (currentPath!.last - dragStart!).distance
                  : 0.05,
              fill: widget.selectedColor.withOpacity(0.3),
            ),
        ];

        Widget canvasWidget = RepaintBoundary(
          key: widget.repaintKey,
          child: CustomPaint(
            painter: TacticalBoardPainter(
              objects: allObjects,
              selectedObjectId: selectedObjectId,
            ),
            size: canvasSize!,
            child: Container(),
          ),
        );

        // Handle keyboard shortcuts
        final gestureDetector = GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onTapDown: widget.currentTool == TacticalTool.select
              ? (details) => _handleSelect(details.localPosition)
              : null,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.keyZ &&
                    (HardwareKeyboard.instance.isMetaPressed ||
                        HardwareKeyboard.instance.isControlPressed)) {
                  if (HardwareKeyboard.instance.isShiftPressed) {
                    redo();
                  } else {
                    undo();
                  }
                } else if (event.logicalKey == LogicalKeyboardKey.delete ||
                    event.logicalKey == LogicalKeyboardKey.backspace) {
                  deleteSelected();
                }
              }
            },
            child: canvasWidget,
          ),
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
      },
    );
  }
}
