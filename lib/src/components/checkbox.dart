import '../core/style.dart';
import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';

class TuiCheckbox extends TuiComponent {
  bool value;
  final String label;
  final TuiStyle? labelStyle;
  final TuiStyle? boxStyle;

  TuiCheckbox({
    this.value = false,
    this.label = '',
    this.labelStyle,
    this.boxStyle,
  });

  void toggle() => value = !value;

  String render(int width) {
    var box = value ? '[x]' : '[ ]';
    if (boxStyle != null) box = boxStyle!.apply(box);
    var text = labelStyle != null ? labelStyle!.apply(label) : label;
    final line = '$box $text';
    return line.length > width
        ? line.substring(0, width)
        : line.padRight(width);
  }

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final box = value ? '[x]' : '[ ]';
    final effectiveBoxStyle = boxStyle ?? const TuiStyle();
    final effectiveLabelStyle = labelStyle ?? const TuiStyle();

    // Draw checkbox
    surface.putTextClip(rect.x, rect.y, box, 3, style: effectiveBoxStyle);

    // Draw label if there's space
    if (label.isNotEmpty && rect.width > 4) {
      surface.putTextClip(
        rect.x + 4,
        rect.y,
        label,
        rect.width - 4,
        style: effectiveLabelStyle,
      );
    }
  }
}
