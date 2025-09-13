import 'package:test/test.dart';
import 'package:utopia_tui/src/core/canvas.dart';
import 'package:utopia_tui/src/core/style.dart';

void main() {
  group('TuiCell', () {
    test('constructor with codePoint creates cell correctly', () {
      const style = TuiStyle(bold: true);
      const cell = TuiCell(codePoint: 65, style: style);

      expect(cell.codePoint, equals(65));
      expect(cell.style, equals(style));
      expect(cell.char, equals('A'));
      expect(cell.isEmpty, isFalse);
    });

    test('default constructor creates empty cell', () {
      const cell = TuiCell(codePoint: 32);

      expect(cell.codePoint, equals(32));
      expect(cell.style, equals(const TuiStyle()));
      expect(cell.char, equals(' '));
      expect(cell.isEmpty, isTrue);
    });

    test('fromChar constructor creates cell from character', () {
      const style = TuiStyle(bold: true);
      final cell = TuiCell.fromChar('A', style: style);

      expect(cell.codePoint, equals(65));
      expect(cell.style, equals(style));
      expect(cell.char, equals('A'));
    });

    test('empty constructor creates space cell', () {
      const style = TuiStyle(fg: 31);
      const cell = TuiCell.empty(style: style);

      expect(cell.codePoint, equals(32));
      expect(cell.style, equals(style));
      expect(cell.isEmpty, isTrue);
    });

    test('equality works correctly', () {
      const style = TuiStyle(bold: true);
      const cell1 = TuiCell(codePoint: 65, style: style);
      const cell2 = TuiCell(codePoint: 65, style: style);
      const cell3 = TuiCell(codePoint: 66, style: style);

      expect(cell1, equals(cell2));
      expect(cell1, isNot(equals(cell3)));
    });

    test('withStyle creates new cell with different style', () {
      const originalStyle = TuiStyle(bold: true);
      const newStyle = TuiStyle(italic: true);
      const originalCell = TuiCell(codePoint: 65, style: originalStyle);

      final newCell = originalCell.withStyle(newStyle);

      expect(newCell.codePoint, equals(65));
      expect(newCell.style, equals(newStyle));
      expect(originalCell.style, equals(originalStyle)); // Original unchanged
    });

    test('hashCode is consistent', () {
      const style = TuiStyle(bold: true);
      const cell1 = TuiCell(codePoint: 65, style: style);
      const cell2 = TuiCell(codePoint: 65, style: style);

      expect(cell1.hashCode, equals(cell2.hashCode));
    });

    test('isEmpty detects space characters', () {
      const spaceCell = TuiCell(codePoint: 32);
      const letterCell = TuiCell(codePoint: 65);

      expect(spaceCell.isEmpty, isTrue);
      expect(letterCell.isEmpty, isFalse);
    });

    test('fromChar handles empty string', () {
      final cell = TuiCell.fromChar('');

      expect(cell.codePoint, equals(32)); // Should default to space
      expect(cell.isEmpty, isTrue);
    });
  });

  group('TuiSurface', () {
    test('constructor creates surface with correct dimensions', () {
      final surface = TuiSurface(width: 10, height: 5);

      expect(surface.width, equals(10));
      expect(surface.height, equals(5));
    });

    test('getCell returns correct cell at position', () {
      final surface = TuiSurface(width: 10, height: 5);

      final cell = surface.getCell(0, 0);
      expect(cell, equals(const TuiCell.empty()));
    });

    test('setCell updates cell at position', () {
      final surface = TuiSurface(width: 10, height: 5);
      const newCell = TuiCell(codePoint: 65);

      surface.setCell(2, 3, newCell);
      final retrievedCell = surface.getCell(2, 3);

      expect(retrievedCell, equals(newCell));
    });

    test('clearRect clears area to empty cells', () {
      final surface = TuiSurface(width: 10, height: 5);

      // Fill some cells first
      surface.setCell(1, 1, const TuiCell(codePoint: 65));
      surface.setCell(2, 1, const TuiCell(codePoint: 66));

      // Clear a rect
      surface.clearRect(1, 1, 2, 1);

      expect(surface.getCell(1, 1), equals(const TuiCell.empty()));
      expect(surface.getCell(2, 1), equals(const TuiCell.empty()));
    });

    test('putText draws string at position', () {
      final surface = TuiSurface(width: 10, height: 5);
      const style = TuiStyle(bold: true);

      surface.putText(2, 1, 'AB', style: style);

      expect(surface.getCell(2, 1).char, equals('A'));
      expect(surface.getCell(3, 1).char, equals('B'));
      expect(surface.getCell(2, 1).style, equals(style));
      expect(surface.getCell(3, 1).style, equals(style));
    });

    test('putText clips to surface bounds', () {
      final surface = TuiSurface(width: 3, height: 3);

      // Try to draw text that would go beyond bounds
      surface.putText(2, 1, 'ABCD', style: const TuiStyle());

      expect(surface.getCell(2, 1).char, equals('A'));
      // The rest should be clipped
    });

    test('toAnsiLines generates ANSI output', () {
      final surface = TuiSurface(width: 3, height: 2);
      surface.putText(0, 0, 'AB', style: const TuiStyle());
      surface.putText(0, 1, 'CD', style: const TuiStyle());

      final lines = surface.toAnsiLines();

      expect(lines, hasLength(2));
      expect(lines[0], contains('AB'));
      expect(lines[1], contains('CD'));
    });

    test('bounds checking prevents out-of-bounds access', () {
      final surface = TuiSurface(width: 3, height: 3);

      // These should not throw
      surface.setCell(-1, 0, const TuiCell(codePoint: 65));
      surface.setCell(0, -1, const TuiCell(codePoint: 65));
      surface.setCell(10, 0, const TuiCell(codePoint: 65));
      surface.setCell(0, 10, const TuiCell(codePoint: 65));

      // Surface should remain unchanged
      expect(surface.getCell(0, 0), equals(const TuiCell.empty()));
    });

    test('fillRect fills area with specified character', () {
      final surface = TuiSurface(width: 5, height: 5);

      surface.fillRect(1, 1, 3, 2, 'X');

      expect(surface.getCell(1, 1).char, equals('X'));
      expect(surface.getCell(2, 1).char, equals('X'));
      expect(surface.getCell(3, 1).char, equals('X'));
      expect(surface.getCell(1, 2).char, equals('X'));
      expect(surface.getCell(2, 2).char, equals('X'));
      expect(surface.getCell(3, 2).char, equals('X'));

      // Outside the rect should be unchanged
      expect(surface.getCell(0, 0), equals(const TuiCell.empty()));
      expect(surface.getCell(4, 4), equals(const TuiCell.empty()));
    });

    test('putChar puts single character', () {
      final surface = TuiSurface(width: 5, height: 5);
      const style = TuiStyle(bold: true);

      surface.putChar(2, 2, 'X', style: style);

      expect(surface.getCell(2, 2).char, equals('X'));
      expect(surface.getCell(2, 2).style, equals(style));
    });

    test('clear method clears entire surface', () {
      final surface = TuiSurface(width: 3, height: 3);

      // Fill with data first
      surface.putText(0, 0, 'ABC', style: const TuiStyle());

      // Clear it
      surface.clear();

      // Should all be empty
      for (int y = 0; y < 3; y++) {
        for (int x = 0; x < 3; x++) {
          expect(surface.getCell(x, y), equals(const TuiCell.empty()));
        }
      }
    });

    test('getRowString returns row as string', () {
      final surface = TuiSurface(width: 3, height: 3);
      surface.putText(0, 1, 'ABC', style: const TuiStyle());

      final rowString = surface.getRowString(1);
      expect(rowString, equals('ABC'));
    });
  });
}
