import '../core/interactive.dart';
import '../core/canvas.dart';
import '../core/rect.dart';
import '../core/events.dart';

class TuiScrollView extends TuiInteractiveComponent {
  List<String> _lines = const [];
  int offset = 0;
  bool softWrap = true; // Enable soft wrap by default

  void setText(String text) {
    _lines = text.split(RegExp(r"\r?\n"));
    offset = 0;
  }

  void setLines(List<String> lines) {
    _lines = List<String>.from(lines);
    offset = 0;
  }

  void scrollBy(int delta, int viewHeight, [int viewWidth = 100]) {
    final src = softWrap
        ? _wrap(_lines, viewWidth)
        : _lines; // Use actual viewport width
    final maxOffset = (src.length - viewHeight).clamp(0, src.length);
    offset = (offset + delta).clamp(0, maxOffset);
  }

  void scrollPage(int viewHeight, [int viewWidth = 100, bool down = true]) {
    scrollBy(down ? viewHeight : -viewHeight, viewHeight, viewWidth);
  }

  void scrollTop() => offset = 0;
  void scrollBottom(int viewHeight, [int viewWidth = 100]) {
    final src = softWrap
        ? _wrap(_lines, viewWidth)
        : _lines; // Use actual viewport width
    final maxOffset = (src.length - viewHeight).clamp(0, src.length);
    offset = maxOffset;
  }

  bool scrollMode = false;
  int _lastViewHeight = 20;
  int _lastViewWidth = 80;

  @override
  bool handleInput(TuiEvent event) {
    if (!focused) return false;

    if (event is TuiKeyEvent) {
      if (event.code == TuiKeyCode.ctrlE) {
        scrollMode = !scrollMode;
        markNeedsRebuild();
        return true;
      }

      if (event.isPrintable) {
        final ch = event.char!.toLowerCase();

        if (ch == 'e') {
          scrollMode = !scrollMode;
          markNeedsRebuild();
          return true;
        }

        if (scrollMode) {
          switch (ch) {
            case 'j':
              scrollBy(1, _lastViewHeight, _lastViewWidth);
              markNeedsRebuild();
              return true;
            case 'k':
              scrollBy(-1, _lastViewHeight, _lastViewWidth);
              markNeedsRebuild();
              return true;
            case 'g':
              scrollTop();
              markNeedsRebuild();
              return true;
          }
        }
      }

      if (scrollMode) {
        switch (event.code) {
          case TuiKeyCode.arrowUp:
            scrollBy(-1, _lastViewHeight, _lastViewWidth);
            markNeedsRebuild();
            return true;
          case TuiKeyCode.arrowDown:
            scrollBy(1, _lastViewHeight, _lastViewWidth);
            markNeedsRebuild();
            return true;
          default:
            break;
        }
      }
    }

    return false;
  }

  @override
  String get focusHint =>
      scrollMode ? 'SCROLL MODE: j/k↕ g=top e/Ctrl+E=exit' : 'e=scroll mode';

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
    for (final line in lines) {
      if (line.isEmpty) {
        out.add('');
        continue;
      }

      if (line.length <= width) {
        out.add(line);
      } else {
        // Word wrapping
        final words = line.split(' ');
        var currentLine = '';

        for (final word in words) {
          if (currentLine.isEmpty) {
            if (word.length <= width) {
              currentLine = word;
            } else {
              // Word is longer than width, break it
              var start = 0;
              while (start < word.length) {
                final end = (start + width).clamp(0, word.length);
                out.add(word.substring(start, end));
                start = end;
              }
            }
          } else if (currentLine.length + 1 + word.length <= width) {
            currentLine += ' $word';
          } else {
            out.add(currentLine);
            if (word.length <= width) {
              currentLine = word;
            } else {
              // Word is longer than width, break it
              currentLine = '';
              var start = 0;
              while (start < word.length) {
                final end = (start + width).clamp(0, word.length);
                out.add(word.substring(start, end));
                start = end;
              }
            }
          }
        }

        if (currentLine.isNotEmpty) {
          out.add(currentLine);
        }
      }
    }
    return out;
  }

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;
    _lastViewHeight = rect.height;
    _lastViewWidth = rect.width;
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);
    final lines = render(rect.width, rect.height);
    for (var i = 0; i < rect.height && i < lines.length; i++) {
      surface.putTextClip(rect.x, rect.y + i, lines[i], rect.width);
    }
  }
}
