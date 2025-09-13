import '../core/theme.dart';
import '../core/style.dart';

/// A selectable list component with navigation and styling support.
///
/// Displays a list of string items with one item selected at a time.
/// Supports keyboard navigation and customizable styling for selected
/// and unselected items using theme-based prefixes.
///
/// ## Usage
///
/// ```dart
/// final list = TuiList([
///   'Option 1',
///   'Option 2',
///   'Option 3',
/// ], selectedIndex: 1);
///
/// // Navigate the list
/// list.moveUp();
/// list.moveDown();
///
/// // Render to strings
/// final lines = list.render(20, 10);
/// ```
class TuiList {
  /// The list of items to display.
  final List<String> items;

  /// The index of the currently selected item.
  int selectedIndex;

  /// The theme used for styling list prefixes and appearance.
  final TuiTheme theme;

  /// Optional style applied to the selected item.
  final TuiStyle? selectedStyle;

  /// Optional style applied to unselected items.
  final TuiStyle? unselectedStyle;

  /// Creates a selectable list with the given [items].
  ///
  /// [selectedIndex] specifies which item is initially selected (default 0).
  /// [theme] provides styling configuration (uses default theme if not specified).
  /// [selectedStyle] and [unselectedStyle] allow custom styling of items.
  TuiList(
    this.items, {
    this.selectedIndex = 0,
    TuiTheme? theme,
    this.selectedStyle,
    this.unselectedStyle,
  }) : theme = theme ?? const TuiTheme();

  /// Moves the selection up by one item.
  ///
  /// Does nothing if already at the first item.
  void moveUp() {
    if (selectedIndex > 0) selectedIndex--;
  }

  /// Moves the selection down by one item.
  ///
  /// Does nothing if already at the last item.
  void moveDown() {
    if (selectedIndex < items.length - 1) selectedIndex++;
  }

  /// Renders the list as strings for the given dimensions.
  ///
  /// Returns a list of formatted strings, one per line, up to [height] lines.
  /// Each line includes the appropriate prefix (selected/unselected) and
  /// applied styling. Lines beyond the number of items are returned as
  /// empty strings.
  ///
  /// [width] is currently unused but provided for API consistency.
  /// [height] determines the maximum number of lines to return.
  List<String> render(int width, int height) {
    final out = <String>[];
    for (var i = 0; i < height; i++) {
      if (i < items.length) {
        final isSel = i == selectedIndex;
        final prefix = isSel
            ? theme.listSelectedPrefix
            : theme.listUnselectedPrefix;
        var label = ' $prefix ${items[i]} ';
        if (isSel && selectedStyle != null) label = selectedStyle!.apply(label);
        if (!isSel && unselectedStyle != null) {
          label = unselectedStyle!.apply(label);
        }
        out.add(label);
      } else {
        out.add('');
      }
    }
    return out;
  }
}
