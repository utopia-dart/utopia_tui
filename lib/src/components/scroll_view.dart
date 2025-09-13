import '../core/canvas.dart';
import '../core/events.dart';
import '../core/interactive.dart';
import '../core/rect.dart';
import '../core/bindings.dart';
import 'text_input.dart';
import 'list_menu.dart';
import 'composition.dart';

class TuiScrollView {
  List<String> _lines = const [];
  int offset = 0;
  bool softWrap = false;

  void setText(String text) {
    _lines = text.split(RegExp(r"\r?\n"));
    offset = 0;
  }

  void setLines(List<String> lines) {
    _lines = List<String>.from(lines);
    offset = 0;
  }

  void scrollBy(int delta, int viewHeight) {
    final maxOffset = (_lines.length - viewHeight).clamp(0, 1 << 30);
    offset = (offset + delta).clamp(0, maxOffset);
  }

  void scrollPage(int viewHeight, {bool down = true}) {
    scrollBy(down ? viewHeight : -viewHeight, viewHeight);
  }

  void scrollTop() => offset = 0;
  void scrollBottom(int viewHeight) {
    final maxOffset = (_lines.length - viewHeight).clamp(0, 1 << 30);
    offset = maxOffset;
  }

  List<String> render(int width, int height) {
    final src = softWrap ? _wrap(_lines, width) : _lines;
    final out = <String>[];
    for (var i = 0; i < height; i++) {
      final idx = offset + i;
      final line = (idx >= 0 && idx < src.length) ? src[idx] : '';
      out.add(line);
    }
    return out;
  }

  List<String> _wrap(List<String> lines, int width) {
    if (width <= 0) return lines;
    final out = <String>[];
    for (final l in lines) {
      if (l.length <= width) {
        out.add(l);
      } else {
        var start = 0;
        while (start < l.length) {
          final end = (start + width) > l.length ? l.length : (start + width);
          out.add(l.substring(start, end));
          start = end;
        }
      }
    }
    return out;
  }
}

/// Enhanced scroll view with input mode
class TuiInteractiveScrollView extends TuiInteractiveComponent {
  final TuiScrollView scrollView;
  bool _scrollMode = false;
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
        return true;
      }

      // Handle scroll mode inputs
      if (_scrollMode) {
        switch (ch) {
          case 'j': // Scroll down
            scrollView.scrollBy(1, 20); // assuming content height of 20
            return true;
          case 'k': // Scroll up
            scrollView.scrollBy(-1, 20);
            return true;
          case 'h': // Scroll left (if applicable)
            // Could implement horizontal scrolling here
            return true;
          case 'l': // Scroll right (if applicable)
            // Could implement horizontal scrolling here
            return true;
          case 'g': // Go to top
            scrollView.scrollTop();
            return true;
        }
      }
    }

    // Handle special keys in scroll mode
    if (event is TuiKeyEvent && _scrollMode) {
      switch (event.code) {
        case TuiKeyCode.arrowUp:
          scrollView.scrollBy(-1, 20);
          return true;
        case TuiKeyCode.arrowDown:
          scrollView.scrollBy(1, 20);
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
  String get focusHint =>
      _scrollMode ? 'SCROLL MODE: j/k↕ h/l↔ g=top e=exit' : 'e=scroll mode';

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    TuiScrollViewView(scrollView).paintSurface(surface, rect);
  }
}

/// Enhanced text input with input mode
class TuiInteractiveTextInput extends TuiInteractiveComponent {
  final TuiTextInput textInput;
  bool _editMode = false;
  bool get editMode => _editMode;

  TuiInteractiveTextInput(this.textInput);

  @override
  bool handleInput(TuiEvent event) {
    if (!focused) return false;

    if (event is TuiKeyEvent && event.isPrintable) {
      final ch = event.char!.toLowerCase();

      // Toggle edit mode with 'e'
      if (ch == 'e') {
        _editMode = !_editMode;
        return true;
      }

      // Handle edit mode inputs
      if (_editMode) {
        TuiBindings.textEdit(event, textInput);
        return true;
      }
    }

    // Handle special keys in edit mode
    if (event is TuiKeyEvent && _editMode) {
      switch (event.code) {
        case TuiKeyCode.backspace:
          textInput.backspace();
          return true;
        case TuiKeyCode.delete:
          textInput.del();
          return true;
        case TuiKeyCode.escape:
          _editMode = false;
          return true;
        default:
          break;
      }
    }

    return false;
  }

  @override
  String get focusHint =>
      _editMode ? 'EDIT MODE: type text, ESC=exit' : 'e=edit mode';

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    TuiTextInputView(textInput).paintSurface(surface, rect);
  }
}

/// Interactive menu with navigation
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
          return true;
        case 'k':
          menu.moveUp();
          return true;
      }
    }

    if (event is TuiKeyEvent) {
      switch (event.code) {
        case TuiKeyCode.arrowUp:
          menu.moveUp();
          return true;
        case TuiKeyCode.arrowDown:
          menu.moveDown();
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
