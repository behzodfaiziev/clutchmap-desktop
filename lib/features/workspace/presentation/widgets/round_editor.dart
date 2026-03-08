import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/lock_status.dart';
import '../bloc/workspace_bloc.dart';
import '../bloc/workspace_event.dart';
import '../bloc/workspace_state.dart';
import 'canvas/tactical_canvas.dart';
import 'canvas/canvas_models.dart';
import 'economy_section.dart';

class RoundEditor extends StatefulWidget {
  final GlobalKey? canvasKey;
  
  const RoundEditor({super.key, this.canvasKey});

  @override
  State<RoundEditor> createState() => _RoundEditorState();
}

class _RoundEditorState extends State<RoundEditor> {
  final _notesController = TextEditingController();
  String? _currentRoundId;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkspaceBloc, WorkspaceState>(
      listener: (context, state) {
        if (state is WorkspaceLoadedState) {
          final round = state.rounds[state.selectedIndex];
          if (round.id != _currentRoundId) {
            _currentRoundId = round.id;
            _notesController.text = round.notes ?? '';
          }
        }
      },
      builder: (context, state) {
        if (state is! WorkspaceLoadedState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final round = state.rounds[state.selectedIndex];
        final lockStatus = state.getLockStatus(round.id) ?? LockStatus.empty();
        final authState = context.read<AuthBloc>().state;
        final currentUserId = authState is AuthAuthenticated
            ? authState.user.id
            : '';
        final isLocked = lockStatus.locked;
        final isLockedByCurrentUser = state.isRoundLockedByCurrentUser(round.id, currentUserId);
        final canEdit = !isLocked || isLockedByCurrentUser;
        final strokes = state.canvasStrokes[round.id] ?? [];
        final arrows = state.canvasArrows[round.id] ?? [];
        final objects = state.canvasObjects[round.id] ?? [];

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lock indicator
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      isLocked ? Icons.lock : Icons.lock_open,
                      size: 16,
                      color: isLocked ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isLocked
                          ? "Locked by ${lockStatus.lockedByUserId ?? 'Unknown'}"
                          : "You have editing access",
                      style: TextStyle(
                        fontSize: 12,
                        color: isLocked ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Round ${round.roundNumber}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Side: ${round.side}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              // Notes Editor
              Text(
                "Notes",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: TextField(
                  controller: _notesController,
                  enabled: canEdit,
                  maxLines: null,
                  expands: true,
                  style: TextStyle(
                    color: canEdit ? Colors.white : Colors.white54,
                  ),
                  decoration: InputDecoration(
                    hintText: canEdit
                        ? "Enter round strategy notes..."
                        : "Round is locked by another user",
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: canEdit
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.02),
                  ),
                  onChanged: canEdit
                      ? (value) {
                          context.read<WorkspaceBloc>().add(
                                RoundNotesUpdated(
                                  roundId: round.id,
                                  notes: value,
                                ),
                              );
                        }
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              // Economy Section
              EconomySection(
                roundId: round.id,
                buyType: state.buyTypes[round.id],
                playerBuys: state.playerBuys[round.id] ?? [],
                canEdit: canEdit,
              ),
              const SizedBox(height: 20),
              // Canvas
              Text(
                "Canvas",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _CanvasTab(
                  roundId: round.id,
                  canEdit: canEdit,
                  strokes: strokes,
                  arrows: arrows,
                  objects: objects,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CanvasTab extends StatefulWidget {
  final String roundId;
  final bool canEdit;
  final List<CanvasStroke> strokes;
  final List<CanvasArrow> arrows;
  final List<CanvasObject> objects;
  final GlobalKey? canvasKey;

  const _CanvasTab({
    required this.roundId,
    required this.canEdit,
    required this.strokes,
    required this.arrows,
    required this.objects,
    this.canvasKey,
  });

  @override
  State<_CanvasTab> createState() => _CanvasTabState();
}

class _CanvasTabState extends State<_CanvasTab> {
  late List<CanvasStroke> _strokes;
  late List<CanvasArrow> _arrows;
  late List<CanvasObject> _objects;
  Timer? _debounceTimer;
  CanvasTool _currentTool = CanvasTool.brush;
  Color _selectedColor = Colors.redAccent;

  @override
  void initState() {
    super.initState();
    _strokes = List.from(widget.strokes);
    _arrows = List.from(widget.arrows);
    _objects = List.from(widget.objects);
  }

  @override
  void didUpdateWidget(_CanvasTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.strokes != widget.strokes ||
        oldWidget.arrows != widget.arrows ||
        oldWidget.objects != widget.objects) {
      _strokes = List.from(widget.strokes);
      _arrows = List.from(widget.arrows);
      _objects = List.from(widget.objects);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _saveCanvas({
    required List<CanvasStroke> strokes,
    required List<CanvasArrow> arrows,
    required List<CanvasObject> objects,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final strokesJson = strokes.map((s) => s.toJson()).toList();
      final arrowsJson = arrows.map((a) => a.toJson()).toList();
      final objectsJson = objects.map((o) => o.toJson()).toList();
      context.read<WorkspaceBloc>().add(
            CanvasDrawingUpdated(
              roundId: widget.roundId,
              strokesJson: strokesJson,
              arrowsJson: arrowsJson,
              objectsJson: objectsJson,
            ),
          );
    });
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _arrows.clear();
      _objects.clear();
    });
    _saveCanvas(strokes: _strokes, arrows: _arrows, objects: _objects);
  }

  void _undoLast() {
    setState(() {
      if (_strokes.isNotEmpty) {
        _strokes.removeLast();
      } else if (_arrows.isNotEmpty) {
        _arrows.removeLast();
      } else if (_objects.isNotEmpty) {
        _objects.removeLast();
      }
    });
    _saveCanvas(strokes: _strokes, arrows: _arrows, objects: _objects);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        Row(
          children: [
            _ToolButton(
              icon: Icons.brush,
              tool: CanvasTool.brush,
              currentTool: _currentTool,
              onToolSelected: (tool) {
                setState(() {
                  _currentTool = tool;
                });
              },
            ),
            _ToolButton(
              icon: Icons.arrow_right_alt,
              tool: CanvasTool.arrow,
              currentTool: _currentTool,
              onToolSelected: (tool) {
                setState(() {
                  _currentTool = tool;
                });
              },
            ),
            _ToolButton(
              icon: Icons.person,
              tool: CanvasTool.icon,
              currentTool: _currentTool,
              onToolSelected: (tool) {
                setState(() {
                  _currentTool = tool;
                });
              },
            ),
            _ToolButton(
              icon: Icons.delete_outline,
              tool: CanvasTool.erase,
              currentTool: _currentTool,
              onToolSelected: (tool) {
                setState(() {
                  _currentTool = tool;
                });
              },
            ),
            const SizedBox(width: 16),
            _ColorPicker(
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white70),
              onPressed: widget.canEdit ? _clearCanvas : null,
              tooltip: 'Clear',
            ),
            IconButton(
              icon: const Icon(Icons.undo, color: Colors.white70),
              onPressed: widget.canEdit ? _undoLast : null,
              tooltip: 'Undo',
            ),
            if (!widget.canEdit)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  "Canvas is locked",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        // Canvas
        Expanded(
          child: TacticalCanvas(
            strokes: _strokes,
            arrows: _arrows,
            objects: _objects,
            enabled: widget.canEdit,
            currentTool: _currentTool,
            selectedColor: _selectedColor,
            onChanged: widget.canEdit
                ? ({required strokes, required arrows, required objects}) {
                    setState(() {
                      _strokes = strokes;
                      _arrows = arrows;
                      _objects = objects;
                    });
                    _saveCanvas(
                      strokes: strokes,
                      arrows: arrows,
                      objects: objects,
                    );
                  }
                : ({required strokes, required arrows, required objects}) {},
          ),
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final CanvasTool tool;
  final CanvasTool currentTool;
  final Function(CanvasTool) onToolSelected;

  const _ToolButton({
    required this.icon,
    required this.tool,
    required this.currentTool,
    required this.onToolSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentTool == tool;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white70,
      ),
      onPressed: () => onToolSelected(tool),
      style: IconButton.styleFrom(
        backgroundColor: isSelected ? Colors.white.withValues(alpha: 0.2) : null,
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final Function(Color) onColorSelected;

  const _ColorPicker({
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.yellowAccent,
      Colors.purpleAccent,
    ];

    return Row(
      children: colors.map((color) {
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedColor == color ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
