import 'terminal.dart';
import 'canvas.dart';
import 'rect.dart';

/// Build context that provides access to terminal state and rendering surface.
///
/// The [TuiContext] is passed to applications during the build phase and
/// provides access to:
/// - Terminal dimensions ([width], [height])
/// - Main rendering surface ([surface])
/// - Utility methods for clearing and capturing output
///
/// ## Usage
///
/// ```dart
/// void build(TuiContext context) {
///   context.surface.putText(0, 0, 'Hello World');
///   // or use the rect property
///   final fullScreen = context.rect;
/// }
/// ```
class TuiContext {
  /// The underlying terminal interface.
  final TuiTerminalInterface terminal;

  /// Width of the terminal in characters.
  late final int width;

  /// Height of the terminal in characters.
  late final int height;

  late final TuiSurface _surface;

  /// Creates a new context for the given [terminal].
  ///
  /// The context will query the terminal for its current dimensions
  /// and create an appropriately sized rendering surface.
  TuiContext(this.terminal) {
    width = terminal.width;
    height = terminal.height;
    _surface = TuiSurface(width: width, height: height);
  }

  /// The main rendering surface for painting UI elements.
  ///
  /// Use this surface to draw text, apply styles, and render components.
  /// The surface automatically handles ANSI escape sequences and styling.
  TuiSurface get surface => _surface;

  /// A rectangle representing the full terminal screen.
  ///
  /// Equivalent to `TuiRect(x: 0, y: 0, width: width, height: height)`.
  /// Useful for components that need to fill the entire screen.
  TuiRect get rect => TuiRect(x: 0, y: 0, width: width, height: height);

  /// Clears the entire surface to empty cells.
  ///
  /// This resets all characters to spaces and removes all styling.
  void clear() {
    _surface.clear();
  }

  /// Captures the current surface content as ANSI-formatted strings.
  ///
  /// Returns a list of strings, one per terminal row, with ANSI escape
  /// sequences for styling and colors.
  /// Captures the current surface content as ANSI-formatted strings.
  ///
  /// Returns a list of strings, one per terminal row, with ANSI escape
  /// sequences for styling and colors.
  List<String> snapshot() {
    return _surface.toAnsiLines();
  }

  /// Captures the current surface content as styled strings.
  ///
  /// This is an alias for [snapshot] since the surface already includes
  /// styling information in its ANSI output.
  List<String> snapshotStyled() {
    return _surface.toAnsiLines();
  }
}
