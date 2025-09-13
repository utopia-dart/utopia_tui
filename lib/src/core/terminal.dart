import 'package:dart_console/dart_console.dart' as dc;

/// Minimal terminal abstraction so utopia_tui is not tightly coupled to
/// dart_console APIs.
abstract class TuiTerminalInterface {
  int get width;
  int get height;

  void hideCursor();
  void showCursor();
  void clearScreen();
  void setCursor(int row, int col);
  void write(String text);
}

class TuiTerminal implements TuiTerminalInterface {
  final dc.Console _console = dc.Console();

  @override
  int get width => _console.windowWidth;

  @override
  int get height => _console.windowHeight;

  @override
  void hideCursor() => _console.hideCursor();

  @override
  void showCursor() => _console.showCursor();

  @override
  void clearScreen() => _console.clearScreen();

  @override
  void setCursor(int row, int col) =>
      _console.cursorPosition = dc.Coordinate(row, col);

  @override
  void write(String text) => _console.write(text);
}
