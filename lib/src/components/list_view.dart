import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';
import '../core/style.dart';
import 'list_menu.dart';

/// View component for rendering TuiList
class TuiListView extends TuiComponent {
  final TuiList list;
  TuiListView(this.list);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    // Render list items directly to surface with proper styling
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
