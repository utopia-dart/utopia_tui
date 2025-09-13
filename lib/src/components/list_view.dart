import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';
import '../core/style.dart';
import 'list_menu.dart';

/// A surface-based view component for rendering [TuiList].
///
/// This component handles the visual presentation of a [TuiList] on a
/// [TuiSurface], applying proper styling and positioning. It renders
/// the list items with appropriate prefixes and selection highlighting.
///
/// ## Usage
///
/// ```dart
/// final list = TuiList(['Item 1', 'Item 2', 'Item 3']);
/// final listView = TuiListView(list);
/// listView.paintSurface(surface, rect);
/// ```
class TuiListView extends TuiComponent {
  /// The list model to render.
  final TuiList list;

  /// Creates a list view for the given [list].
  TuiListView(this.list);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final theme = list.theme;
    for (var i = 0; i < rect.height && i < list.items.length; i++) {
      final isSel = i == list.selectedIndex;
      final prefix = isSel
          ? theme.listSelectedPrefix
          : theme.listUnselectedPrefix;
      final item = list.items[i];
      final text = ' $prefix $item ';
      final style = isSel
          ? (list.selectedStyle ?? const TuiStyle())
          : (list.unselectedStyle ?? const TuiStyle());

      surface.putTextClip(rect.x, rect.y + i, text, rect.width, style: style);
    }
  }
}
