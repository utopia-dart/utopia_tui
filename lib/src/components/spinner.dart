import '../core/style.dart';
import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';

class TuiSpinner {
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
}

/// Surface-based spinner component for the new rendering system
class TuiSpinnerView extends TuiComponent {
  final TuiSpinner spinner;

  TuiSpinnerView(this.spinner);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final frame = spinner.frames[spinner.index];
    final style = spinner.style ?? const TuiStyle();

    // Draw the spinner frame
    surface.putTextClip(rect.x, rect.y, frame, rect.width, style: style);
  }
}
