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

      if (TuiSurface.displayWidth(line) <= width) {
        out.add(line);
      } else {
        final words = line.split(' ');
        var currentLine = '';
        var currentWidth = 0;

        for (final word in words) {
          final wordWidth = TuiSurface.displayWidth(word);
          if (currentLine.isEmpty) {
            if (wordWidth <= width) {
              currentLine = word;
              currentWidth = wordWidth;
            } else {
              _breakLongWord(word, width, out);
            }
          } else if (currentWidth + 1 + wordWidth <= width) {
            currentLine += ' $word';
            currentWidth += 1 + wordWidth;
          } else {
            out.add(currentLine);
            if (wordWidth <= width) {
              currentLine = word;
              currentWidth = wordWidth;
            } else {
              currentLine = '';
              currentWidth = 0;
              _breakLongWord(word, width, out);
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

  void _breakLongWord(String word, int width, List<String> out) {
    var buf = StringBuffer();
    var bufWidth = 0;
    for (final rune in word.runes) {
      final charWidth = TuiSurface.displayWidth(String.fromCharCode(rune));
      if (bufWidth + charWidth > width && bufWidth > 0) {
        out.add(buf.toString());
        buf = StringBuffer();
        bufWidth = 0;
      }
      buf.writeCharCode(rune);
      bufWidth += charWidth;
    }
    if (bufWidth > 0) {
      out.add(buf.toString());
    }
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
