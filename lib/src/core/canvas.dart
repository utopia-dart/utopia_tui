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

  /// Creates a cell with the specified [codePoint] and optional [style].
  const TuiCell({required this.codePoint, this.style = const TuiStyle()});

  /// Creates a cell from a string [char] with optional [style].
  ///
  /// If [char] is empty, defaults to a space character (code point 32).
  /// If [char] has multiple characters, only the first is used.
  TuiCell.fromChar(String char, {this.style = const TuiStyle()})
    : codePoint = char.isNotEmpty ? char.codeUnitAt(0) : 32;

  /// Creates an empty cell (space character) with optional [style].
  const TuiCell.empty({this.style = const TuiStyle()}) : codePoint = 32;

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
        other.style == style;
  }

  @override
  int get hashCode => codePoint.hashCode ^ style.hashCode;
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
    for (int i = 0; i < text.length; i++) {
      if (x + i >= width) break;
      putChar(x + i, y, text[i], style: style);
    }
  }

  /// Put text clipped to a specific width
  void putTextClip(
    int x,
    int y,
    String text,
    int maxWidth, {
    TuiStyle style = const TuiStyle(),
  }) {
    final clippedText = text.length > maxWidth
        ? text.substring(0, maxWidth)
        : text;
    putText(x, y, clippedText, style: style);
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

        // Apply style changes only when needed
        if (currentStyle != cell.style) {
          if (currentStyle != null) {
            // Reset previous style
            buffer.write('\x1b[0m');
          }
          // Apply new style
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

  /// Get a row as a string (for debugging)
  String getRowString(int row) {
    if (row < 0 || row >= height) return '';
    return _grid[row].map((cell) => cell.char).join();
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
            bold: cell.style.bold,
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
