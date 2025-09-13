/// A rectangle representing a region on the terminal surface
class TuiRect {
  final int x;
  final int y;
  final int width;
  final int height;

  const TuiRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Create a rect from coordinates
  const TuiRect.fromLTWH(int left, int top, this.width, this.height)
    : x = left,
      y = top;

  /// Create a rect from corner coordinates
  TuiRect.fromLTRB(int left, int top, int right, int bottom)
    : x = left,
      y = top,
      width = right - left,
      height = bottom - top;

  /// Get the right edge (x + width)
  int get right => x + width;

  /// Get the bottom edge (y + height)
  int get bottom => y + height;

  /// Get the center point
  TuiPoint get center => TuiPoint(x + width ~/ 2, y + height ~/ 2);

  /// Check if this rect contains a point
  bool contains(int px, int py) {
    return px >= x && px < right && py >= y && py < bottom;
  }

  /// Check if this rect contains another point
  bool containsPoint(TuiPoint point) {
    return contains(point.x, point.y);
  }

  /// Check if this rect intersects with another rect
  bool intersects(TuiRect other) {
    return x < other.right &&
        right > other.x &&
        y < other.bottom &&
        bottom > other.y;
  }

  /// Get the intersection of two rects, or null if they don't intersect
  TuiRect? intersection(TuiRect other) {
    final left = x > other.x ? x : other.x;
    final top = y > other.y ? y : other.y;
    final rightEdge = right < other.right ? right : other.right;
    final bottomEdge = bottom < other.bottom ? bottom : other.bottom;

    if (left < rightEdge && top < bottomEdge) {
      return TuiRect(
        x: left,
        y: top,
        width: rightEdge - left,
        height: bottomEdge - top,
      );
    }
    return null;
  }

  /// Create a new rect with padding applied inward
  TuiRect shrink({int left = 0, int top = 0, int right = 0, int bottom = 0}) {
    final newX = x + left;
    final newY = y + top;
    final newWidth = (width - left - right).clamp(0, width);
    final newHeight = (height - top - bottom).clamp(0, height);

    return TuiRect(x: newX, y: newY, width: newWidth, height: newHeight);
  }

  /// Create a new rect with padding applied outward
  TuiRect expand({int left = 0, int top = 0, int right = 0, int bottom = 0}) {
    return TuiRect(
      x: x - left,
      y: y - top,
      width: width + left + right,
      height: height + top + bottom,
    );
  }

  /// Create a new rect offset by dx, dy
  TuiRect translate(int dx, int dy) {
    return TuiRect(x: x + dx, y: y + dy, width: width, height: height);
  }

  /// Split this rect horizontally into left and right parts
  /// leftWidth can be negative to specify width of right part
  TuiRectSplit splitHorizontal(int leftWidth) {
    if (leftWidth < 0) {
      leftWidth = (width + leftWidth).clamp(0, width);
    }
    leftWidth = leftWidth.clamp(0, width);

    final rightWidth = width - leftWidth;

    return TuiRectSplit(
      left: TuiRect(x: x, y: y, width: leftWidth, height: height),
      right: TuiRect(x: x + leftWidth, y: y, width: rightWidth, height: height),
    );
  }

  /// Split this rect vertically into top and bottom parts
  /// topHeight can be negative to specify height of bottom part
  TuiRectSplit splitVertical(int topHeight) {
    if (topHeight < 0) {
      topHeight = (height + topHeight).clamp(0, height);
    }
    topHeight = topHeight.clamp(0, height);

    final bottomHeight = height - topHeight;

    return TuiRectSplit(
      left: TuiRect(x: x, y: y, width: width, height: topHeight), // top
      right: TuiRect(
        x: x,
        y: y + topHeight,
        width: width,
        height: bottomHeight,
      ), // bottom
    );
  }

  /// Split this rect into multiple horizontal sections
  List<TuiRect> splitHorizontalMultiple(List<int> widths) {
    final result = <TuiRect>[];
    var currentX = x;

    for (final w in widths) {
      final actualWidth = w < 0
          ? (width - result.fold<int>(0, (sum, r) => sum + r.width))
          : w;
      final clampedWidth = actualWidth.clamp(0, width - (currentX - x));

      result.add(
        TuiRect(x: currentX, y: y, width: clampedWidth, height: height),
      );

      currentX += clampedWidth;
      if (currentX >= right) break;
    }

    return result;
  }

  /// Split this rect into multiple vertical sections
  List<TuiRect> splitVerticalMultiple(List<int> heights) {
    final result = <TuiRect>[];
    var currentY = y;

    for (final h in heights) {
      final actualHeight = h < 0
          ? (height - result.fold<int>(0, (sum, r) => sum + r.height))
          : h;
      final clampedHeight = actualHeight.clamp(0, height - (currentY - y));

      result.add(
        TuiRect(x: x, y: currentY, width: width, height: clampedHeight),
      );

      currentY += clampedHeight;
      if (currentY >= bottom) break;
    }

    return result;
  }

  /// Check if this rect is empty (zero width or height)
  bool get isEmpty => width <= 0 || height <= 0;

  /// Get the area of this rect
  int get area => width * height;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TuiRect &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(x, y, width, height);

  @override
  String toString() => 'TuiRect(x: $x, y: $y, width: $width, height: $height)';
}

/// A point on the terminal surface
class TuiPoint {
  final int x;
  final int y;

  const TuiPoint(this.x, this.y);

  /// Translate this point by dx, dy
  TuiPoint translate(int dx, int dy) => TuiPoint(x + dx, y + dy);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TuiPoint && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'TuiPoint($x, $y)';
}

/// Result of splitting a rect into two parts
class TuiRectSplit {
  final TuiRect left;
  final TuiRect right;

  const TuiRectSplit({required this.left, required this.right});

  /// For vertical splits, get the top rect
  TuiRect get top => left;

  /// For vertical splits, get the bottom rect
  TuiRect get bottom => right;
}

/// Edge insets for padding/margin
class TuiInsets {
  final int left;
  final int top;
  final int right;
  final int bottom;

  const TuiInsets({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  /// Create symmetric insets
  const TuiInsets.all(int value)
    : left = value,
      top = value,
      right = value,
      bottom = value;

  /// Create horizontal/vertical insets
  const TuiInsets.symmetric({int horizontal = 0, int vertical = 0})
    : left = horizontal,
      right = horizontal,
      top = vertical,
      bottom = vertical;

  /// Create insets from left, top, right, bottom
  const TuiInsets.ltrb(this.left, this.top, this.right, this.bottom);

  /// Apply these insets to a rect (shrink inward)
  TuiRect applyTo(TuiRect rect) {
    return rect.shrink(left: left, top: top, right: right, bottom: bottom);
  }

  /// Get total horizontal insets
  int get horizontal => left + right;

  /// Get total vertical insets
  int get vertical => top + bottom;
}
