class TuiLayout {
  /// Split a horizontal region [total] into [parts] widths. Negative widths are
  /// treated as flexible; remaining space is distributed equally among them.
  static List<(int offset, int width)> splitH(int total, List<int> parts, {int gap = 0}) {
    final fixed = parts.where((w) => w >= 0).fold<int>(0, (a, b) => a + b);
    final flexCount = parts.where((w) => w < 0).length;
    final gaps = gap * (parts.length - 1);
    final remaining = (total - fixed - gaps).clamp(0, total);
    final flex = flexCount == 0 ? 0 : remaining ~/ flexCount;
    final result = <(int, int)>[];
    var x = 0;
    for (var i = 0; i < parts.length; i++) {
      final w = parts[i] >= 0 ? parts[i] : flex;
      result.add((x, w));
      x += w;
      if (i < parts.length - 1) x += gap;
    }
    return result;
  }

  /// Split a vertical region [total] into [parts] heights. Negative heights
  /// are flexible and share remaining space.
  static List<(int offset, int height)> splitV(int total, List<int> parts, {int gap = 0}) {
    final fixed = parts.where((h) => h >= 0).fold<int>(0, (a, b) => a + b);
    final flexCount = parts.where((h) => h < 0).length;
    final gaps = gap * (parts.length - 1);
    final remaining = (total - fixed - gaps).clamp(0, total);
    final flex = flexCount == 0 ? 0 : remaining ~/ flexCount;
    final result = <(int, int)>[];
    var y = 0;
    for (var i = 0; i < parts.length; i++) {
      final h = parts[i] >= 0 ? parts[i] : flex;
      result.add((y, h));
      y += h;
      if (i < parts.length - 1) y += gap;
    }
    return result;
  }
}

