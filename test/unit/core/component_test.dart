import 'package:test/test.dart';
import 'package:utopia_tui/utopia_tui.dart';

/// A minimal terminal implementation for testing purposes.
class _MockTerminal implements TuiTerminalInterface {
  @override
  final int width;
  @override
  final int height;

  _MockTerminal({this.width = 80, this.height = 24});

  @override
  void hideCursor() {}
  @override
  void showCursor() {}
  @override
  void clearScreen() {}
  @override
  void setCursor(int row, int col) {}
  @override
  void write(String text) {}
}

void main() {
  group('TuiComponent.paint', () {
    test('paint delegates to paintSurface with correct surface and rect', () {
      final terminal = _MockTerminal(width: 80, height: 24);
      final context = TuiContext(terminal);
      final text = TuiText('Hello');

      text.paint(context, row: 2, col: 3, width: 10, height: 5);

      // Verify that 'Hello' was painted at col=3, row=2
      expect(context.surface.getCell(3, 2).char, equals('H'));
      expect(context.surface.getCell(4, 2).char, equals('e'));
      expect(context.surface.getCell(5, 2).char, equals('l'));
      expect(context.surface.getCell(6, 2).char, equals('l'));
      expect(context.surface.getCell(7, 2).char, equals('o'));
    });

    test('paint maps row to y and col to x correctly', () {
      final terminal = _MockTerminal(width: 40, height: 20);
      final context = TuiContext(terminal);
      final text = TuiText('X');

      text.paint(context, row: 5, col: 10, width: 3, height: 1);

      // X should be at (col=10, row=5)
      expect(context.surface.getCell(10, 5).char, equals('X'));
      // Nearby cells should be cleared (spaces)
      expect(context.surface.getCell(9, 5).char, equals(' '));
    });

    test('paint works with zero-offset position', () {
      final terminal = _MockTerminal(width: 20, height: 10);
      final context = TuiContext(terminal);
      final text = TuiText('AB');

      text.paint(context, row: 0, col: 0, width: 5, height: 1);

      expect(context.surface.getCell(0, 0).char, equals('A'));
      expect(context.surface.getCell(1, 0).char, equals('B'));
    });

    test('paint works for TuiTextComponent subclasses', () {
      final terminal = _MockTerminal(width: 30, height: 10);
      final context = TuiContext(terminal);
      final text = TuiText('Line 1\nLine 2');

      text.paint(context, row: 1, col: 2, width: 10, height: 3);

      // Line 1 at row=1
      expect(context.surface.getCell(2, 1).char, equals('L'));
      // Line 2 at row=2
      expect(context.surface.getCell(2, 2).char, equals('L'));
      expect(context.surface.getCell(7, 2).char, equals('2'));
    });

    test('paint handles empty rect gracefully', () {
      final terminal = _MockTerminal(width: 20, height: 10);
      final context = TuiContext(terminal);
      final text = TuiText('Test');

      // Should not throw
      text.paint(context, row: 0, col: 0, width: 0, height: 0);
    });
  });
}
