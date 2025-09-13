import 'style.dart';

/// Defines border character sets for drawing panels and boxes.
///
/// Contains the characters used to draw borders around UI components.
/// Several predefined sets are available, including ASCII-compatible
/// and Unicode box-drawing characters.
class TuiBorderChars {
  /// Character for top-left corner.
  final String topLeft;

  /// Character for top-right corner.
  final String topRight;

  /// Character for bottom-left corner.
  final String bottomLeft;

  /// Character for bottom-right corner.
  final String bottomRight;

  /// Character for horizontal lines.
  final String horizontal;

  /// Character for vertical lines.
  final String vertical;

  /// Creates a custom border character set.
  const TuiBorderChars({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.horizontal,
    required this.vertical,
  });

  /// ASCII-compatible border characters using +, -, and |.
  ///
  /// Safe for all terminals but less visually appealing.
  static const ascii = TuiBorderChars(
    topLeft: '+',
    topRight: '+',
    bottomLeft: '+',
    bottomRight: '+',
    horizontal: '-',
    vertical: '|',
  );

  /// Unicode box-drawing characters for smooth borders.
  ///
  /// Provides a clean, modern appearance but requires Unicode support.
  static const rounded = TuiBorderChars(
    topLeft: '┌',
    topRight: '┐',
    bottomLeft: '└',
    bottomRight: '┘',
    horizontal: '─',
    vertical: '│',
  );
}

/// Theme configuration for consistent component styling across the application.
///
/// Defines colors, borders, prefixes, and other visual elements used by
/// TUI components. Multiple predefined themes are available, or you can
/// create custom themes.
///
/// ## Usage
///
/// ```dart
/// // Use a predefined theme
/// final theme = TuiTheme.dark;
///
/// // Create a custom theme
/// final theme = TuiTheme(
///   border: TuiBorderChars.ascii,
///   accent: TuiStyle(fg: 4, bold: true),
/// );
/// ```
class TuiTheme {
  /// Border character set for drawing panels and boxes.
  final TuiBorderChars border;

  /// Prefix character shown before selected list items.
  final String listSelectedPrefix;

  /// Prefix character shown before unselected list items.
  final String listUnselectedPrefix;

  /// Accent color for highlighting important elements.
  final TuiStyle? accent;

  /// Dimmed style for secondary text.
  final TuiStyle? dim;

  /// Style applied to border characters.
  final TuiStyle? borderStyle;

  /// Style applied to panel titles.
  final TuiStyle? titleStyle;

  /// Background style for focused elements.
  final TuiStyle? focusBg;

  /// Border style for focused elements.
  final TuiStyle? focusBorderStyle;

  /// Creates a custom theme with the specified properties.
  const TuiTheme({
    this.border = TuiBorderChars.rounded,
    this.listSelectedPrefix = '>',
    this.listUnselectedPrefix = ' ',
    this.accent,
    this.dim,
    this.borderStyle,
    this.titleStyle,
    this.focusBg,
    this.focusBorderStyle,
  });

  static const dark = TuiTheme(
    border: TuiBorderChars.rounded,
    listSelectedPrefix: '>',
    listUnselectedPrefix: ' ',
    accent: TuiStyle(bold: true, fg: 39),
    dim: TuiStyle(fg: 245),
    borderStyle: TuiStyle(fg: 240),
    titleStyle: TuiStyle(bold: true, fg: 39),
    focusBg: TuiStyle(bg: 238),
    focusBorderStyle: TuiStyle(fg: 39),
  );

  static const light = TuiTheme(
    border: TuiBorderChars.rounded,
    listSelectedPrefix: '>',
    listUnselectedPrefix: ' ',
    accent: TuiStyle(bold: true, fg: 27),
    dim: TuiStyle(fg: 240),
    borderStyle: TuiStyle(fg: 242),
    titleStyle: TuiStyle(bold: true, fg: 27),
    focusBg: TuiStyle(bg: 254),
    focusBorderStyle: TuiStyle(fg: 27),
  );

  static const contrast = TuiTheme(
    border: TuiBorderChars.rounded,
    listSelectedPrefix: '>',
    listUnselectedPrefix: ' ',
    accent: TuiStyle(bold: true, fg: 46),
    dim: TuiStyle(fg: 250),
    borderStyle: TuiStyle(fg: 246),
    titleStyle: TuiStyle(bold: true, fg: 46),
    focusBg: TuiStyle(bg: 235),
    focusBorderStyle: TuiStyle(fg: 46),
  );

  static const monokai = TuiTheme(
    border: TuiBorderChars.rounded,
    listSelectedPrefix: '>',
    listUnselectedPrefix: ' ',
    accent: TuiStyle(bold: true, fg: 197),
    dim: TuiStyle(fg: 248),
    borderStyle: TuiStyle(fg: 242),
    titleStyle: TuiStyle(bold: true, fg: 197),
    focusBg: TuiStyle(bg: 238),
    focusBorderStyle: TuiStyle(fg: 197),
  );

  static const oceanic = TuiTheme(
    border: TuiBorderChars.rounded,
    listSelectedPrefix: '>',
    listUnselectedPrefix: ' ',
    accent: TuiStyle(bold: true, fg: 74),
    dim: TuiStyle(fg: 244),
    borderStyle: TuiStyle(fg: 240),
    titleStyle: TuiStyle(bold: true, fg: 74),
    focusBg: TuiStyle(bg: 237),
    focusBorderStyle: TuiStyle(fg: 74),
  );
}
