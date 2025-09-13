import 'package:test/test.dart';
import 'package:utopia_tui/src/core/rect.dart';

void main() {
  group('TuiRect', () {
    test('basic construction and properties', () {
      const rect = TuiRect(x: 10, y: 20, width: 30, height: 40);
      expect(rect.x, equals(10));
      expect(rect.y, equals(20));
      expect(rect.width, equals(30));
      expect(rect.height, equals(40));
      expect(rect.right, equals(40));
      expect(rect.bottom, equals(60));
    });

    test('contains point', () {
      const rect = TuiRect(x: 10, y: 10, width: 20, height: 20);
      expect(rect.contains(15, 15), isTrue);
      expect(rect.contains(10, 10), isTrue);
      expect(rect.contains(29, 29), isTrue);
      expect(rect.contains(30, 30), isFalse);
      expect(rect.contains(5, 15), isFalse);
    });

    test('intersection', () {
      const rect1 = TuiRect(x: 0, y: 0, width: 20, height: 20);
      const rect2 = TuiRect(x: 10, y: 10, width: 20, height: 20);

      final intersection = rect1.intersection(rect2);
      expect(intersection, isNotNull);
      expect(intersection!.x, equals(10));
      expect(intersection.y, equals(10));
      expect(intersection.width, equals(10));
      expect(intersection.height, equals(10));
    });

    test('split horizontal', () {
      const rect = TuiRect(x: 0, y: 0, width: 100, height: 50);
      final split = rect.splitHorizontal(30);

      expect(split.left.width, equals(30));
      expect(split.right.width, equals(70));
      expect(split.left.x, equals(0));
      expect(split.right.x, equals(30));
    });

    test('shrink with padding', () {
      const rect = TuiRect(x: 10, y: 10, width: 100, height: 100);
      final shrunk = rect.shrink(left: 5, top: 5, right: 10, bottom: 10);

      expect(shrunk.x, equals(15));
      expect(shrunk.y, equals(15));
      expect(shrunk.width, equals(85));
      expect(shrunk.height, equals(85));
    });
  });

  group('TuiInsets', () {
    test('apply to rect', () {
      const rect = TuiRect(x: 0, y: 0, width: 100, height: 100);
      const insets = TuiInsets.all(10);

      final result = insets.applyTo(rect);
      expect(result.x, equals(10));
      expect(result.y, equals(10));
      expect(result.width, equals(80));
      expect(result.height, equals(80));
    });

    test('symmetric insets', () {
      const insets = TuiInsets.symmetric(horizontal: 5, vertical: 10);
      expect(insets.left, equals(5));
      expect(insets.right, equals(5));
      expect(insets.top, equals(10));
      expect(insets.bottom, equals(10));
    });
  });
}
