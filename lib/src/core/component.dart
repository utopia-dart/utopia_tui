import 'context.dart';
import 'events.dart';
import 'canvas.dart';
import 'rect.dart';

/// Base component contract. Components paint into a TuiRect on a TuiSurface
abstract class TuiComponent {
  void onEvent(TuiEvent event, TuiContext context) {}

  /// Paint this component into the given rect on the surface
  void paintSurface(TuiSurface surface, TuiRect rect);
}

/// Stateless component base; implement [buildLines] to provide content lines
abstract class TuiStatelessComponent extends TuiComponent {
  List<String> buildLines(TuiSurface surface, TuiRect rect);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area first
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final lines = buildLines(surface, rect);
    for (var i = 0; i < rect.height && i < lines.length; i++) {
      surface.putTextClip(rect.x, rect.y + i, lines[i], rect.width);
    }
  }
}

/// Stateful component base with minimal state handling
abstract class TuiStatefulComponent<S> extends TuiComponent {
  S state;
  TuiStatefulComponent(this.state);

  void setState(void Function(S s) updater) => updater(state);
}
