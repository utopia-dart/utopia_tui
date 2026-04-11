import '../core/style.dart';
import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';

class TuiButton extends TuiComponent {
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

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final text = ' $label ';
    final style = focused
        ? (focusedStyle ?? const TuiStyle())
        : (normalStyle ?? const TuiStyle());

    final startX = text.length < rect.width
        ? rect.x + (rect.width - text.length) ~/ 2
        : rect.x;

    surface.putTextClip(startX, rect.y, text, rect.width, style: style);
  }
}
