import '../core/style.dart';
import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';

class TuiCheckbox {
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
}

/// Surface-based checkbox component for the new rendering system
class TuiCheckboxView extends TuiComponent {
  final TuiCheckbox checkbox;

  TuiCheckboxView(this.checkbox);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final box = checkbox.value ? '[x]' : '[ ]';
    final boxStyle = checkbox.boxStyle ?? const TuiStyle();
    final labelStyle = checkbox.labelStyle ?? const TuiStyle();

    // Draw checkbox
    surface.putTextClip(rect.x, rect.y, box, 3, style: boxStyle);

    // Draw label if there's space
    if (checkbox.label.isNotEmpty && rect.width > 4) {
      surface.putTextClip(
        rect.x + 4,
        rect.y,
        checkbox.label,
        rect.width - 4,
        style: labelStyle,
      );
    }
  }
}
