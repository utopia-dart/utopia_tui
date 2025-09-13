class TuiScrollView {
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
}
