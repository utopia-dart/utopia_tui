import '../core/style.dart';
import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';

class TuiTabs {
  final List<String> tabs;
  int index;
  final TuiStyle? activeStyle;
  final TuiStyle? inactiveStyle;
  final String separator;

  TuiTabs(
    this.tabs, {
    this.index = 0,
    this.activeStyle,
    this.inactiveStyle,
    this.separator = '  ',
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
}

/// Surface-based tabs component for the new rendering system
class TuiTabsView extends TuiComponent {
  final TuiTabs tabs;
  final bool focused;

  TuiTabsView(this.tabs, {this.focused = false});

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    // Render each tab with proper styling
    var x = rect.x;
    for (var i = 0; i < tabs.tabs.length && x < rect.right; i++) {
      final label = ' ${tabs.tabs[i]} ';

      TuiStyle style;
      if (i == tabs.index) {
        final base = tabs.activeStyle ?? const TuiStyle();
        style = focused ? base.merge(const TuiStyle(underline: true)) : base;
      } else {
        style = tabs.inactiveStyle ?? const TuiStyle();
      }

      // Put the tab text with style
      final tabWidth = label.length;
      if (x + tabWidth <= rect.right) {
        surface.putTextClip(x, rect.y, label, tabWidth, style: style);
        x += tabWidth;

        // Add separator if not the last tab
        if (i < tabs.tabs.length - 1 &&
            x + tabs.separator.length <= rect.right) {
          surface.putTextClip(x, rect.y, tabs.separator, tabs.separator.length);
          x += tabs.separator.length;
        }
      }
    }
  }
}
