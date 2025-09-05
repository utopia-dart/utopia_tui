import '../core/theme.dart';

class TuiPanel {
  final String title;
  final TuiTheme theme;
  TuiPanel({this.title = '', TuiTheme? theme}) : theme = theme ?? const TuiTheme();

  List<String> wrap(List<String> contentLines, int width, int height) {
    // Simple box drawing: top/bottom borders and vertical edges
    final w = width;
    final h = height;
    final out = <String>[];
    final topTitle = title.isEmpty ? '' : ' $title ';
    final b = theme.border;
    final top = '${b.topLeft}$topTitle${b.horizontal * (w - 2 - topTitle.length)}${b.topRight}';
    out.add(top.substring(0, w));
    final innerHeight = h - 2;
    for (var i = 0; i < innerHeight; i++) {
      final line = i < contentLines.length ? contentLines[i] : '';
      final padded = line.padRight(w - 2).substring(0, w - 2);
      out.add('${b.vertical}$padded${b.vertical}');
    }
    out.add(('${b.bottomLeft}${b.horizontal * (w - 2)}${b.bottomRight}').substring(0, w));
    return out;
  }
}
