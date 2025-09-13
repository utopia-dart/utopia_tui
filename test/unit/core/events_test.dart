import 'package:test/test.dart';
import 'package:utopia_tui/src/core/events.dart';

void main() {
  group('TuiEvent', () {
    test('TuiTickEvent stores timestamp correctly', () {
      final now = DateTime.now();
      final event = TuiTickEvent(now);

      expect(event.at, equals(now));
    });

    test('TuiResizeEvent stores dimensions correctly', () {
      const event = TuiResizeEvent(80, 24);

      expect(event.width, equals(80));
      expect(event.height, equals(24));
    });
  });

  group('TuiKeyCode', () {
    test('enum values exist', () {
      expect(TuiKeyCode.printable, isNotNull);
      expect(TuiKeyCode.enter, isNotNull);
      expect(TuiKeyCode.escape, isNotNull);
      expect(TuiKeyCode.backspace, isNotNull);
      expect(TuiKeyCode.delete, isNotNull);
      expect(TuiKeyCode.arrowUp, isNotNull);
      expect(TuiKeyCode.arrowDown, isNotNull);
      expect(TuiKeyCode.arrowLeft, isNotNull);
      expect(TuiKeyCode.arrowRight, isNotNull);
      expect(TuiKeyCode.ctrlC, isNotNull);
      expect(TuiKeyCode.unknown, isNotNull);
    });
  });

  group('TuiKeyEvent', () {
    test('basic key event creation', () {
      const event = TuiKeyEvent(code: TuiKeyCode.enter);

      expect(event.code, equals(TuiKeyCode.enter));
      expect(event.char, isNull);
      expect(event.isPrintable, isFalse);
    });

    test('printable key event creation', () {
      const event = TuiKeyEvent(code: TuiKeyCode.printable, char: 'a');

      expect(event.code, equals(TuiKeyCode.printable));
      expect(event.char, equals('a'));
      expect(event.isPrintable, isTrue);
    });

    test('isPrintable property works correctly', () {
      const printableEvent = TuiKeyEvent(code: TuiKeyCode.printable, char: 'x');
      const nonPrintableEvent = TuiKeyEvent(code: TuiKeyCode.enter);
      const invalidPrintableEvent = TuiKeyEvent(code: TuiKeyCode.printable);

      expect(printableEvent.isPrintable, isTrue);
      expect(nonPrintableEvent.isPrintable, isFalse);
      expect(invalidPrintableEvent.isPrintable, isFalse);
    });

    test('equality works correctly', () {
      const event1 = TuiKeyEvent(code: TuiKeyCode.enter);
      const event2 = TuiKeyEvent(code: TuiKeyCode.enter);
      const event3 = TuiKeyEvent(code: TuiKeyCode.escape);
      const event4 = TuiKeyEvent(code: TuiKeyCode.printable, char: 'a');
      const event5 = TuiKeyEvent(code: TuiKeyCode.printable, char: 'a');
      const event6 = TuiKeyEvent(code: TuiKeyCode.printable, char: 'b');

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
      expect(event4, equals(event5));
      expect(event4, isNot(equals(event6)));
    });

    test('control key events work', () {
      const ctrlCEvent = TuiKeyEvent(code: TuiKeyCode.ctrlC);
      const ctrlZEvent = TuiKeyEvent(code: TuiKeyCode.ctrlZ);

      expect(ctrlCEvent.code, equals(TuiKeyCode.ctrlC));
      expect(ctrlZEvent.code, equals(TuiKeyCode.ctrlZ));
      expect(ctrlCEvent.isPrintable, isFalse);
      expect(ctrlZEvent.isPrintable, isFalse);
    });

    test('arrow key events work', () {
      const upEvent = TuiKeyEvent(code: TuiKeyCode.arrowUp);
      const downEvent = TuiKeyEvent(code: TuiKeyCode.arrowDown);
      const leftEvent = TuiKeyEvent(code: TuiKeyCode.arrowLeft);
      const rightEvent = TuiKeyEvent(code: TuiKeyCode.arrowRight);

      expect(upEvent.code, equals(TuiKeyCode.arrowUp));
      expect(downEvent.code, equals(TuiKeyCode.arrowDown));
      expect(leftEvent.code, equals(TuiKeyCode.arrowLeft));
      expect(rightEvent.code, equals(TuiKeyCode.arrowRight));
    });
  });

  group('TuiResizeEvent', () {
    test('equality works correctly', () {
      const event1 = TuiResizeEvent(80, 24);
      const event2 = TuiResizeEvent(80, 24);
      const event3 = TuiResizeEvent(100, 24);

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });

    test('stores zero dimensions', () {
      const event = TuiResizeEvent(0, 0);

      expect(event.width, equals(0));
      expect(event.height, equals(0));
    });

    test('stores large dimensions', () {
      const event = TuiResizeEvent(1920, 1080);

      expect(event.width, equals(1920));
      expect(event.height, equals(1080));
    });
  });

  group('Event inheritance', () {
    test('all events extend TuiEvent', () {
      final tickEvent = TuiTickEvent(DateTime.now());
      const resizeEvent = TuiResizeEvent(80, 24);
      const keyEvent = TuiKeyEvent(code: TuiKeyCode.enter);

      expect(tickEvent, isA<TuiEvent>());
      expect(resizeEvent, isA<TuiEvent>());
      expect(keyEvent, isA<TuiEvent>());
    });
  });
}
