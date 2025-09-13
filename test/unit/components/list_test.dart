import 'package:test/test.dart';
import 'package:utopia_tui/utopia_tui.dart';

void main() {
  group('TuiList', () {
    test('constructor sets properties correctly', () {
      final items = ['Item 1', 'Item 2', 'Item 3'];
      const theme = TuiTheme();
      const selectedStyle = TuiStyle(fg: 255);
      const unselectedStyle = TuiStyle(fg: 240);

      final list = TuiList(
        items,
        selectedIndex: 1,
        theme: theme,
        selectedStyle: selectedStyle,
        unselectedStyle: unselectedStyle,
      );

      expect(list.items, equals(items));
      expect(list.selectedIndex, equals(1));
      expect(list.theme, equals(theme));
      expect(list.selectedStyle, equals(selectedStyle));
      expect(list.unselectedStyle, equals(unselectedStyle));
    });

    test('default constructor values are correct', () {
      final items = ['Item 1', 'Item 2'];
      final list = TuiList(items);

      expect(list.items, equals(items));
      expect(list.selectedIndex, equals(0));
      expect(list.theme, isA<TuiTheme>());
      expect(list.selectedStyle, isNull);
      expect(list.unselectedStyle, isNull);
    });

    test('moveUp decreases selectedIndex', () {
      final list = TuiList(['A', 'B', 'C'], selectedIndex: 2);

      list.moveUp();
      expect(list.selectedIndex, equals(1));

      list.moveUp();
      expect(list.selectedIndex, equals(0));
    });

    test('moveUp does not go below 0', () {
      final list = TuiList(['A', 'B', 'C'], selectedIndex: 0);

      list.moveUp();
      expect(list.selectedIndex, equals(0));
    });

    test('moveDown increases selectedIndex', () {
      final list = TuiList(['A', 'B', 'C'], selectedIndex: 0);

      list.moveDown();
      expect(list.selectedIndex, equals(1));

      list.moveDown();
      expect(list.selectedIndex, equals(2));
    });

    test('moveDown does not exceed items length', () {
      final list = TuiList(['A', 'B', 'C'], selectedIndex: 2);

      list.moveDown();
      expect(list.selectedIndex, equals(2));
    });

    test('render produces correct number of lines', () {
      final list = TuiList(['A', 'B', 'C']);
      final lines = list.render(20, 5);

      expect(lines, hasLength(5));
    });

    test('render shows all items when height >= items.length', () {
      final list = TuiList(['Alpha', 'Beta', 'Gamma']);
      final lines = list.render(20, 5);

      expect(lines[0], contains('Alpha'));
      expect(lines[1], contains('Beta'));
      expect(lines[2], contains('Gamma'));
      expect(lines[3], equals('')); // Empty line
      expect(lines[4], equals('')); // Empty line
    });

    test('render shows only available items when height < items.length', () {
      final list = TuiList(['Alpha', 'Beta', 'Gamma', 'Delta']);
      final lines = list.render(20, 2);

      expect(lines, hasLength(2));
      expect(lines[0], contains('Alpha'));
      expect(lines[1], contains('Beta'));
    });

    test('render uses correct prefixes for selected/unselected items', () {
      const theme = TuiTheme(
        listSelectedPrefix: '→',
        listUnselectedPrefix: '·',
      );
      final list = TuiList(['Alpha', 'Beta'], selectedIndex: 1, theme: theme);
      final lines = list.render(20, 2);

      expect(lines[0], contains('·')); // Unselected
      expect(lines[0], contains('Alpha'));
      expect(lines[1], contains('→')); // Selected
      expect(lines[1], contains('Beta'));
    });

    test('render applies styles correctly', () {
      const selectedStyle = TuiStyle(fg: 255);
      const unselectedStyle = TuiStyle(fg: 240);
      final list = TuiList(
        ['Alpha', 'Beta'],
        selectedIndex: 0,
        selectedStyle: selectedStyle,
        unselectedStyle: unselectedStyle,
      );
      final lines = list.render(20, 2);

      // Lines should contain ANSI escape codes for styling
      expect(lines[0], contains('\x1b[')); // Selected item with style
      expect(lines[1], contains('\x1b[')); // Unselected item with style
    });

    test('render handles width constraints correctly', () {
      final list = TuiList(['Very long item name that exceeds width']);
      final lines = list.render(10, 1);

      expect(lines, hasLength(1));
      // The render method doesn't actually constrain width, it just formats
      expect(lines[0].length, greaterThan(10));
      expect(lines[0], contains('Very long item name'));
    });

    test('render handles very small width', () {
      final list = TuiList(['Alpha']);
      final lines = list.render(3, 1);

      expect(lines, hasLength(1));
      // The render method doesn't constrain width, just formats
      expect(lines[0].length, greaterThan(3));
    });

    test('render handles empty items list', () {
      final list = TuiList([]);
      final lines = list.render(20, 3);

      expect(lines, hasLength(3));
      expect(lines[0], equals(''));
      expect(lines[1], equals(''));
      expect(lines[2], equals(''));
    });

    test('render does not pad lines to width', () {
      final list = TuiList(['A']);
      final lines = list.render(15, 2);

      expect(lines, hasLength(2));
      // render() doesn't pad lines to width, just formats the text
      expect(lines[0], equals(' > A '));
      expect(lines[1], equals(''));
    });
  });

  group('TuiListView', () {
    test('constructor sets list correctly', () {
      final list = TuiList(['A', 'B']);
      final listView = TuiListView(list);

      expect(listView.list, equals(list));
    });

    test('paintSurface renders list content', () {
      final list = TuiList(['Alpha', 'Beta'], selectedIndex: 1);
      final listView = TuiListView(list);
      final surface = TuiSurface(width: 10, height: 3);
      final rect = TuiRect(x: 0, y: 0, width: 10, height: 3);

      listView.paintSurface(surface, rect);

      // Check that content was rendered
      final lines = surface.toAnsiLines();
      expect(lines[0], contains('Alpha'));
      expect(lines[1], contains('Beta'));
    });

    test('paintSurface handles empty rect', () {
      final list = TuiList(['Alpha']);
      final listView = TuiListView(list);
      final surface = TuiSurface(width: 10, height: 3);
      final rect = TuiRect(x: 0, y: 0, width: 0, height: 0);

      // Should not throw
      listView.paintSurface(surface, rect);
    });

    test('paintSurface clears the area before rendering', () {
      final list = TuiList(['A']);
      final listView = TuiListView(list);
      final surface = TuiSurface(width: 5, height: 2);
      final rect = TuiRect(x: 0, y: 0, width: 5, height: 2);

      // Pre-fill surface with content
      surface.putChar(0, 0, 'X');
      surface.putChar(1, 0, 'Y');

      listView.paintSurface(surface, rect);

      // Should be cleared and replaced with list content
      final lines = surface.toAnsiLines();
      expect(lines[0], isNot(contains('X')));
      expect(lines[0], isNot(contains('Y')));
    });

    test('paintSurface respects rect boundaries', () {
      final list = TuiList(['Alpha', 'Beta', 'Gamma']);
      final listView = TuiListView(list);
      final surface = TuiSurface(width: 10, height: 5);
      final rect = TuiRect(x: 2, y: 1, width: 6, height: 2);

      listView.paintSurface(surface, rect);

      // Content should only appear within the specified rect
      expect(surface.getCell(1, 1).char, equals(' ')); // Outside rect (left)
      expect(
        surface.getCell(3, 1).char,
        equals('>'),
      ); // Inside rect - selector char
      expect(
        surface.getCell(5, 2).char,
        equals('B'),
      ); // Inside rect - second line content
      expect(surface.getCell(2, 3).char, equals(' ')); // Outside rect (below)
    });
  });
}
