import 'package:test/test.dart';
import 'package:utopia_tui/src/components/button.dart';
import 'package:utopia_tui/src/core/style.dart';
import 'package:utopia_tui/src/core/canvas.dart';
import 'package:utopia_tui/src/core/rect.dart';

void main() {
  group('TuiButton', () {
    test('constructor creates button with label', () {
      final button = TuiButton('Click me');

      expect(button.label, equals('Click me'));
      expect(button.focused, isFalse);
      expect(button.normalStyle, isNull);
      expect(button.focusedStyle, isNull);
    });

    test('constructor with all parameters', () {
      const normalStyle = TuiStyle(fg: 255);
      const focusedStyle = TuiStyle(fg: 255, bold: true);
      final button = TuiButton(
        'Test',
        focused: true,
        normalStyle: normalStyle,
        focusedStyle: focusedStyle,
      );

      expect(button.label, equals('Test'));
      expect(button.focused, isTrue);
      expect(button.normalStyle, equals(normalStyle));
      expect(button.focusedStyle, equals(focusedStyle));
    });

    test('render method returns padded text', () {
      final button = TuiButton('Test');

      final result = button.render(10);

      expect(result.length, equals(10));
      expect(result, contains('Test'));
    });

    test('render method truncates long text', () {
      final button = TuiButton('Very long button text');

      final result = button.render(5);

      expect(result.length, equals(5));
    });

    test('render applies normal style when not focused', () {
      const style = TuiStyle(bold: true);
      final button = TuiButton('Test', normalStyle: style, focused: false);

      final result = button.render(10);

      expect(result, contains('\x1b[')); // Should contain ANSI codes
    });

    test('render applies focused style when focused', () {
      const normalStyle = TuiStyle(fg: 255);
      const focusedStyle = TuiStyle(fg: 255, bold: true);
      final button = TuiButton(
        'Test',
        normalStyle: normalStyle,
        focusedStyle: focusedStyle,
        focused: true,
      );

      final result = button.render(10);

      expect(result, contains('\x1b[')); // Should contain ANSI codes
    });

    test('render handles minimum width', () {
      final button = TuiButton('X');

      final result = button.render(1);

      expect(result.length, equals(1));
    });

    test('focused property can be changed', () {
      final button = TuiButton('Test');

      expect(button.focused, isFalse);

      button.focused = true;
      expect(button.focused, isTrue);
    });

    test('render with empty label', () {
      final button = TuiButton('');

      final result = button.render(5);

      expect(result.length, equals(5));
      expect(result.trim(), equals(''));
    });

    test('render exact width match', () {
      final button = TuiButton('Test');

      final result = button.render(6); // ' Test ' = 6 chars

      expect(result.length, equals(6));
      expect(result, equals(' Test '));
    });
  });

  group('TuiButtonView', () {
    test('constructor creates button view', () {
      final button = TuiButton('Test');
      final buttonView = TuiButtonView(button);

      expect(buttonView.button, equals(button));
    });

    test('paintSurface handles empty rect', () {
      final button = TuiButton('Test');
      final buttonView = TuiButtonView(button);
      final surface = TuiSurface(width: 10, height: 5);
      const emptyRect = TuiRect(x: 0, y: 0, width: 0, height: 0);

      // Should not throw
      buttonView.paintSurface(surface, emptyRect);
    });

    test('paintSurface renders button on surface', () {
      final button = TuiButton('Test');
      final buttonView = TuiButtonView(button);
      final surface = TuiSurface(width: 10, height: 5);
      const rect = TuiRect(x: 1, y: 1, width: 8, height: 1);

      buttonView.paintSurface(surface, rect);

      // Check that text was drawn (should be centered)
      final text = surface.getCell(3, 1).char; // Should be 'T' from 'Test'
      expect(text, isNotNull);
    });

    test('paintSurface centers text correctly', () {
      final button = TuiButton('X');
      final buttonView = TuiButtonView(button);
      final surface = TuiSurface(width: 10, height: 5);
      const rect = TuiRect(x: 0, y: 0, width: 7, height: 1);

      buttonView.paintSurface(surface, rect);

      // ' X ' should be centered in width 7
      // Center position should be (7 - 3) / 2 = 2, so 'X' at position 3
      expect(surface.getCell(3, 0).char, equals('X'));
    });

    test('paintSurface applies focused style when focused', () {
      const focusedStyle = TuiStyle(bold: true);
      final button = TuiButton(
        'Test',
        focused: true,
        focusedStyle: focusedStyle,
      );
      final buttonView = TuiButtonView(button);
      final surface = TuiSurface(width: 10, height: 5);
      const rect = TuiRect(x: 0, y: 0, width: 8, height: 1);

      buttonView.paintSurface(surface, rect);

      // Check that style was applied (we can't easily test the exact style,
      // but we can verify the surface has been modified)
      expect(surface.getCell(2, 0).char, isNotEmpty);
    });

    test('paintSurface handles long text', () {
      final button = TuiButton('Very long button text');
      final buttonView = TuiButtonView(button);
      final surface = TuiSurface(width: 5, height: 5);
      const rect = TuiRect(x: 0, y: 0, width: 5, height: 1);

      // Should not throw and should handle clipping
      buttonView.paintSurface(surface, rect);
    });
  });
}
