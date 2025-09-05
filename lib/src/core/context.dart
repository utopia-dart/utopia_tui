import 'terminal.dart';

/// Build context that draws into an in-memory frame buffer.
class TuiContext {
  final TuiTerminalInterface terminal;
  late final int width;
  late final int height;
  late final List<List<int>> _buf; // rows of code units

  TuiContext(this.terminal) {
    width = terminal.width;
    height = terminal.height;
    _buf = List.generate(height, (_) => List<int>.filled(width, 32)); // space
  }

  /// Clear the backing buffer to spaces.
  void clear() {
    for (var r = 0; r < height; r++) {
      final row = _buf[r];
      for (var c = 0; c < width; c++) {
        row[c] = 32;
      }
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

  /// Writes exactly [w] characters at [row],[col], padding/clipping as needed.
  void writeRow(int row, int col, int w, String text) {
    if (row < 0 || row >= height || col >= width) return;
    final widthToWrite = (w).clamp(0, width - col);
    for (var i = 0; i < widthToWrite; i++) {
      final x = col + i;
      if (x < 0 || x >= width) continue;
      _buf[row][x] = 32;
    }
    final clipped = text.length > widthToWrite ? text.substring(0, widthToWrite) : text;
    writeAt(row, col, clipped);
  }

  /// Returns an immutable snapshot of the buffer as full-width lines.
  List<String> snapshot() => List<String>.generate(
        height,
        (r) => String.fromCharCodes(_buf[r]),
        growable: false,
      );
}
