class TuiTable {
  final List<String> headers;
  final List<List<String>> rows;
  final List<int> columnWidths; // visible widths

  TuiTable({required this.headers, required this.rows, required this.columnWidths});

  List<String> render(int totalWidth) {
    final out = <String>[];
    String rowToLine(List<String> cells) {
      final parts = <String>[];
      for (var i = 0; i < columnWidths.length; i++) {
        final w = columnWidths[i];
        final cell = i < cells.length ? cells[i] : '';
        final clipped = cell.length > w ? cell.substring(0, w) : cell.padRight(w);
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

