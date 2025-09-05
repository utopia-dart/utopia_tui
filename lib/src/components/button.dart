import '../core/style.dart';
import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';

class TuiButton {
  final String label;
  bool focused;
  final TuiStyle? normalStyle;
  final TuiStyle? focusedStyle;

  TuiButton(
    this.label, {
    this.focused = false,
    this.normalStyle,
    this.focusedStyle,
  });

  String render(int width) {
    final base = ' $label ';
    final styled = focused
        ? (focusedStyle?.apply(base) ?? base)
        : (normalStyle?.apply(base) ?? base);
    return styled.length > width
        ? styled.substring(0, width)
        : styled.padRight(width);
  }
}

/// Surface-based button component for the new rendering system
class TuiButtonView extends TuiComponent {
  final TuiButton button;

  TuiButtonView(this.button);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final text = ' ${button.label} ';
    final style = button.focused
        ? (button.focusedStyle ?? const TuiStyle())
        : (button.normalStyle ?? const TuiStyle());

    // Center the button text or left-align if it doesn't fit
    final startX = text.length < rect.width
        ? rect.x + (rect.width - text.length) ~/ 2
        : rect.x;

    surface.putTextClip(startX, rect.y, text, rect.width, style: style);
  }
}
