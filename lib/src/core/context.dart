import 'terminal.dart';
import 'canvas.dart';
import 'rect.dart';

/// Build context that uses a cell-based surface for rendering
class TuiContext {
  final TuiTerminalInterface terminal;
  late final int width;
  late final int height;
  late final TuiSurface _surface;

  TuiContext(this.terminal) {
    width = terminal.width;
    height = terminal.height;
    _surface = TuiSurface(width: width, height: height);
  }

  /// Get the main surface for painting
  TuiSurface get surface => _surface;

  /// Get the full screen rect
  TuiRect get rect => TuiRect(x: 0, y: 0, width: width, height: height);

  /// Clear the surface to empty cells
  void clear() {
    _surface.clear();
  }

  /// Get lines for terminal output
  List<String> snapshot() {
    return _surface.toAnsiLines();
  }

  /// Get styled lines for terminal output (same as snapshot for surface-based)
  List<String> snapshotStyled() {
    return _surface.toAnsiLines();
  }
}
