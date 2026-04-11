import '../core/style.dart';
import '../core/interactive.dart';
import '../core/canvas.dart';
import '../core/rect.dart';
import '../core/events.dart';

class TuiTabs extends TuiInteractiveComponent {
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
    bool focused = false,
  }) {
    this.focused = focused;
  }

  @override
  bool handleInput(TuiEvent event) {
    if (!focused) return false;

    if (event is TuiKeyEvent) {
      if (event.code == TuiKeyCode.arrowLeft ||
          (event.isPrintable && event.char == 'h')) {
        if (index > 0) {
          index--;
          markNeedsRebuild();
          return true;
        }
      }
      if (event.code == TuiKeyCode.arrowRight ||
          (event.isPrintable && event.char == 'l')) {
        if (index < tabs.length - 1) {
          index++;
          markNeedsRebuild();
          return true;
        }
      }
    }

    return false;
  }

  @override
  String get focusHint => 'h/l or ←→ to switch tabs';

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
        if (i < tabs.length - 1 && x + separator.length <= rect.right) {
          surface.putTextClip(x, rect.y, separator, separator.length);
          x += separator.length;
        }
      }
    }
  }
}
