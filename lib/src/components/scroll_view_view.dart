import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';
import 'scroll_view.dart';

/// View component for rendering TuiScrollView
class TuiScrollViewView extends TuiComponent {
  final TuiScrollView scroll;

  TuiScrollViewView(this.scroll);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final lines = scroll.render(rect.width, rect.height);
    for (var i = 0; i < rect.height && i < lines.length; i++) {
      surface.putTextClip(rect.x, rect.y + i, lines[i], rect.width);
    }
  }
}
