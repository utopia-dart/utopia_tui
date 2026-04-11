import '../core/style.dart';
import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';

class TuiSpinner extends TuiComponent {
  final List<String> frames;
  int index = 0;
  final TuiStyle? style;

  TuiSpinner({List<String>? frames, this.style})
    : frames =
          frames ?? const ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

  void tick() {
    index = (index + 1) % frames.length;
  }

  String render() {
    final s = frames[index];
    return style != null ? style!.apply(s) : s;
  }

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final frame = frames[index];
    final effectiveStyle = style ?? const TuiStyle();

    // Draw the spinner frame
    surface.putTextClip(
      rect.x,
      rect.y,
      frame,
      rect.width,
      style: effectiveStyle,
    );
  }
}
