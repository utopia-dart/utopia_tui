import '../core/style.dart';
import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';

class TuiStatusBar {
  final TuiStyle? style;
  TuiStatusBar({this.style});

  String render(
    int width, {
    String left = '',
    String center = '',
    String right = '',
  }) {
    final l = left;
    final r = right;
    final remaining = (width - l.length - r.length).clamp(0, width);
    var c = center;
    if (c.length > remaining) c = c.substring(0, remaining);
    final leftPad = (remaining - c.length) ~/ 2;
    final rightPad = remaining - c.length - leftPad;
    var line = '$l${' ' * leftPad}$c${' ' * rightPad}$r';
    if (line.length < width) line = line.padRight(width);
    if (line.length > width) line = line.substring(0, width);
    return style?.apply(line) ?? line;
  }
}

/// Surface-based status bar component for the new rendering system
class TuiStatusBarView extends TuiComponent {
  final TuiStyle? style;
  final String left;
  final String center;
  final String right;

  TuiStatusBarView({
    this.style,
    this.left = '',
    this.center = '',
    this.right = '',
  });

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final l = left;
    final r = right;
    final remaining = (rect.width - l.length - r.length).clamp(0, rect.width);
    var c = center;
    if (c.length > remaining) c = c.substring(0, remaining);

    final leftPad = (remaining - c.length) ~/ 2;

    final effectiveStyle = style ?? const TuiStyle();

    // Draw left text
    if (l.isNotEmpty) {
      surface.putTextClip(rect.x, rect.y, l, l.length, style: effectiveStyle);
    }

    // Draw center text with padding
    final centerStart = rect.x + l.length + leftPad;
    if (c.isNotEmpty && centerStart < rect.right) {
      surface.putTextClip(
        centerStart,
        rect.y,
        c,
        c.length,
        style: effectiveStyle,
      );
    }

    // Draw right text
    final rightStart = rect.x + rect.width - r.length;
    if (r.isNotEmpty && rightStart >= rect.x + l.length) {
      surface.putTextClip(
        rightStart,
        rect.y,
        r,
        r.length,
        style: effectiveStyle,
      );
    }

    // Fill any gaps with background
    for (int x = rect.x + l.length; x < centerStart && x < rect.right; x++) {
      surface.putChar(x, rect.y, ' ', style: effectiveStyle);
    }
    for (
      int x = centerStart + c.length;
      x < rightStart && x < rect.right;
      x++
    ) {
      surface.putChar(x, rect.y, ' ', style: effectiveStyle);
    }
  }
}
