import 'package:test/test.dart';
import 'package:utopia_tui/utopia_tui.dart';

void main() {
  group('TuiLayout', () {
    group('splitH', () {
      test('splits horizontal space with fixed widths', () {
        final splits = TuiLayout.splitH(100, [20, 30, 50]);

        expect(splits, hasLength(3));
        expect(splits[0], equals((0, 20)));
        expect(splits[1], equals((20, 30)));
        expect(splits[2], equals((50, 50)));
      });

      test('splits horizontal space with flexible width (-1)', () {
        final splits = TuiLayout.splitH(100, [20, -1, 30]);

        expect(splits, hasLength(3));
        expect(splits[0], equals((0, 20)));
        expect(splits[1], equals((20, 50))); // 100 - 20 - 30 = 50
        expect(splits[2], equals((70, 30)));
      });

      test('splits horizontal space with multiple flexible widths', () {
        final splits = TuiLayout.splitH(100, [20, -1, -1]);

        expect(splits, hasLength(3));
        expect(splits[0], equals((0, 20)));
        expect(splits[1], equals((20, 40))); // (100 - 20) / 2 = 40
        expect(splits[2], equals((60, 40)));
      });

      test('handles gap between splits', () {
        final splits = TuiLayout.splitH(100, [20, 30, 40], gap: 5);

        expect(splits, hasLength(3));
        expect(splits[0], equals((0, 20)));
        expect(splits[1], equals((25, 30))); // 20 + 5 = 25
        expect(splits[2], equals((60, 40))); // 25 + 30 + 5 = 60
      });

      test('handles insufficient space', () {
        final splits = TuiLayout.splitH(50, [20, 30, 40]);

        expect(splits, hasLength(3));
        // Should still return splits, even if they exceed available space
        expect(splits[0], equals((0, 20)));
        expect(splits[1], equals((20, 30)));
        expect(splits[2], equals((50, 40)));
      });

      test('handles empty widths list', () {
        final splits = TuiLayout.splitH(100, []);

        expect(splits, isEmpty);
      });

      test('handles zero total width', () {
        final splits = TuiLayout.splitH(0, [10, 20]);

        expect(splits, hasLength(2));
        expect(splits[0], equals((0, 10)));
        expect(splits[1], equals((10, 20)));
      });
    });

    group('splitV', () {
      test('splits vertical space with fixed heights', () {
        final splits = TuiLayout.splitV(100, [20, 30, 50]);

        expect(splits, hasLength(3));
        expect(splits[0], equals((0, 20)));
        expect(splits[1], equals((20, 30)));
        expect(splits[2], equals((50, 50)));
      });

      test('splits vertical space with flexible height (-1)', () {
        final splits = TuiLayout.splitV(100, [20, -1, 30]);

        expect(splits, hasLength(3));
        expect(splits[0], equals((0, 20)));
        expect(splits[1], equals((20, 50))); // 100 - 20 - 30 = 50
        expect(splits[2], equals((70, 30)));
      });

      test('splits vertical space with multiple flexible heights', () {
        final splits = TuiLayout.splitV(100, [20, -1, -1]);

        expect(splits, hasLength(3));
        expect(splits[0], equals((0, 20)));
        expect(splits[1], equals((20, 40))); // (100 - 20) / 2 = 40
        expect(splits[2], equals((60, 40)));
      });

      test('handles gap between splits', () {
        final splits = TuiLayout.splitV(100, [20, 30, 40], gap: 5);

        expect(splits, hasLength(3));
        expect(splits[0], equals((0, 20)));
        expect(splits[1], equals((25, 30))); // 20 + 5 = 25
        expect(splits[2], equals((60, 40))); // 25 + 30 + 5 = 60
      });

      test('handles insufficient space', () {
        final splits = TuiLayout.splitV(50, [20, 30, 40]);

        expect(splits, hasLength(3));
        // Should still return splits, even if they exceed available space
        expect(splits[0], equals((0, 20)));
        expect(splits[1], equals((20, 30)));
        expect(splits[2], equals((50, 40)));
      });

      test('handles empty heights list', () {
        final splits = TuiLayout.splitV(100, []);

        expect(splits, isEmpty);
      });

      test('handles zero total height', () {
        final splits = TuiLayout.splitV(0, [10, 20]);

        expect(splits, hasLength(2));
        expect(splits[0], equals((0, 10)));
        expect(splits[1], equals((10, 20)));
      });
    });

    group('edge cases', () {
      test('handles negative widths/heights gracefully', () {
        final hsplits = TuiLayout.splitH(100, [20, -2, 30]);
        final vsplits = TuiLayout.splitV(100, [20, -2, 30]);

        // Should treat negative values other than -1 as flexible
        expect(hsplits, hasLength(3));
        expect(vsplits, hasLength(3));
      });

      test('handles very large splits', () {
        final splits = TuiLayout.splitH(10, [1000, 2000]);

        expect(splits, hasLength(2));
        expect(splits[0], equals((0, 1000)));
        expect(splits[1], equals((1000, 2000)));
      });
    });
  });
}
