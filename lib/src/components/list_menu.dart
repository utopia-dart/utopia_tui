import '../core/theme.dart';

class TuiList {
  final List<String> items;
  int selectedIndex;
  final TuiTheme theme;

  TuiList(this.items, {this.selectedIndex = 0, TuiTheme? theme})
      : theme = theme ?? const TuiTheme();

  void moveUp() {
    if (selectedIndex > 0) selectedIndex--;
  }

  void moveDown() {
    if (selectedIndex < items.length - 1) selectedIndex++;
  }

  List<String> render(int width, int height) {
    final out = <String>[];
    for (var i = 0; i < height; i++) {
      if (i < items.length) {
        final prefix = i == selectedIndex
            ? theme.listSelectedPrefix
            : theme.listUnselectedPrefix;
        final label = ' $prefix ${items[i]} ';
        out.add(label.padRight(width).substring(0, width));
      } else {
        out.add(''.padRight(width));
      }
    }
    return out;
  }
}
