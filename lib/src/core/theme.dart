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

  const TuiTheme({
    this.border = TuiBorderChars.rounded,
    this.listSelectedPrefix = '›',
    this.listUnselectedPrefix = ' ',
  });
}

