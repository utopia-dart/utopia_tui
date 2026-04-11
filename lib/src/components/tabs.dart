import '../core/style.dart';
import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';

class TuiTabs extends TuiComponent {
  final List<String> tabs;
  int index;
  final TuiStyle? activeStyle;
  final TuiStyle? inactiveStyle;
  final String separator;
  bool focused;

  TuiTabs(
    this.tabs, {
    this.index = 0,
    this.activeStyle,
    this.inactiveStyle,
    this.separator = '  ',
    this.focused = false,
  });

  String render(int width, {bool focused = false}) {
    final parts = <String>[];
    for (var i = 0; i < tabs.length; i++) {
      final label = ' ${tabs[i]} ';
      if (i == index) {
        final base = activeStyle ?? const TuiStyle();
        final effective = focused
            ? base.merge(const TuiStyle(underline: true))
            : base;
        parts.add(effective.apply(label));
      } else {
        parts.add(inactiveStyle?.apply(label) ?? label);
      }
    }
    final line = parts.join(separator);
    return line.length > width
        ? line.substring(0, width)
        : line.padRight(width);
  }

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    // Render each tab with proper styling
    var x = rect.x;
    for (var i = 0; i < tabs.length && x < rect.right; i++) {
      final label = ' ${tabs[i]} ';

      TuiStyle style;
      if (i == index) {
        final base = activeStyle ?? const TuiStyle();
        style = focused ? base.merge(const TuiStyle(underline: true)) : base;
      } else {
        style = inactiveStyle ?? const TuiStyle();
      }

      // Put the tab text with style
      final tabWidth = label.length;
      if (x + tabWidth <= rect.right) {
        surface.putTextClip(x, rect.y, label, tabWidth, style: style);
        x += tabWidth;

        // Add separator if not the last tab
        if (i < tabs.length - 1 &&
            x + separator.length <= rect.right) {
          surface.putTextClip(x, rect.y, separator, separator.length);
          x += separator.length;
        }
      }
    }
  }
}
