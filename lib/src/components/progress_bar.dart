import '../core/style.dart';
import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';

class TuiProgressBar {
  double value; // 0.0 .. 1.0
  final TuiStyle? barStyle;
  final TuiStyle? fillStyle;
  final String fillChar;
  final String emptyChar;
  TuiProgressBar({
    this.value = 0,
    this.barStyle,
    this.fillStyle,
    this.fillChar = '█',
    this.emptyChar = ' ',
  });

  String render(int width) {
    final inner = (width - 2).clamp(1, 1000);
    final filled = (value.clamp(0, 1) * inner).round();
    final fill = (fillChar * filled) + (emptyChar * (inner - filled));
    var bar = '[$fill]';
    if (fillStyle != null) {
      final styledFill = fillStyle!.apply(
        (fillChar * filled) + (emptyChar * (inner - filled)),
      );
      bar = '[$styledFill]';
    }
    if (barStyle != null) bar = barStyle!.apply(bar);
    return bar;
  }
}

/// Surface-based progress bar component for the new rendering system
class TuiProgressBarView extends TuiComponent {
  final TuiProgressBar progressBar;

  TuiProgressBarView(this.progressBar);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty || rect.width < 3) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    // Calculate fill
    final inner = (rect.width - 2).clamp(1, rect.width - 2);
    final filled = (progressBar.value.clamp(0, 1) * inner).round();
    final empty = inner - filled;

    // Draw opening bracket
    final barStyle = progressBar.barStyle ?? const TuiStyle();
    surface.putChar(rect.x, rect.y, '[', style: barStyle);

    // Draw filled portion
    final fillStyle = progressBar.fillStyle ?? const TuiStyle();
    for (int i = 0; i < filled; i++) {
      surface.putChar(
        rect.x + 1 + i,
        rect.y,
        progressBar.fillChar,
        style: fillStyle,
      );
    }

    // Draw empty portion
    for (int i = 0; i < empty; i++) {
      surface.putChar(
        rect.x + 1 + filled + i,
        rect.y,
        progressBar.emptyChar,
        style: fillStyle,
      );
    }

    // Draw closing bracket
    surface.putChar(rect.x + rect.width - 1, rect.y, ']', style: barStyle);
  }
}
