import '../core/style.dart';

class TuiStatusBar {
  final TuiStyle? style;
  TuiStatusBar({this.style});

  String render(int width, {String left = '', String center = '', String right = ''}) {
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

