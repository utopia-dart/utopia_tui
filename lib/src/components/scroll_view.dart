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
