import '../core/theme.dart';
import '../core/style.dart';

class TuiList {
  final List<String> items;
  int selectedIndex;
  final TuiTheme theme;
  final TuiStyle? selectedStyle;
  final TuiStyle? unselectedStyle;

  TuiList(
    this.items, {
    this.selectedIndex = 0,
    TuiTheme? theme,
    this.selectedStyle,
    this.unselectedStyle,
  }) : theme = theme ?? const TuiTheme();

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
        final isSel = i == selectedIndex;
        final prefix = isSel
            ? theme.listSelectedPrefix
            : theme.listUnselectedPrefix;
        var label = ' $prefix ${items[i]} ';
        if (isSel && selectedStyle != null) label = selectedStyle!.apply(label);
        if (!isSel && unselectedStyle != null) {
          label = unselectedStyle!.apply(label);
        }
        out.add(label);
      } else {
        out.add('');
      }
    }
    return out;
  }
}
