import 'package:test/test.dart';
import 'package:utopia_tui/utopia_tui.dart';

class _FakeComponent extends TuiInteractiveComponent {
  final String name;
  _FakeComponent(this.name);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {}

  @override
  String toString() => 'Fake($name)';
}

void main() {
  group('TuiFocusManager', () {
    late _FakeComponent a, b, c;

    setUp(() {
      a = _FakeComponent('a');
      b = _FakeComponent('b');
      c = _FakeComponent('c');
    });

    test('initial focus goes to first leaf', () {
      final fm = TuiFocusManager(
        root: TuiFocusNode.column(
          children: [
            TuiFocusNode.leaf(id: 'a', component: a),
            TuiFocusNode.leaf(id: 'b', component: b),
          ],
        ),
      );

      expect(fm.focusedId, 'a');
      expect(a.focused, true);
      expect(b.focused, false);
    });

    test('move down in column', () {
      final fm = TuiFocusManager(
        root: TuiFocusNode.column(
          children: [
            TuiFocusNode.leaf(id: 'a', component: a),
            TuiFocusNode.leaf(id: 'b', component: b),
          ],
        ),
      );

      final moved = fm.move(FocusDirection.down);
      expect(moved, true);
      expect(fm.focusedId, 'b');
      expect(a.focused, false);
      expect(b.focused, true);
    });

    test('move up in column', () {
      final fm = TuiFocusManager(
        root: TuiFocusNode.column(
          children: [
            TuiFocusNode.leaf(id: 'a', component: a),
            TuiFocusNode.leaf(id: 'b', component: b),
          ],
        ),
      );

      fm.move(FocusDirection.down);
      final moved = fm.move(FocusDirection.up);
      expect(moved, true);
      expect(fm.focusedId, 'a');
    });

    test('move left/right in row', () {
      final fm = TuiFocusManager(
        root: TuiFocusNode.row(
          children: [
            TuiFocusNode.leaf(id: 'a', component: a),
            TuiFocusNode.leaf(id: 'b', component: b),
          ],
        ),
      );

      expect(fm.focusedId, 'a');
      fm.move(FocusDirection.right);
      expect(fm.focusedId, 'b');
      fm.move(FocusDirection.left);
      expect(fm.focusedId, 'a');
    });

    test('cannot move past boundaries', () {
      final fm = TuiFocusManager(
        root: TuiFocusNode.column(
          children: [
            TuiFocusNode.leaf(id: 'a', component: a),
            TuiFocusNode.leaf(id: 'b', component: b),
          ],
        ),
      );

      expect(fm.move(FocusDirection.up), false);
      expect(fm.focusedId, 'a');

      fm.move(FocusDirection.down);
      expect(fm.move(FocusDirection.down), false);
      expect(fm.focusedId, 'b');
    });

    test('wrong axis does not move', () {
      final fm = TuiFocusManager(
        root: TuiFocusNode.column(
          children: [
            TuiFocusNode.leaf(id: 'a', component: a),
            TuiFocusNode.leaf(id: 'b', component: b),
          ],
        ),
      );

      expect(fm.move(FocusDirection.left), false);
      expect(fm.move(FocusDirection.right), false);
      expect(fm.focusedId, 'a');
    });

    test('nested tree: column > row navigation', () {
      final fm = TuiFocusManager(
        root: TuiFocusNode.column(
          children: [
            TuiFocusNode.leaf(id: 'tabs', component: a),
            TuiFocusNode.row(
              children: [
                TuiFocusNode.leaf(id: 'menu', component: b),
                TuiFocusNode.leaf(id: 'content', component: c),
              ],
            ),
          ],
        ),
      );

      expect(fm.focusedId, 'tabs');

      fm.move(FocusDirection.down);
      expect(fm.focusedId, 'menu');

      fm.move(FocusDirection.right);
      expect(fm.focusedId, 'content');

      fm.move(FocusDirection.up);
      expect(fm.focusedId, 'tabs');
    });

    test('focusById', () {
      final fm = TuiFocusManager(
        root: TuiFocusNode.column(
          children: [
            TuiFocusNode.leaf(id: 'a', component: a),
            TuiFocusNode.row(
              children: [
                TuiFocusNode.leaf(id: 'b', component: b),
                TuiFocusNode.leaf(id: 'c', component: c),
              ],
            ),
          ],
        ),
      );

      fm.focusById('c');
      expect(fm.focusedId, 'c');
      expect(c.focused, true);
      expect(a.focused, false);
    });

    test('focusNext cycles through all leaves', () {
      final fm = TuiFocusManager(
        root: TuiFocusNode.column(
          children: [
            TuiFocusNode.leaf(id: 'a', component: a),
            TuiFocusNode.row(
              children: [
                TuiFocusNode.leaf(id: 'b', component: b),
                TuiFocusNode.leaf(id: 'c', component: c),
              ],
            ),
          ],
        ),
      );

      expect(fm.focusedId, 'a');
      fm.focusNext();
      expect(fm.focusedId, 'b');
      fm.focusNext();
      expect(fm.focusedId, 'c');
      fm.focusNext();
      expect(fm.focusedId, 'a');
    });

    test('focusPrev cycles backwards', () {
      final fm = TuiFocusManager(
        root: TuiFocusNode.column(
          children: [
            TuiFocusNode.leaf(id: 'a', component: a),
            TuiFocusNode.leaf(id: 'b', component: b),
          ],
        ),
      );

      expect(fm.focusedId, 'a');
      fm.focusPrev();
      expect(fm.focusedId, 'b');
      fm.focusPrev();
      expect(fm.focusedId, 'a');
    });

    test('single leaf focus manager', () {
      final fm = TuiFocusManager(
        root: TuiFocusNode.leaf(id: 'only', component: a),
      );

      expect(fm.focusedId, 'only');
      expect(fm.move(FocusDirection.up), false);
      expect(fm.move(FocusDirection.down), false);
      expect(fm.focusedId, 'only');
    });

    test('move up from nested row bubbles to parent column', () {
      final fm = TuiFocusManager(
        root: TuiFocusNode.column(
          children: [
            TuiFocusNode.leaf(id: 'top', component: a),
            TuiFocusNode.row(
              children: [
                TuiFocusNode.leaf(id: 'left', component: b),
                TuiFocusNode.leaf(id: 'right', component: c),
              ],
            ),
          ],
        ),
      );

      fm.focusById('right');
      expect(fm.focusedId, 'right');

      fm.move(FocusDirection.up);
      expect(fm.focusedId, 'top');
    });
  });
}
