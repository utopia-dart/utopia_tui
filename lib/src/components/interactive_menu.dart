import '../core/interactive.dart';
import '../core/canvas.dart';
import '../core/rect.dart';
import '../core/events.dart';
import 'list_menu.dart';
import 'list_view.dart';

/// Interactive menu with enhanced navigation
class TuiInteractiveMenu extends TuiInteractiveComponent {
  final TuiList menu;

  TuiInteractiveMenu(this.menu);

  @override
  bool handleInput(TuiEvent event) {
    if (!focused) return false;

    if (event is TuiKeyEvent && event.isPrintable) {
      final ch = event.char!.toLowerCase();
      switch (ch) {
        case 'j':
          menu.moveDown();
          markNeedsRebuild();
          return true;
        case 'k':
          menu.moveUp();
          markNeedsRebuild();
          return true;
      }
    }

    if (event is TuiKeyEvent) {
      switch (event.code) {
        case TuiKeyCode.arrowUp:
          menu.moveUp();
          markNeedsRebuild();
          return true;
        case TuiKeyCode.arrowDown:
          menu.moveDown();
          markNeedsRebuild();
          return true;
        default:
          break;
      }
    }

    return false;
  }

  @override
  String get focusHint => 'j/k or ↑↓ to navigate';

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    TuiListView(menu).paintSurface(surface, rect);
  }
}
