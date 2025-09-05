import '../core/style.dart';

class TuiProgressBar {
  double value; // 0.0 .. 1.0
  final TuiStyle? barStyle;
  final TuiStyle? fillStyle;
  final String fillChar;
  final String emptyChar;
  TuiProgressBar({this.value = 0, this.barStyle, this.fillStyle, this.fillChar = '█', this.emptyChar = ' '});

  String render(int width) {
    final inner = (width - 2).clamp(1, 1000);
    final filled = (value.clamp(0, 1) * inner).round();
    final fill = (fillChar * filled) + (emptyChar * (inner - filled));
    var bar = '[$fill]';
    if (fillStyle != null) {
      final styledFill = fillStyle!.apply((fillChar * filled) + (emptyChar * (inner - filled)));
      bar = '[$styledFill]';
    }
    if (barStyle != null) bar = barStyle!.apply(bar);
    return bar;
  }
}
