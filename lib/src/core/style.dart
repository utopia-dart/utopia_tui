/// Text styling utilities built on ANSI escape sequences.
///
/// The [TuiStyle] class provides a convenient way to apply colors, formatting,
/// and other visual attributes to text in terminal applications.
library;

/// Represents text styling options including colors and formatting.
///
/// Supports 256-color palette for both foreground and background colors,
/// plus common text formatting like bold, italic, and underline.
///
/// ## Color Values
///
/// Colors are specified as integers from 0-255:
/// - 0-15: Standard colors (black, red, green, etc.)
/// - 16-231: 216-color cube (6×6×6)
/// - 232-255: Grayscale ramp
///
/// ## Usage Examples
///
/// ```dart
/// // Red text on black background
/// const style = TuiStyle(fg: 1, bg: 0);
///
/// // Bold blue text
/// const style = TuiStyle(fg: 4, bold: true);
///
/// // Apply styling to text
/// final styledText = style.apply('Hello World');
/// ```
class TuiStyle {
  /// Foreground color (0-255), or null for default.
  final int? fg;

  /// Background color (0-255), or null for default.
  final int? bg;

  /// Whether text should be rendered in bold.
  final bool bold;

  /// Whether text should be rendered in italic.
  final bool italic;

  /// Whether text should be underlined.
  final bool underline;

  /// Creates a new text style with the specified properties.
  const TuiStyle({
    this.fg,
    this.bg,
    this.bold = false,
    this.italic = false,
    this.underline = false,
  });

  /// Creates a new style by merging this style with [other].
  ///
  /// Properties from [other] take precedence over properties from this style.
  /// Boolean properties (bold, italic, underline) are combined with logical OR.
  TuiStyle merge(TuiStyle other) => TuiStyle(
    fg: other.fg ?? fg,
    bg: other.bg ?? bg,
    bold: bold || other.bold,
    italic: italic || other.italic,
    underline: underline || other.underline,
  );

  /// Creates a copy of this style with the specified properties changed.
  ///
  /// Any properties not specified will retain their current values.
  TuiStyle copyWith({
    int? fg,
    int? bg,
    bool? bold,
    bool? italic,
    bool? underline,
  }) => TuiStyle(
    fg: fg ?? this.fg,
    bg: bg ?? this.bg,
    bold: bold ?? this.bold,
    italic: italic ?? this.italic,
    underline: underline ?? this.underline,
  );

  /// Applies this style to the given [text] using ANSI escape sequences.
  ///
  /// Returns the text wrapped with appropriate ANSI codes for styling.
  /// The text will be automatically reset to default styling at the end.
  String apply(String text) {
    final buf = StringBuffer();
    if (bold || italic || underline || fg != null || bg != null) {
      buf.write('\x1b[');
      final parts = <String>[];
      if (bold) parts.add('1');
      if (italic) parts.add('3');
      if (underline) parts.add('4');
      if (fg != null) parts.add('38;5;$fg');
      if (bg != null) parts.add('48;5;$bg');
      buf.write(parts.join(';'));
      buf.write('m');
      buf.write(text);
      buf.write('\x1b[0m');
      return buf.toString();
    }
    return text;
  }

  /// Get the ANSI escape sequence for this style (without reset)
  String toAnsi() {
    if (bold || italic || underline || fg != null || bg != null) {
      final buf = StringBuffer();
      buf.write('\x1b[');
      final parts = <String>[];
      if (bold) parts.add('1');
      if (italic) parts.add('3');
      if (underline) parts.add('4');
      if (fg != null) parts.add('38;5;$fg');
      if (bg != null) parts.add('48;5;$bg');
      buf.write(parts.join(';'));
      buf.write('m');
      return buf.toString();
    }
    return '';
  }

  /// Check if this style has any formatting
  bool get isEmpty =>
      !bold && !italic && !underline && fg == null && bg == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TuiStyle &&
        other.fg == fg &&
        other.bg == bg &&
        other.bold == bold &&
        other.italic == italic &&
        other.underline == underline;
  }

  @override
  int get hashCode => Object.hash(fg, bg, bold, italic, underline);
}

// Strip ANSI escape sequences for width calculations.
String tuiStripAnsi(String input) {
  final re = RegExp(r'\x1B\[[0-9;]*m');
  return input.replaceAll(re, '');
}

// Clip a styled string to a target visible width (characters), preserving ANSI.
String tuiClipAnsi(String input, int visibleWidth) {
  if (visibleWidth <= 0) return '';
  final re = RegExp(r'\x1B\[[0-9;]*m');
  final out = StringBuffer();
  var visible = 0;
  for (var i = 0; i < input.length; i++) {
    final ch = input[i];
    if (ch == '\x1B') {
      // copy ANSI sequence as-is
      final match = re.matchAsPrefix(input, i);
      if (match != null) {
        out.write(match.group(0));
        i = match.end - 1; // -1 because loop will i++
        continue;
      }
    }
    if (visible >= visibleWidth) break;
    out.write(ch);
    visible++;
  }
  // ensure reset at end if there was any ansi start
  if (out.toString().contains('\x1B[') && !out.toString().endsWith('\x1b[0m')) {
    out.write('\x1b[0m');
  }
  return out.toString();
}
