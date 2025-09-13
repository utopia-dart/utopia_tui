import '../core/interactive.dart';
import '../core/canvas.dart';
import '../core/rect.dart';
import '../core/events.dart';
import 'scroll_view.dart';
import 'scroll_view_view.dart';

/// Interactive scroll view with enhanced input handling
class TuiInteractiveScrollView extends TuiInteractiveComponent {
  final TuiScrollView scrollView;
  bool _scrollMode = false;
  int _lastViewHeight = 20; // Track the last known viewport height
  int _lastViewWidth = 80; // Track the last known viewport width

  /// Whether the scroll view is in scroll mode (accepting scroll input)
  bool get scrollMode => _scrollMode;

  TuiInteractiveScrollView(this.scrollView);

  @override
  bool handleInput(TuiEvent event) {
    if (!focused) return false;

    if (event is TuiKeyEvent && event.isPrintable) {
      final ch = event.char!.toLowerCase();

      // Toggle scroll mode with 'e'
      if (ch == 'e') {
        _scrollMode = !_scrollMode;
        markNeedsRebuild();
        return true;
      }

      // Handle scroll mode inputs
      if (_scrollMode) {
        switch (ch) {
          case 'j': // Scroll down
            scrollView.scrollBy(1, _lastViewHeight, _lastViewWidth);
            markNeedsRebuild();
            return true;
          case 'k': // Scroll up
            scrollView.scrollBy(-1, _lastViewHeight, _lastViewWidth);
            markNeedsRebuild();
            return true;
          case 'h': // Scroll left
            // Could implement horizontal scrolling here
            return true;
          case 'l': // Scroll right
            // Could implement horizontal scrolling here
            return true;
          case 'g': // Go to top
            scrollView.scrollTop();
            markNeedsRebuild();
            return true;
          case 'G': // Go to bottom (capital G)
            scrollView.scrollBottom(_lastViewHeight, _lastViewWidth);
            markNeedsRebuild();
            return true;
        }
      }
    }

    // Handle arrow keys in scroll mode
    if (event is TuiKeyEvent && _scrollMode) {
      switch (event.code) {
        case TuiKeyCode.arrowUp:
          scrollView.scrollBy(-1, _lastViewHeight, _lastViewWidth);
          markNeedsRebuild();
          return true;
        case TuiKeyCode.arrowDown:
          scrollView.scrollBy(1, _lastViewHeight, _lastViewWidth);
          markNeedsRebuild();
          return true;
        case TuiKeyCode.arrowLeft:
          // Horizontal scroll left
          return true;
        case TuiKeyCode.arrowRight:
          // Horizontal scroll right
          return true;
        default:
          break;
      }
    }

    return false;
  }

  @override
  String get focusHint => _scrollMode
      ? 'SCROLL MODE: j/k↕ h/l↔ g/G top/bottom e=exit'
      : 'e=scroll mode';

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    _lastViewHeight = rect.height; // Update the viewport height
    _lastViewWidth = rect.width; // Update the viewport width
    TuiScrollViewView(scrollView).paintSurface(surface, rect);
  }
}
