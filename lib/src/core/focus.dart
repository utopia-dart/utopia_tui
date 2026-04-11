import 'interactive.dart';
import 'canvas.dart';
import 'rect.dart';
import 'events.dart';

enum FocusDirection { up, down, left, right }

/// A focusable placeholder that doesn't consume input.
/// Use in focus trees where a pane should be focusable for visual
/// highlighting but has no interactive component.
class TuiFocusPlaceholder extends TuiInteractiveComponent {
  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {}
}

sealed class TuiFocusNode {
  final String? id;

  const TuiFocusNode({this.id});

  factory TuiFocusNode.leaf({
    String? id,
    required TuiInteractiveComponent component,
  }) = TuiFocusLeaf;

  factory TuiFocusNode.row({String? id, required List<TuiFocusNode> children}) =
      _TuiFocusGroup.horizontal;

  factory TuiFocusNode.column({
    String? id,
    required List<TuiFocusNode> children,
  }) = _TuiFocusGroup.vertical;
}

class TuiFocusLeaf extends TuiFocusNode {
  final TuiInteractiveComponent component;

  const TuiFocusLeaf({super.id, required this.component});
}

class _TuiFocusGroup extends TuiFocusNode {
  final List<TuiFocusNode> children;
  final bool horizontal;

  const _TuiFocusGroup.horizontal({super.id, required this.children})
    : horizontal = true;

  const _TuiFocusGroup.vertical({super.id, required this.children})
    : horizontal = false;
}

class TuiFocusManager {
  TuiFocusNode root;
  final List<int> _path = [];

  TuiFocusManager({required this.root}) {
    _path.addAll(_firstLeafPath(root));
    _syncFocus();
  }

  TuiFocusLeaf? get focusedNode {
    final node = _nodeAtPath(_path);
    return node is TuiFocusLeaf ? node : null;
  }

  TuiInteractiveComponent? get focusedComponent => focusedNode?.component;

  String? get focusedId {
    final node = _nodeAtPath(_path);
    return node?.id;
  }

  bool move(FocusDirection direction) {
    final newPath = _tryMove(_path, root, direction);
    if (newPath != null) {
      _path
        ..clear()
        ..addAll(newPath);
      _syncFocus();
      return true;
    }
    return false;
  }

  void focusNext() => _cycle(1);

  void focusPrev() => _cycle(-1);

  void focusById(String id) {
    final path = _findById(root, id, []);
    if (path != null) {
      _path
        ..clear()
        ..addAll(path);
      _syncFocus();
    }
  }

  bool handleInput(TuiEvent event) {
    final comp = focusedComponent;
    if (comp != null && comp.focused) {
      return comp.handleInput(event);
    }
    return false;
  }

  void _syncFocus() {
    _setAllFocus(root, false);
    final comp = focusedComponent;
    if (comp != null) comp.setFocus(true);
  }

  void _setAllFocus(TuiFocusNode node, bool value) {
    switch (node) {
      case TuiFocusLeaf(:final component):
        component.setFocus(value);
      case _TuiFocusGroup(:final children):
        for (final child in children) {
          _setAllFocus(child, value);
        }
    }
  }

  // --- Path navigation ---

  TuiFocusNode? _nodeAtPath(List<int> path) {
    TuiFocusNode current = root;
    for (final idx in path) {
      if (current is _TuiFocusGroup) {
        if (idx < 0 || idx >= current.children.length) return null;
        current = current.children[idx];
      } else {
        return null;
      }
    }
    return current;
  }

  List<int> _firstLeafPath(TuiFocusNode node) {
    switch (node) {
      case TuiFocusLeaf():
        return [];
      case _TuiFocusGroup(:final children):
        if (children.isEmpty) return [];
        return [0, ..._firstLeafPath(children.first)];
    }
  }

  List<int> _lastLeafPath(TuiFocusNode node) {
    switch (node) {
      case TuiFocusLeaf():
        return [];
      case _TuiFocusGroup(:final children):
        if (children.isEmpty) return [];
        return [children.length - 1, ..._lastLeafPath(children.last)];
    }
  }

  List<int>? _tryMove(
    List<int> path,
    TuiFocusNode root,
    FocusDirection direction,
  ) {
    if (path.isEmpty) return null;

    final parentPath = path.sublist(0, path.length - 1);
    final currentIdx = path.last;
    final parent = _nodeAtPath(parentPath);

    if (parent is! _TuiFocusGroup) return null;

    final isAligned = _isAligned(parent.horizontal, direction);

    if (isAligned) {
      final delta = _delta(direction);
      final nextIdx = currentIdx + delta;
      if (nextIdx >= 0 && nextIdx < parent.children.length) {
        final target = parent.children[nextIdx];
        final subPath = delta > 0
            ? _firstLeafPath(target)
            : _lastLeafPath(target);
        return [...parentPath, nextIdx, ...subPath];
      }
    }

    if (parentPath.isEmpty) return null;
    return _tryMove(parentPath, root, direction);
  }

  bool _isAligned(bool horizontal, FocusDirection direction) {
    if (horizontal) {
      return direction == FocusDirection.left ||
          direction == FocusDirection.right;
    }
    return direction == FocusDirection.up || direction == FocusDirection.down;
  }

  int _delta(FocusDirection direction) {
    return (direction == FocusDirection.down ||
            direction == FocusDirection.right)
        ? 1
        : -1;
  }

  // --- Cycle ---

  void _cycle(int direction) {
    final leaves = <List<int>>[];
    _collectLeaves(root, [], leaves);
    if (leaves.isEmpty) return;

    final currentStr = _path.toString();
    var idx = leaves.indexWhere((p) => p.toString() == currentStr);
    if (idx < 0) idx = 0;

    idx = (idx + direction) % leaves.length;
    if (idx < 0) idx += leaves.length;

    _path
      ..clear()
      ..addAll(leaves[idx]);
    _syncFocus();
  }

  void _collectLeaves(
    TuiFocusNode node,
    List<int> prefix,
    List<List<int>> out,
  ) {
    switch (node) {
      case TuiFocusLeaf():
        out.add(List.of(prefix));
      case _TuiFocusGroup(:final children):
        for (var i = 0; i < children.length; i++) {
          _collectLeaves(children[i], [...prefix, i], out);
        }
    }
  }

  // --- Find by ID ---

  List<int>? _findById(TuiFocusNode node, String id, List<int> prefix) {
    if (node.id == id) {
      switch (node) {
        case TuiFocusLeaf():
          return List.of(prefix);
        case _TuiFocusGroup():
          return [...prefix, ..._firstLeafPath(node)];
      }
    }
    if (node is _TuiFocusGroup) {
      for (var i = 0; i < node.children.length; i++) {
        final result = _findById(node.children[i], id, [...prefix, i]);
        if (result != null) return result;
      }
    }
    return null;
  }
}
