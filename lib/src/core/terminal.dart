import 'dart:io';

/// Minimal terminal abstraction using dart:io directly.
abstract class TuiTerminalInterface {
  int get width;
  int get height;

  void hideCursor();
  void showCursor();
  void clearScreen();
  void setCursor(int row, int col);
  void write(String text);
  void resetRawMode() {}
}

class TuiTerminal implements TuiTerminalInterface {
  @override
  int get width => stdout.terminalColumns;

  @override
  int get height => stdout.terminalLines;

  @override
  void hideCursor() => stdout.write('\x1b[?25l');

  @override
  void showCursor() => stdout.write('\x1b[?25h');

  @override
  void clearScreen() => stdout.write('\x1b[2J\x1b[H');

  @override
  void setCursor(int row, int col) =>
      stdout.write('\x1b[${row + 1};${col + 1}H');

  @override
  void write(String text) => stdout.write(text);

  @override
  void resetRawMode() {
    try {
      stdin.lineMode = true;
      stdin.echoMode = true;
    } catch (_) {}
  }
}
