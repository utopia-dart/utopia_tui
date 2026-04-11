import 'style.dart';

/// Represents a single character cell in the terminal with its styling.
///
/// Each cell contains a character (stored as a Unicode code point) and
/// associated styling information. This is the fundamental unit of the
/// terminal display system.
///
/// ## Usage
///
/// ```dart
/// // Create a styled character cell
/// final cell = TuiCell.fromChar('A', style: TuiStyle(fg: 1, bold: true));
///
/// // Create an empty cell
/// final empty = TuiCell.empty();
///
/// // Check cell properties
/// print(cell.char); // 'A'
/// print(cell.isEmpty); // false
/// ```
class TuiCell {
  /// The Unicode code point of the character in this cell.
  final int codePoint;

  /// The styling applied to this character.
  final TuiStyle style;

  /// Whether this cell is the trailing half of a wide (2-column) character.
  final bool wideContinuation;

  /// Creates a cell with the specified [codePoint] and optional [style].
  const TuiCell({
    required this.codePoint,
    this.style = const TuiStyle(),
    this.wideContinuation = false,
  });

  /// Creates a cell from a string [char] with optional [style].
  ///
  /// If [char] is empty, defaults to a space character (code point 32).
  /// If [char] has multiple characters, only the first rune is used.
  TuiCell.fromChar(String char, {this.style = const TuiStyle()})
    : codePoint = char.isNotEmpty ? char.runes.first : 32,
      wideContinuation = false;

  /// Creates an empty cell (space character) with optional [style].
  const TuiCell.empty({this.style = const TuiStyle()})
    : codePoint = 32,
      wideContinuation = false;

  /// The character as a string.
  String get char => String.fromCharCode(codePoint);

  /// Whether this cell contains a space character.
  bool get isEmpty => codePoint == 32;

  /// Creates a copy of this cell with a different [newStyle].
  TuiCell withStyle(TuiStyle newStyle) {
    return TuiCell(codePoint: codePoint, style: newStyle);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TuiCell &&
        other.codePoint == codePoint &&
        other.style == style &&
        other.wideContinuation == wideContinuation;
  }

  @override
  int get hashCode =>
      codePoint.hashCode ^ style.hashCode ^ wideContinuation.hashCode;
}

/// A 2D grid of character cells representing the terminal screen buffer.
///
/// The surface provides efficient character-based rendering operations
/// with automatic styling and clipping. It serves as the main drawing
/// canvas for all TUI components.
///
/// ## Key Features
///
/// - Character-level precision for terminal UIs
/// - Automatic ANSI escape sequence generation
/// - Efficient bulk operations and clipping
/// - Style inheritance and merging
///
/// ## Usage
///
/// ```dart
/// final surface = TuiSurface(width: 80, height: 24);
///
/// // Write text
/// surface.putText(0, 0, 'Hello World');
///
/// // Write styled text
/// surface.putText(0, 1, 'Error', style: TuiStyle(fg: 1));
///
/// // Get output lines
/// final lines = surface.toAnsiLines();
/// ```
class TuiSurface {
  /// Width of the surface in characters.
  final int width;

  /// Height of the surface in rows.
  final int height;

  late final List<List<TuiCell>> _grid;

  /// Creates a surface with the specified dimensions.
  ///
  /// The surface is initialized with empty cells (spaces with no styling).
  TuiSurface({required this.width, required this.height}) {
    _grid = List.generate(
      height,
      (row) => List.generate(width, (col) => const TuiCell.empty()),
    );
  }

  /// Get a cell at the specified position
  TuiCell getCell(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return const TuiCell.empty();
    }
    return _grid[y][x];
  }

  /// Set a cell at the specified position
  void setCell(int x, int y, TuiCell cell) {
    if (x < 0 || x >= width || y < 0 || y >= height) return;
    _grid[y][x] = cell;
  }

  /// Put a single character at the specified position
  void putChar(int x, int y, String char, {TuiStyle style = const TuiStyle()}) {
    if (char.isEmpty) return;
    setCell(x, y, TuiCell.fromChar(char, style: style));
  }

  /// Put text at the specified position, clipping to the surface bounds
  void putText(int x, int y, String text, {TuiStyle style = const TuiStyle()}) {
    var col = x;
    for (final rune in text.runes) {
      if (col >= width) break;
      final charWidth = _isWideChar(rune) ? 2 : 1;
      final ch = String.fromCharCode(rune);
      putChar(col, y, ch, style: style);
      if (charWidth == 2) {
        final nextCol = col + 1;
        if (nextCol < width) {
          setCell(
            nextCol,
            y,
            const TuiCell(codePoint: 32, wideContinuation: true),
          );
        }
      }
      col += charWidth;
    }
  }

  /// Put text clipped to a specific width, accounting for wide characters
  void putTextClip(
    int x,
    int y,
    String text,
    int maxWidth, {
    TuiStyle style = const TuiStyle(),
  }) {
    final limit = x + maxWidth;
    var col = x;
    for (final rune in text.runes) {
      if (col >= limit || col >= width) break;
      final charWidth = _isWideChar(rune) ? 2 : 1;
      if (col + charWidth > limit) break;
      final ch = String.fromCharCode(rune);
      putChar(col, y, ch, style: style);
      if (charWidth == 2) {
        final nextCol = col + 1;
        if (nextCol < width) {
          setCell(
            nextCol,
            y,
            const TuiCell(codePoint: 32, wideContinuation: true),
          );
        }
      }
      col += charWidth;
    }
  }

  /// Draw a horizontal line
  void hLine(
    int x,
    int y,
    int length,
    String char, {
    TuiStyle style = const TuiStyle(),
  }) {
    for (int i = 0; i < length; i++) {
      if (x + i >= width) break;
      putChar(x + i, y, char, style: style);
    }
  }

  /// Draw a vertical line
  void vLine(
    int x,
    int y,
    int length,
    String char, {
    TuiStyle style = const TuiStyle(),
  }) {
    for (int i = 0; i < length; i++) {
      if (y + i >= height) break;
      putChar(x, y + i, char, style: style);
    }
  }

  /// Fill a rectangle with a character
  void fillRect(
    int x,
    int y,
    int w,
    int h,
    String char, {
    TuiStyle style = const TuiStyle(),
  }) {
    for (int row = 0; row < h; row++) {
      for (int col = 0; col < w; col++) {
        if (x + col < width && y + row < height) {
          putChar(x + col, y + row, char, style: style);
        }
      }
    }
  }

  /// Clear a rectangle to empty cells
  void clearRect(
    int x,
    int y,
    int w,
    int h, {
    TuiStyle style = const TuiStyle(),
  }) {
    fillRect(x, y, w, h, ' ', style: style);
  }

  /// Clear the entire surface
  void clear({TuiStyle style = const TuiStyle()}) {
    clearRect(0, 0, width, height, style: style);
  }

  /// Draw a panel border with join logic for seamless connections
  void drawPanelBorder({
    required int x,
    required int y,
    required int w,
    required int h,
    required String topLeft,
    required String topRight,
    required String bottomLeft,
    required String bottomRight,
    required String horizontal,
    required String vertical,
    TuiStyle? style,
    bool drawTop = true,
    bool drawBottom = true,
    bool drawLeft = true,
    bool drawRight = true,
    bool joinLeft = false,
    bool joinRight = false,
  }) {
    final borderStyle = style ?? const TuiStyle();

    // Top border
    if (drawTop) {
      if (drawLeft && !joinLeft) putChar(x, y, topLeft, style: borderStyle);
      for (
        int i = (drawLeft && !joinLeft ? 1 : 0);
        i < w - (drawRight && !joinRight ? 1 : 0);
        i++
      ) {
        putChar(x + i, y, horizontal, style: borderStyle);
      }
      if (drawRight && !joinRight) {
        putChar(x + w - 1, y, topRight, style: borderStyle);
      }

      // Join characters for seamless connections
      if (joinLeft && drawLeft) putChar(x, y, '┬', style: borderStyle);
      if (joinRight && drawRight) {
        putChar(x + w - 1, y, '┬', style: borderStyle);
      }
    }

    // Bottom border
    if (drawBottom) {
      if (drawLeft && !joinLeft) {
        putChar(x, y + h - 1, bottomLeft, style: borderStyle);
      }
      for (
        int i = (drawLeft && !joinLeft ? 1 : 0);
        i < w - (drawRight && !joinRight ? 1 : 0);
        i++
      ) {
        putChar(x + i, y + h - 1, horizontal, style: borderStyle);
      }
      if (drawRight && !joinRight) {
        putChar(x + w - 1, y + h - 1, bottomRight, style: borderStyle);
      }

      // Join characters for seamless connections
      if (joinLeft && drawLeft) putChar(x, y + h - 1, '┴', style: borderStyle);
      if (joinRight && drawRight) {
        putChar(x + w - 1, y + h - 1, '┴', style: borderStyle);
      }
    }

    // Left and right borders
    for (int i = (drawTop ? 1 : 0); i < h - (drawBottom ? 1 : 0); i++) {
      if (drawLeft) putChar(x, y + i, vertical, style: borderStyle);
      if (drawRight) putChar(x + w - 1, y + i, vertical, style: borderStyle);
    }
  }

  /// Convert the surface to ANSI-styled lines for terminal output
  List<String> toAnsiLines() {
    final lines = <String>[];

    for (int row = 0; row < height; row++) {
      final buffer = StringBuffer();
      TuiStyle? currentStyle;

      for (int col = 0; col < width; col++) {
        final cell = _grid[row][col];

        // Skip continuation cells — the wide character already occupies
        // this terminal column via the previous cell's output.
        if (cell.wideContinuation) continue;

        // Apply style changes only when needed
        if (currentStyle != cell.style) {
          if (currentStyle != null) {
            buffer.write('\x1b[0m');
          }
          buffer.write(cell.style.toAnsi());
          currentStyle = cell.style;
        }

        buffer.write(cell.char);
      }

      // Reset style at end of line
      if (currentStyle != null && !currentStyle.isEmpty) {
        buffer.write('\x1b[0m');
      }

      lines.add(buffer.toString());
    }

    return lines;
  }

  /// Convert the surface to plain text lines without ANSI styling.
  List<String> toPlainLines() {
    return List.generate(height, (row) => getRowString(row));
  }

  /// Get a row as a string (for debugging)
  String getRowString(int row) {
    if (row < 0 || row >= height) return '';
    return _grid[row]
        .where((cell) => !cell.wideContinuation)
        .map((cell) => cell.char)
        .join();
  }

  /// Estimated display width of a string, accounting for wide characters.
  static int displayWidth(String text) {
    var w = 0;
    for (final rune in text.runes) {
      w += _isWideChar(rune) ? 2 : 1;
    }
    return w;
  }

  static bool _isWideChar(int rune) {
    // CJK Unified Ideographs, CJK Compatibility, Fullwidth Forms
    if (rune >= 0x1100 && rune <= 0x115F) return true;
    if (rune >= 0x2E80 && rune <= 0x303E) return true;
    if (rune >= 0x3040 && rune <= 0x33BF) return true;
    if (rune >= 0x3400 && rune <= 0x4DBF) return true;
    if (rune >= 0x4E00 && rune <= 0xA4CF) return true;
    if (rune >= 0xAC00 && rune <= 0xD7AF) return true;
    if (rune >= 0xF900 && rune <= 0xFAFF) return true;
    if (rune >= 0xFE30 && rune <= 0xFE6F) return true;
    if (rune >= 0xFF01 && rune <= 0xFF60) return true;
    if (rune >= 0xFFE0 && rune <= 0xFFE6) return true;
    // Emoji and symbols (most are double-width)
    if (rune >= 0x1F000) return true;
    // Miscellaneous symbols
    if (rune >= 0x2600 && rune <= 0x27BF) return true;
    return false;
  }

  /// Apply dimming style to a rectangular region
  void dimRect(int x, int y, int w, int h, TuiStyle dimStyle) {
    for (int row = 0; row < h; row++) {
      for (int col = 0; col < w; col++) {
        final cellX = x + col;
        final cellY = y + row;
        if (cellX >= 0 && cellX < width && cellY >= 0 && cellY < height) {
          final cell = _grid[cellY][cellX];
          // Apply dimming by merging with dim style
          final dimmedStyle = TuiStyle(
            fg: dimStyle.fg ?? cell.style.fg,
            bg: dimStyle.bg ?? cell.style.bg,
            fgRgb: dimStyle.fgRgb ?? cell.style.fgRgb,
            bgRgb: dimStyle.bgRgb ?? cell.style.bgRgb,
            bold: cell.style.bold,
            italic: cell.style.italic,
            underline: cell.style.underline,
          );
          _grid[cellY][cellX] = TuiCell(
            codePoint: cell.codePoint,
            style: dimmedStyle,
          );
        }
      }
    }
  }
}
