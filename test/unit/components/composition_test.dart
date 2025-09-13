import 'package:test/test.dart';
import 'package:utopia_tui/utopia_tui.dart';

void main() {
  group('TuiRow', () {
    test('constructor sets properties correctly', () {
      final child1 = TuiText('A');
      final child2 = TuiText('B');
      final children = [child1, child2];
      final widths = [10, 20];

      final row = TuiRow(children: children, widths: widths, gap: 2);

      expect(row.children, equals(children));
      expect(row.widths, equals(widths));
      expect(row.gap, equals(2));
    });

    test('default gap is 0', () {
      final row = TuiRow(children: [], widths: []);

      expect(row.gap, equals(0));
    });

    test('paintSurface renders children horizontally', () {
      final child1 = TuiText('A');
      final child2 = TuiText('B');
      final row = TuiRow(children: [child1, child2], widths: [3, 3]);

      final surface = TuiSurface(width: 6, height: 1);
      final rect = TuiRect(x: 0, y: 0, width: 6, height: 1);

      row.paintSurface(surface, rect);

      final lines = surface.toAnsiLines();
      expect(lines[0], contains('A'));
      expect(lines[0], contains('B'));
    });

    test('paintSurface handles gap between children', () {
      final child1 = TuiText('X');
      final child2 = TuiText('Y');
      final row = TuiRow(children: [child1, child2], widths: [1, 1], gap: 2);

      final surface = TuiSurface(width: 5, height: 1);
      final rect = TuiRect(x: 0, y: 0, width: 5, height: 1);

      row.paintSurface(surface, rect);

      expect(surface.getCell(0, 0).char, equals('X'));
      expect(surface.getCell(1, 0).char, equals(' ')); // Gap
      expect(surface.getCell(2, 0).char, equals(' ')); // Gap
      expect(surface.getCell(3, 0).char, equals('Y'));
    });

    test('paintSurface handles flexible widths (-1)', () {
      final child1 = TuiText('Fixed');
      final child2 = TuiText('Flexible');
      final row = TuiRow(children: [child1, child2], widths: [5, -1]);

      final surface = TuiSurface(width: 15, height: 1);
      final rect = TuiRect(x: 0, y: 0, width: 15, height: 1);

      row.paintSurface(surface, rect);

      final lines = surface.toAnsiLines();
      expect(lines[0], contains('Fixed'));
      expect(lines[0], contains('Flexible'));
    });

    test('paintSurface handles empty children list', () {
      final row = TuiRow(children: [], widths: []);

      final surface = TuiSurface(width: 10, height: 1);
      final rect = TuiRect(x: 0, y: 0, width: 10, height: 1);

      // Should not throw
      row.paintSurface(surface, rect);
    });

    test('paintSurface handles empty rect', () {
      final child = TuiText('A');
      final row = TuiRow(children: [child], widths: [5]);

      final surface = TuiSurface(width: 10, height: 1);
      final rect = TuiRect(x: 0, y: 0, width: 0, height: 0);

      // Should not throw and not render anything
      row.paintSurface(surface, rect);
    });
  });

  group('TuiColumn', () {
    test('constructor sets properties correctly', () {
      final child1 = TuiText('A');
      final child2 = TuiText('B');
      final children = [child1, child2];
      final heights = [10, 20];

      final column = TuiColumn(children: children, heights: heights, gap: 1);

      expect(column.children, equals(children));
      expect(column.heights, equals(heights));
      expect(column.gap, equals(1));
    });

    test('default gap is 0', () {
      final column = TuiColumn(children: [], heights: []);

      expect(column.gap, equals(0));
    });

    test('paintSurface renders children vertically', () {
      final child1 = TuiText('A');
      final child2 = TuiText('B');
      final column = TuiColumn(children: [child1, child2], heights: [1, 1]);

      final surface = TuiSurface(width: 3, height: 2);
      final rect = TuiRect(x: 0, y: 0, width: 3, height: 2);

      column.paintSurface(surface, rect);

      expect(surface.getCell(0, 0).char, equals('A'));
      expect(surface.getCell(0, 1).char, equals('B'));
    });

    test('paintSurface handles gap between children', () {
      final child1 = TuiText('X');
      final child2 = TuiText('Y');
      final column = TuiColumn(
        children: [child1, child2],
        heights: [1, 1],
        gap: 1,
      );

      final surface = TuiSurface(width: 3, height: 4);
      final rect = TuiRect(x: 0, y: 0, width: 3, height: 4);

      column.paintSurface(surface, rect);

      expect(surface.getCell(0, 0).char, equals('X'));
      expect(surface.getCell(0, 1).char, equals(' ')); // Gap
      expect(surface.getCell(0, 2).char, equals('Y'));
    });

    test('paintSurface handles flexible heights (-1)', () {
      final child1 = TuiText('Fixed');
      final child2 = TuiText('Flexible');
      final column = TuiColumn(children: [child1, child2], heights: [1, -1]);

      final surface = TuiSurface(width: 10, height: 5);
      final rect = TuiRect(x: 0, y: 0, width: 10, height: 5);

      column.paintSurface(surface, rect);

      expect(surface.getCell(0, 0).char, equals('F')); // "Fixed"
      expect(surface.getCell(0, 1).char, equals('F')); // "Flexible"
    });
  });

  group('TuiText', () {
    test('constructor sets properties correctly', () {
      const style = TuiStyle(fg: 255);
      final text = TuiText('Hello World', style: style);

      expect(text.text, equals('Hello World'));
      expect(text.style, equals(style));
    });

    test('style is optional', () {
      final text = TuiText('Hello');

      expect(text.text, equals('Hello'));
      expect(text.style, isNull);
    });

    test('paintSurface renders single line text', () {
      final text = TuiText('Hello');
      final surface = TuiSurface(width: 10, height: 2);
      final rect = TuiRect(x: 0, y: 0, width: 10, height: 2);

      text.paintSurface(surface, rect);

      expect(surface.getCell(0, 0).char, equals('H'));
      expect(surface.getCell(1, 0).char, equals('e'));
      expect(surface.getCell(2, 0).char, equals('l'));
      expect(surface.getCell(3, 0).char, equals('l'));
      expect(surface.getCell(4, 0).char, equals('o'));
      expect(surface.getCell(0, 1).char, equals(' ')); // Second line empty
    });

    test('paintSurface handles multiline text', () {
      final text = TuiText('Line 1\nLine 2');
      final surface = TuiSurface(width: 10, height: 3);
      final rect = TuiRect(x: 0, y: 0, width: 10, height: 3);

      text.paintSurface(surface, rect);

      // Check first line
      expect(surface.getCell(0, 0).char, equals('L'));
      expect(surface.getCell(5, 0).char, equals('1'));

      // Check second line
      expect(surface.getCell(0, 1).char, equals('L'));
      expect(surface.getCell(5, 1).char, equals('2'));
    });

    test('paintSurface applies style when provided', () {
      const style = TuiStyle(fg: 255);
      final text = TuiText('Test', style: style);
      final surface = TuiSurface(width: 10, height: 1);
      final rect = TuiRect(x: 0, y: 0, width: 10, height: 1);

      text.paintSurface(surface, rect);

      expect(surface.getCell(0, 0).style, equals(style));
    });

    test('paintSurface uses default style when none provided', () {
      final text = TuiText('Test');
      final surface = TuiSurface(width: 10, height: 1);
      final rect = TuiRect(x: 0, y: 0, width: 10, height: 1);

      text.paintSurface(surface, rect);

      expect(surface.getCell(0, 0).style, equals(const TuiStyle()));
    });

    test('paintSurface clips text to rect width', () {
      final text = TuiText('Very long text that exceeds width');
      final surface = TuiSurface(width: 10, height: 1);
      final rect = TuiRect(x: 0, y: 0, width: 5, height: 1);

      text.paintSurface(surface, rect);

      expect(surface.getCell(0, 0).char, equals('V'));
      expect(surface.getCell(4, 0).char, equals(' ')); // Within rect
      expect(
        surface.getCell(5, 0).char,
        equals(' '),
      ); // Outside rect - should be empty
    });

    test('paintSurface clips text to rect height', () {
      final text = TuiText('Line 1\nLine 2\nLine 3');
      final surface = TuiSurface(width: 10, height: 3);
      final rect = TuiRect(x: 0, y: 0, width: 10, height: 2);

      text.paintSurface(surface, rect);

      // Should only render first 2 lines
      expect(surface.getCell(0, 0).char, isNot(equals(' ')));
      expect(surface.getCell(0, 1).char, isNot(equals(' ')));
      expect(
        surface.getCell(0, 2).char,
        equals(' '),
      ); // Third line not rendered
    });

    test('paintSurface handles empty text', () {
      final text = TuiText('');
      final surface = TuiSurface(width: 5, height: 1);
      final rect = TuiRect(x: 0, y: 0, width: 5, height: 1);

      text.paintSurface(surface, rect);

      // Should clear the area but not place any characters
      for (int x = 0; x < 5; x++) {
        expect(surface.getCell(x, 0).char, equals(' '));
      }
    });

    test('paintSurface handles empty rect', () {
      final text = TuiText('Test');
      final surface = TuiSurface(width: 5, height: 1);
      final rect = TuiRect(x: 0, y: 0, width: 0, height: 0);

      // Should not throw
      text.paintSurface(surface, rect);
    });
  });

  group('TuiPadding', () {
    test('constructor sets properties correctly', () {
      final child = TuiText('Test');
      final padding = TuiPadding(
        child: child,
        left: 1,
        right: 2,
        top: 3,
        bottom: 4,
      );

      expect(padding.child, equals(child));
      expect(padding.left, equals(1));
      expect(padding.right, equals(2));
      expect(padding.top, equals(3));
      expect(padding.bottom, equals(4));
    });

    test('default padding values are 0', () {
      final child = TuiText('Test');
      final padding = TuiPadding(child: child);

      expect(padding.left, equals(0));
      expect(padding.right, equals(0));
      expect(padding.top, equals(0));
      expect(padding.bottom, equals(0));
    });

    test('paintSurface applies padding correctly', () {
      final child = TuiText('X');
      final padding = TuiPadding(child: child, left: 2, top: 1);

      final surface = TuiSurface(width: 5, height: 3);
      final rect = TuiRect(x: 0, y: 0, width: 5, height: 3);

      padding.paintSurface(surface, rect);

      // Child should be rendered at offset position
      expect(surface.getCell(0, 0).char, equals(' ')); // Padding area
      expect(surface.getCell(1, 0).char, equals(' ')); // Padding area
      expect(surface.getCell(0, 1).char, equals(' ')); // Padding area
      expect(surface.getCell(2, 1).char, equals('X')); // Child content
    });

    test('paintSurface handles padding larger than rect', () {
      final child = TuiText('X');
      final padding = TuiPadding(child: child, left: 10, top: 10);

      final surface = TuiSurface(width: 5, height: 3);
      final rect = TuiRect(x: 0, y: 0, width: 5, height: 3);

      // Should not throw, child should not be rendered
      padding.paintSurface(surface, rect);
    });

    test('paintSurface handles empty rect', () {
      final child = TuiText('X');
      final padding = TuiPadding(child: child, left: 1);

      final surface = TuiSurface(width: 5, height: 3);
      final rect = TuiRect(x: 0, y: 0, width: 0, height: 0);

      // Should not throw
      padding.paintSurface(surface, rect);
    });
  });
}
