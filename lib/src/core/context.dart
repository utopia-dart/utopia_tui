import 'terminal.dart';
import 'style.dart';

/// Build context that draws into an in-memory frame buffer.
class TuiContext {
  final TuiTerminalInterface terminal;
  late final int width;
  late final int height;
  late final List<List<int>> _buf; // visible chars
  late final List<List<_RowSeg>> _rowSegs; // styled segments

  TuiContext(this.terminal) {
    width = terminal.width;
    height = terminal.height;
    _buf = List.generate(height, (_) => List<int>.filled(width, 32));
    _rowSegs = List.generate(height, (_) => <_RowSeg>[]);
  }

  /// Clear the backing buffer to spaces.
  void clear() {
    for (var r = 0; r < height; r++) {
      final row = _buf[r];
      for (var c = 0; c < width; c++) {
        row[c] = 32;
      }
      _rowSegs[r].clear();
    }
  }

  /// Writes text at [row],[col]. Clips to the screen width.
  void writeAt(int row, int col, String text) {
    if (row < 0 || row >= height || col >= width) return;
    final codes = text.codeUnits;
    for (var i = 0; i < codes.length; i++) {
      final x = col + i;
      if (x < 0 || x >= width) break;
      _buf[row][x] = codes[i];
    }
  }

  /// Writes exactly [w] visible characters at [row],[col], padding/clipping as needed.
  /// ANSI styling is preserved in output, but not counted towards width.
  void writeRow(int row, int col, int w, String text) {
    if (row < 0 || row >= height || col >= width) return;
    final widthToWrite = (w).clamp(0, width - col);
    // Build visible content
    final visible = tuiStripAnsi(text);
    final padded = visible.length >= widthToWrite
        ? visible.substring(0, widthToWrite)
        : visible.padRight(widthToWrite);
    // Update visible buffer
    final codes = padded.codeUnits;
    for (var i = 0; i < widthToWrite; i++) {
      final x = col + i;
      if (x < 0 || x >= width) continue;
      _buf[row][x] = codes[i];
    }
    // Store styled segment clipped to visible width
    final styled = tuiClipAnsi(text, widthToWrite);
    final seg = _RowSeg(col: col, width: widthToWrite, visible: padded, styled: styled);
    final list = _rowSegs[row];
    // remove overlapping segments
    list.removeWhere((s) => _rangesOverlap(s.col, s.col + s.width, col, col + widthToWrite));
    list.add(seg);
    list.sort((a, b) => a.col.compareTo(b.col));
  }

  /// Returns an immutable snapshot of the visible buffer as full-width lines.
  List<String> snapshot() => List<String>.generate(
        height,
        (r) => String.fromCharCodes(_buf[r]),
        growable: false,
      );

  /// Returns a styled snapshot assembled from written segments.
  List<String> snapshotStyled() {
    final lines = <String>[];
    for (var r = 0; r < height; r++) {
      final segs = _rowSegs[r];
      final buf = StringBuffer();
      var cursor = 0;
      for (final s in segs) {
        if (s.col > cursor) {
          buf.write(' ' * (s.col - cursor));
          cursor = s.col;
        }
        buf.write(s.styled);
        cursor += s.width;
      }
      if (cursor < width) {
        buf.write(' ' * (width - cursor));
      }
      lines.add(buf.toString());
    }
    return lines;
  }
}

class _RowSeg {
  final int col;
  final int width; // visible width
  final String visible;
  final String styled;
  _RowSeg({required this.col, required this.width, required this.visible, required this.styled});
}

bool _rangesOverlap(int aStart, int aEnd, int bStart, int bEnd) {
  return aStart < bEnd && bStart < aEnd;
}
