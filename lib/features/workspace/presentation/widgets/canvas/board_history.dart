import 'tactical_object.dart';

class BoardHistory {
  final List<List<TacticalObject>> undoStack;
  final List<List<TacticalObject>> redoStack;
  final int maxStackSize;

  BoardHistory({this.maxStackSize = 50})
      : undoStack = [],
        redoStack = [];

  void pushState(List<TacticalObject> state) {
    // Deep copy the state
    final stateCopy = state.map((obj) => obj.copyWith()).toList();
    
    undoStack.add(stateCopy);
    if (undoStack.length > maxStackSize) {
      undoStack.removeAt(0);
    }
    
    // Clear redo stack on new action
    redoStack.clear();
  }

  List<TacticalObject>? undo(List<TacticalObject> current) {
    if (undoStack.isEmpty) return null;
    
    // Save current state to redo
    final currentCopy = current.map((obj) => obj.copyWith()).toList();
    redoStack.add(currentCopy);
    if (redoStack.length > maxStackSize) {
      redoStack.removeAt(0);
    }
    
    return undoStack.removeLast();
  }

  List<TacticalObject>? redo(List<TacticalObject> current) {
    if (redoStack.isEmpty) return null;
    
    // Save current state to undo
    final currentCopy = current.map((obj) => obj.copyWith()).toList();
    undoStack.add(currentCopy);
    if (undoStack.length > maxStackSize) {
      undoStack.removeAt(0);
    }
    
    return redoStack.removeLast();
  }

  bool canUndo() => undoStack.isNotEmpty;
  bool canRedo() => redoStack.isNotEmpty;

  void clear() {
    undoStack.clear();
    redoStack.clear();
  }
}
