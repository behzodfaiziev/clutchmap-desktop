import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../domain/entities/game_type.dart';

/// Selected game type for the current team/match. DAY_126: GameContext state.
/// Use [GameContextScope] at app or feature level, then [GameContext.of] to read/update.
class GameContext extends InheritedWidget {
  const GameContext({
    super.key,
    required this.selectedGameType,
    required super.child,
  });

  final ValueNotifier<GameType?> selectedGameType;

  static GameContext of(BuildContext context) {
    final ctx = context.dependOnInheritedWidgetOfExactType<GameContext>();
    assert(ctx != null, 'No GameContext found. Wrap with GameContextScope.');
    return ctx!;
  }

  static GameContext? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GameContext>();
  }

  @override
  bool updateShouldNotify(GameContext oldWidget) {
    return selectedGameType != oldWidget.selectedGameType;
  }
}

/// Holds [GameContext] and provides [ValueNotifier<GameType?>] for selected game type.
class GameContextScope extends StatefulWidget {
  const GameContextScope({
    super.key,
    this.initialGameType,
    required this.child,
  });

  final GameType? initialGameType;
  final Widget child;

  @override
  State<GameContextScope> createState() => _GameContextScopeState();
}

class _GameContextScopeState extends State<GameContextScope> {
  late final ValueNotifier<GameType?> _selectedGameType =
      ValueNotifier<GameType?>(widget.initialGameType);

  @override
  void dispose() {
    _selectedGameType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameContext(
      selectedGameType: _selectedGameType,
      child: widget.child,
    );
  }
}
