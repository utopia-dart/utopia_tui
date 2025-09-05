import '../core/theme.dart';
import '../core/style.dart';
import 'dart:math' as math;

class TuiPanel {
  final String title;
  final TuiTheme theme;
  final TuiStyle? titleStyle;
  final TuiStyle? borderStyle;
  TuiPanel({this.title = '', TuiTheme? theme, this.titleStyle, this.borderStyle})
      : theme = theme ?? const TuiTheme();

  List<String> wrap(List<String> contentLines, int width, int height) {
    // Simple box drawing: top/bottom borders and vertical edges
    final w = width;
    final h = height;
    final out = <String>[];
    final topTitle = title.isEmpty ? '' : ' $title ';
    final b = theme.border;
    final styledTitle = titleStyle?.apply(topTitle) ?? topTitle;
    final visTitleLen = tuiStripAnsi(styledTitle).length;
    final horizCount = math.max(0, w - 2 - visTitleLen);
    final horiz = b.horizontal * horizCount;
    var top = '${b.topLeft}$styledTitle$horiz${b.topRight}';
    if (borderStyle != null) top = borderStyle!.apply(top);
    out.add(top);
    final innerHeight = h - 2;
    for (var i = 0; i < innerHeight; i++) {
      final line = i < contentLines.length ? contentLines[i] : '';
      // ANSI-aware clip + pad to inner width
      final clipped = tuiClipAnsi(line, w - 2);
      final visLen = tuiStripAnsi(clipped).length;
      final pad = (w - 2 - visLen);
      final padded = '$clipped${' ' * pad}';
      var mid = '${b.vertical}$padded${b.vertical}';
      if (borderStyle != null) mid = borderStyle!.apply(mid);
      out.add(mid);
    }
    var bottom = '${b.bottomLeft}${b.horizontal * (w - 2)}${b.bottomRight}';
    if (borderStyle != null) bottom = borderStyle!.apply(bottom);
    out.add(bottom);
    return out;
  }
}
