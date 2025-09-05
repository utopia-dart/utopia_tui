import 'style.dart';

/// Border character presets for panels and boxes.
class TuiBorderChars {
  final String topLeft;
  final String topRight;
  final String bottomLeft;
  final String bottomRight;
  final String horizontal;
  final String vertical;

  const TuiBorderChars({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.horizontal,
    required this.vertical,
  });

  static const ascii = TuiBorderChars(
    topLeft: '+',
    topRight: '+',
    bottomLeft: '+',
    bottomRight: '+',
    horizontal: '-',
    vertical: '|',
  );

  static const rounded = TuiBorderChars(
    topLeft: '┌',
    topRight: '┐',
    bottomLeft: '└',
    bottomRight: '┘',
    horizontal: '─',
    vertical: '│',
  );
}

/// Simple theme settings for shared component styling.
class TuiTheme {
  final TuiBorderChars border;
  final String listSelectedPrefix;
  final String listUnselectedPrefix;

  // Optional style hints
  final TuiStyle? accent;
  final TuiStyle? dim;
  final TuiStyle? borderStyle;
  final TuiStyle? titleStyle;
  final TuiStyle? focusBg;
  final TuiStyle? focusBorderStyle;

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
}
