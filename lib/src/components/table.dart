import '../core/style.dart';
import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';

class TuiTable {
  final List<String> headers;
  final List<List<String>> rows;
  final List<int> columnWidths; // visible widths

  TuiTable({
    required this.headers,
    required this.rows,
    required this.columnWidths,
  });

  List<String> render(int totalWidth) {
    final out = <String>[];
    String rowToLine(List<String> cells) {
      final parts = <String>[];
      for (var i = 0; i < columnWidths.length; i++) {
        final w = columnWidths[i];
        final cell = i < cells.length ? cells[i] : '';
        final clipped = cell.length > w
            ? cell.substring(0, w)
            : cell.padRight(w);
        parts.add(clipped);
      }
      var line = parts.join(' ');
      if (line.length > totalWidth) line = line.substring(0, totalWidth);
      return line;
    }

    out.add(rowToLine(headers));
    for (final r in rows) {
      out.add(rowToLine(r));
    }
    return out;
  }
}

/// Surface-based table component for the new rendering system
class TuiTableView extends TuiComponent {
  final TuiTable table;
  final TuiStyle? headerStyle;
  final TuiStyle? rowStyle;

  TuiTableView(this.table, {this.headerStyle, this.rowStyle});

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    int y = rect.y;

    // Render header if there's space
    if (y < rect.bottom && table.headers.isNotEmpty) {
      _renderRow(
        surface,
        rect.x,
        y,
        rect.width,
        table.headers,
        headerStyle ?? const TuiStyle(bold: true),
      );
      y++;
    }

    // Render data rows
    for (final row in table.rows) {
      if (y >= rect.bottom) break;
      _renderRow(
        surface,
        rect.x,
        y,
        rect.width,
        row,
        rowStyle ?? const TuiStyle(),
      );
      y++;
    }
  }

  void _renderRow(
    TuiSurface surface,
    int x,
    int y,
    int width,
    List<String> cells,
    TuiStyle style,
  ) {
    int currentX = x;
    for (var i = 0; i < table.columnWidths.length; i++) {
      if (currentX >= x + width) break;

      final colWidth = table.columnWidths[i];
      final cell = i < cells.length ? cells[i] : '';
      final availableWidth = (x + width - currentX).clamp(0, colWidth);

      if (availableWidth > 0) {
        surface.putTextClip(currentX, y, cell, availableWidth, style: style);
        currentX += colWidth;

        // Add separator space if not the last column and there's space
        if (i < table.columnWidths.length - 1 && currentX < x + width) {
          surface.putChar(currentX, y, ' ');
          currentX++;
        }
      }
    }
  }
}
