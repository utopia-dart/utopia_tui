import 'package:test/test.dart';
import 'package:utopia_tui/src/core/canvas.dart';
import 'package:utopia_tui/src/core/style.dart';

void main() {
  group('TuiCell', () {
    test('constructor creates cell correctly', () {
      const style = TuiStyle(bold: true);
      const cell = TuiCell(char: 'A', style: style);

      expect(cell.char, equals('A'));
      expect(cell.style, equals(style));
      expect(cell.isEmpty, isFalse);
    });

    test('default constructor creates empty cell', () {
      const cell = TuiCell(char: ' ');

      expect(cell.style, equals(const TuiStyle()));
      expect(cell.char, equals(' '));
      expect(cell.isEmpty, isTrue);
    });

    test('empty constructor creates space cell', () {
      const style = TuiStyle(fg: 31);
      const cell = TuiCell.empty(style: style);

      expect(cell.style, equals(style));
      expect(cell.isEmpty, isTrue);
    });

    test('equality works correctly', () {
      const style = TuiStyle(bold: true);
      const cell1 = TuiCell(char: 'A', style: style);
      const cell2 = TuiCell(char: 'A', style: style);
      const cell3 = TuiCell(char: 'B', style: style);

      expect(cell1, equals(cell2));
      expect(cell1, isNot(equals(cell3)));
    });

    test('withStyle creates new cell with different style', () {
      const originalStyle = TuiStyle(bold: true);
      const newStyle = TuiStyle(italic: true);
      const originalCell = TuiCell(char: 'A', style: originalStyle);

      final newCell = originalCell.withStyle(newStyle);

      expect(newCell.char, equals('A'));
      expect(newCell.style, equals(newStyle));
      expect(originalCell.style, equals(originalStyle));
    });

    test('hashCode is consistent', () {
      const style = TuiStyle(bold: true);
      const cell1 = TuiCell(char: 'A', style: style);
      const cell2 = TuiCell(char: 'A', style: style);

      expect(cell1.hashCode, equals(cell2.hashCode));
    });

    test('isEmpty detects space characters', () {
      const spaceCell = TuiCell(char: ' ');
      const letterCell = TuiCell(char: 'A');

      expect(spaceCell.isEmpty, isTrue);
      expect(letterCell.isEmpty, isFalse);
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
      const newCell = TuiCell(char: 'A');

      surface.setCell(2, 3, newCell);
      final retrievedCell = surface.getCell(2, 3);

      expect(retrievedCell, equals(newCell));
    });

    test('clearRect clears area to empty cells', () {
      final surface = TuiSurface(width: 10, height: 5);

      surface.setCell(1, 1, const TuiCell(char: 'A'));
      surface.setCell(2, 1, const TuiCell(char: 'B'));

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

      surface.putText(2, 1, 'ABCD', style: const TuiStyle());

      expect(surface.getCell(2, 1).char, equals('A'));
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

      surface.setCell(-1, 0, const TuiCell(char: 'A'));
      surface.setCell(0, -1, const TuiCell(char: 'A'));
      surface.setCell(10, 0, const TuiCell(char: 'A'));
      surface.setCell(0, 10, const TuiCell(char: 'A'));

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

      surface.putText(0, 0, 'ABC', style: const TuiStyle());
      surface.clear();

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

    test('wide character sets continuation cell', () {
      final surface = TuiSurface(width: 10, height: 1);
      surface.putTextClip(0, 0, 'A🚀B', 10);

      expect(surface.getCell(0, 0).char, equals('A'));
      expect(surface.getCell(1, 0).char, contains('🚀'));
      expect(surface.getCell(2, 0).wideContinuation, isTrue);
      expect(surface.getCell(3, 0).char, equals('B'));
    });

    test('toAnsiLines skips continuation cells', () {
      final surface = TuiSurface(width: 10, height: 1);
      surface.putChar(0, 0, '│');
      surface.putTextClip(1, 0, 'A🚀B', 8);
      surface.putChar(9, 0, '│');

      final lines = surface.toAnsiLines();
      final plain = lines[0].replaceAll(RegExp(r'\x1b\[[0-9;]*m'), '');
      expect(TuiSurface.displayWidth(plain), equals(10));
    });

    test('zero-width chars do not occupy cells', () {
      final surface = TuiSurface(width: 10, height: 1);
      // ❤️ = U+2764 + U+FE0F (variation selector)
      surface.putTextClip(0, 0, 'A❤️B', 10);

      expect(surface.getCell(0, 0).char, equals('A'));
      // ❤ with variation selector stored as one cluster
      expect(surface.getCell(1, 0).char, contains('❤'));
      // B follows after the wide char + continuation
      expect(surface.getCell(3, 0).char, equals('B'));
    });

    test('displayWidth counts zero-width chars as 0', () {
      expect(TuiSurface.displayWidth('A'), equals(1));
      expect(TuiSurface.displayWidth('🚀'), equals(2));
      // Variation selector should not add width
      expect(TuiSurface.displayWidth('\u{FE0F}'), equals(0));
    });
  });
}
