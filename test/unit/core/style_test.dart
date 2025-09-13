import 'package:test/test.dart';
import 'package:utopia_tui/src/core/style.dart';

void main() {
  group('TuiStyle', () {
    test('default constructor creates empty style', () {
      const style = TuiStyle();

      expect(style.fg, isNull);
      expect(style.bg, isNull);
      expect(style.bold, isFalse);
      expect(style.italic, isFalse);
      expect(style.underline, isFalse);
    });

    test('constructor with parameters sets properties correctly', () {
      const style = TuiStyle(
        fg: 255,
        bg: 0,
        bold: true,
        italic: true,
        underline: true,
      );

      expect(style.fg, equals(255));
      expect(style.bg, equals(0));
      expect(style.bold, isTrue);
      expect(style.italic, isTrue);
      expect(style.underline, isTrue);
    });

    test('apply method wraps text with ANSI codes', () {
      const style = TuiStyle(
        fg: 31,
        bg: 40,
        bold: true,
        italic: true,
        underline: true,
      );

      final result = style.apply('Hello');

      // Should start with escape sequence and end with reset
      expect(result, startsWith('\x1b['));
      expect(result, endsWith('Hello\x1b[0m'));
      expect(result, contains('Hello'));
    });
    test('empty style does not add ANSI codes', () {
      const style = TuiStyle();
      final result = style.apply('Hello');

      expect(result, equals('Hello'));
    });

    test('merge combines styles correctly', () {
      const style1 = TuiStyle(fg: 31, bold: true);
      const style2 = TuiStyle(bg: 40, italic: true);

      final merged = style1.merge(style2);

      expect(merged.fg, equals(31));
      expect(merged.bg, equals(40));
      expect(merged.bold, isTrue);
      expect(merged.italic, isTrue);
      expect(merged.underline, isFalse);
    });

    test('merge overwrites properties', () {
      const style1 = TuiStyle(fg: 31, bold: true);
      const style2 = TuiStyle(fg: 32, italic: true);

      final merged = style1.merge(style2);

      expect(merged.fg, equals(32)); // style2 overwrites style1
      expect(merged.bold, isTrue);
      expect(merged.italic, isTrue);
    });

    test('copyWith creates new style with changes', () {
      const original = TuiStyle(fg: 31, bold: true);
      final copy = original.copyWith(bg: 40, bold: false);

      expect(copy.fg, equals(31));
      expect(copy.bg, equals(40));
      expect(copy.bold, isFalse);
      expect(copy.italic, isFalse);
      expect(copy.underline, isFalse);
    });

    test('equality works correctly', () {
      const style1 = TuiStyle(fg: 31, bold: true);
      const style2 = TuiStyle(fg: 31, bold: true);
      const style3 = TuiStyle(fg: 32, bold: true);

      expect(style1, equals(style2));
      expect(style1, isNot(equals(style3)));
    });

    test('hashCode is consistent', () {
      const style1 = TuiStyle(fg: 31, bold: true);
      const style2 = TuiStyle(fg: 31, bold: true);

      expect(style1.hashCode, equals(style2.hashCode));
    });

    test('predefined colors work correctly', () {
      const redStyle = TuiStyle(fg: 196);
      const greenStyle = TuiStyle(fg: 46);
      const blueStyle = TuiStyle(fg: 21);

      expect(redStyle.fg, equals(196));
      expect(greenStyle.fg, equals(46));
      expect(blueStyle.fg, equals(21));
    });

    test('background colors work correctly', () {
      const style = TuiStyle(bg: 196);

      expect(style.bg, equals(196));
      final result = style.apply('test');
      expect(result, contains('48;5;196'));
    });

    test('multiple boolean styles combine correctly', () {
      const style = TuiStyle(bold: true, italic: true, underline: true);

      final result = style.apply('test');
      expect(result, contains('1')); // bold
      expect(result, contains('3')); // italic
      expect(result, contains('4')); // underline
    });
  });
}
