import 'package:test/test.dart';
import 'package:utopia_tui/utopia_tui.dart';

void main() {
  group('TuiBorderChars', () {
    test('ascii border chars are correct', () {
      const border = TuiBorderChars.ascii;

      expect(border.topLeft, equals('+'));
      expect(border.topRight, equals('+'));
      expect(border.bottomLeft, equals('+'));
      expect(border.bottomRight, equals('+'));
      expect(border.horizontal, equals('-'));
      expect(border.vertical, equals('|'));
    });

    test('rounded border chars are correct', () {
      const border = TuiBorderChars.rounded;

      expect(border.topLeft, equals('┌'));
      expect(border.topRight, equals('┐'));
      expect(border.bottomLeft, equals('└'));
      expect(border.bottomRight, equals('┘'));
      expect(border.horizontal, equals('─'));
      expect(border.vertical, equals('│'));
    });

    test('custom border chars can be created', () {
      const border = TuiBorderChars(
        topLeft: 'A',
        topRight: 'B',
        bottomLeft: 'C',
        bottomRight: 'D',
        horizontal: 'E',
        vertical: 'F',
      );

      expect(border.topLeft, equals('A'));
      expect(border.topRight, equals('B'));
      expect(border.bottomLeft, equals('C'));
      expect(border.bottomRight, equals('D'));
      expect(border.horizontal, equals('E'));
      expect(border.vertical, equals('F'));
    });
  });

  group('TuiTheme', () {
    test('default constructor uses rounded borders', () {
      const theme = TuiTheme();

      expect(theme.border, equals(TuiBorderChars.rounded));
      expect(theme.listSelectedPrefix, equals('>'));
      expect(theme.listUnselectedPrefix, equals(' '));
    });

    test('constructor with parameters sets properties correctly', () {
      const accent = TuiStyle(fg: 39);
      const dim = TuiStyle(fg: 245);
      const borderStyle = TuiStyle(fg: 240);

      const theme = TuiTheme(
        border: TuiBorderChars.ascii,
        listSelectedPrefix: '→',
        listUnselectedPrefix: '·',
        accent: accent,
        dim: dim,
        borderStyle: borderStyle,
      );

      expect(theme.border, equals(TuiBorderChars.ascii));
      expect(theme.listSelectedPrefix, equals('→'));
      expect(theme.listUnselectedPrefix, equals('·'));
      expect(theme.accent, equals(accent));
      expect(theme.dim, equals(dim));
      expect(theme.borderStyle, equals(borderStyle));
    });

    test('theme with all optional styles', () {
      const titleStyle = TuiStyle(bold: true);
      const focusBorderStyle = TuiStyle(fg: 39);

      const theme = TuiTheme(
        titleStyle: titleStyle,
        focusBorderStyle: focusBorderStyle,
      );

      expect(theme.titleStyle, equals(titleStyle));
      expect(theme.focusBorderStyle, equals(focusBorderStyle));
    });

    test('theme equality', () {
      const theme1 = TuiTheme(
        border: TuiBorderChars.ascii,
        listSelectedPrefix: '→',
      );
      const theme2 = TuiTheme(
        border: TuiBorderChars.ascii,
        listSelectedPrefix: '→',
      );
      const theme3 = TuiTheme(
        border: TuiBorderChars.rounded,
        listSelectedPrefix: '→',
      );

      expect(theme1, equals(theme2));
      expect(theme1, isNot(equals(theme3)));
    });

    test('default theme is usable', () {
      const theme = TuiTheme();

      // Should not throw and should have reasonable defaults
      expect(theme.border.topLeft, isNotEmpty);
      expect(theme.listSelectedPrefix, isNotEmpty);
      expect(theme.listUnselectedPrefix, isNotNull);
    });
  });
}
