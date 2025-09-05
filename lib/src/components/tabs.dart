import '../core/style.dart';

class TuiTabs {
  final List<String> tabs;
  int index;
  final TuiStyle? activeStyle;
  final TuiStyle? inactiveStyle;
  final String separator;

  TuiTabs(this.tabs, {this.index = 0, this.activeStyle, this.inactiveStyle, this.separator = '  '});

  String render(int width, {bool focused = false}) {
    final parts = <String>[];
    for (var i = 0; i < tabs.length; i++) {
      final label = ' ${tabs[i]} ';
      if (i == index) {
        final base = activeStyle ?? const TuiStyle();
        final effective = focused ? base.merge(const TuiStyle(underline: true)) : base;
        parts.add(effective.apply(label));
      } else {
        parts.add(inactiveStyle?.apply(label) ?? label);
      }
    }
    final line = parts.join(separator);
    return line.length > width ? line.substring(0, width) : line.padRight(width);
  }
}
