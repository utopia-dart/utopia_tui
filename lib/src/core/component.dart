import 'context.dart';
import 'events.dart';

/// Base component contract. Parents control layout; components draw into
/// the provided rectangle. Keep minimal for small footprint.
abstract class TuiComponent {
  void onEvent(TuiEvent event, TuiContext context) {}
  void paint(
    TuiContext context, {
    required int row,
    required int col,
    required int width,
    required int height,
  });
}

/// Stateless component base; implement [buildLines] to provide content lines.
abstract class TuiStatelessComponent extends TuiComponent {
  List<String> buildLines(TuiContext context, int width, int height);

  @override
  void paint(
    TuiContext context, {
    required int row,
    required int col,
    required int width,
    required int height,
  }) {
    final lines = buildLines(context, width, height);
    for (var i = 0; i < height; i++) {
      final text = i < lines.length ? lines[i] : '';
      context.writeRow(row + i, col, width, text);
    }
  }
}

/// Stateful component base with minimal state handling.
abstract class TuiStatefulComponent<S> extends TuiComponent {
  S state;
  TuiStatefulComponent(this.state);

  void setState(void Function(S s) updater) => updater(state);
}

