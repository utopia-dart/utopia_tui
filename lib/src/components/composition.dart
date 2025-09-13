import '../core/component.dart';
import '../core/layout.dart';
import '../core/style.dart';
import '../core/theme.dart';
import '../core/canvas.dart';
import '../core/rect.dart';

/// A layout component that arranges child components horizontally.
///
/// Children are laid out from left to right with configurable widths
/// and optional gaps between them. Widths can be fixed (positive values)
/// or flexible (negative values for proportional sizing).
///
/// ## Usage
///
/// ```dart
/// TuiRow(
///   children: [widget1, widget2, widget3],
///   widths: [10, -1, 5], // 10 chars, flexible, 5 chars
///   gap: 1, // 1 character gap between children
/// )
/// ```
class TuiRow extends TuiComponent {
  /// The child components to lay out horizontally.
  final List<TuiComponent> children;

  /// Width specifications for each child.
  ///
  /// Positive values specify fixed widths in characters.
  /// Negative values specify flexible sizing (proportional to absolute value).
  final List<int> widths;

  /// Gap in characters between child components.
  final int gap;

  /// Creates a horizontal layout with the given [children] and [widths].
  ///
  /// The [children] and [widths] lists must have the same length.
  /// An optional [gap] can be specified between children (default 0).
  TuiRow({required this.children, required this.widths, this.gap = 0})
    : assert(children.length == widths.length);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty || children.isEmpty) return;

    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final splits = TuiLayout.splitH(rect.width, widths, gap: gap);
    for (var i = 0; i < children.length; i++) {
      final (offset, w) = splits[i];
      if (w <= 0) continue;

      final childRect = TuiRect(
        x: rect.x + offset,
        y: rect.y,
        width: w,
        height: rect.height,
      );
      children[i].paintSurface(surface, childRect);
    }
  }
}

/// A layout component that arranges child components vertically.
///
/// Children are laid out from top to bottom with configurable heights
/// and optional gaps between them. Heights can be fixed (positive values)
/// or flexible (negative values for proportional sizing).
///
/// ## Usage
///
/// ```dart
/// TuiColumn(
///   children: [header, content, footer],
///   heights: [3, -1, 2], // 3 rows, flexible, 2 rows
///   gap: 1, // 1 row gap between children
/// )
/// ```
class TuiColumn extends TuiComponent {
  /// The child components to lay out vertically.
  final List<TuiComponent> children;

  /// Height specifications for each child.
  ///
  /// Positive values specify fixed heights in rows.
  /// Negative values specify flexible sizing (proportional to absolute value).
  final List<int> heights;

  /// Gap in rows between child components.
  final int gap;

  /// Creates a vertical layout with the given [children] and [heights].
  ///
  /// The [children] and [heights] lists must have the same length.
  /// An optional [gap] can be specified between children (default 0).
  TuiColumn({required this.children, required this.heights, this.gap = 0})
    : assert(children.length == heights.length);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty || children.isEmpty) return;

    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final splits = TuiLayout.splitV(rect.height, heights, gap: gap);
    for (var i = 0; i < children.length; i++) {
      final (offset, h) = splits[i];
      if (h <= 0) continue;

      final childRect = TuiRect(
        x: rect.x,
        y: rect.y + offset,
        width: rect.width,
        height: h,
      );
      children[i].paintSurface(surface, childRect);
    }
  }
}

/// A component that displays text content with optional styling.
///
/// Supports multiline text with automatic line breaking on newlines.
/// Text is clipped to the available rectangle and styled with ANSI
/// escape sequences if a style is provided.
///
/// ## Usage
///
/// ```dart
/// // Simple text
/// TuiText('Hello World')
///
/// // Styled text
/// TuiText('Error message', style: TuiStyle(fg: 1, bold: true))
///
/// // Multiline text
/// TuiText('Line 1\nLine 2\nLine 3')
/// ```
class TuiText extends TuiComponent {
  /// The text content to display.
  final String text;

  /// Optional styling to apply to the text.
  final TuiStyle? style;

  /// Creates a text component with the given [text] and optional [style].
  TuiText(this.text, {this.style});

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final lines = text.split(RegExp(r"\r?\n"));
    for (var i = 0; i < rect.height && i < lines.length; i++) {
      final line = lines[i];
      surface.putTextClip(
        rect.x,
        rect.y + i,
        line,
        rect.width,
        style: style ?? const TuiStyle(),
      );
    }
  }
}

/// A component that generates lines of text dynamically using a builder function.
///
/// This is useful for content that needs to be computed based on the available
/// space, such as data tables, formatted lists, or dynamically sized content.
/// The builder function receives the available dimensions and returns the
/// appropriate lines of text.
///
/// ## Usage
///
/// ```dart
/// TuiLines((width, height) {
///   final lines = <String>[];
///   for (int i = 0; i < height; i++) {
///     lines.add('Line $i (max width: $width)');
///   }
///   return lines;
/// })
/// ```
class TuiLines extends TuiComponent {
  /// Function that builds the lines based on available space.
  ///
  /// Called each time the component needs to render, receiving the
  /// available width and height in characters.
  final List<String> Function(int width, int height) builder;

  /// Whether to strip ANSI escape codes from the generated lines.
  ///
  /// If true, any ANSI escape sequences in the generated text will be
  /// removed before rendering. This is useful when the builder generates
  /// pre-styled text but you want plain text output.
  final bool stripAnsiCodes;

  /// Creates a lines component with the given [builder] function.
  ///
  /// Set [stripAnsiCodes] to false if the builder generates plain text
  /// or if you want to preserve ANSI styling in the output.
  TuiLines(this.builder, {this.stripAnsiCodes = true});

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final lines = builder(rect.width, rect.height);
    for (var i = 0; i < rect.height && i < lines.length; i++) {
      var line = lines[i];

      if (stripAnsiCodes) {
        line = line.replaceAll(RegExp(r'\x1B\[[0-9;]*[mK]'), '');
      }

      surface.putTextClip(rect.x, rect.y + i, line, rect.width);
    }
  }
}

/// A container component with borders and an optional title.
///
/// Creates a rectangular panel with borders around the child content.
/// The borders are drawn using the theme's border characters, and an
/// optional title can be displayed in the top border.
///
/// ## Usage
///
/// ```dart
/// TuiPanelBox(
///   title: ' Settings ',
///   child: TuiText('Panel content here'),
///   theme: TuiTheme.dark,
/// )
/// ```
class TuiPanelBox extends TuiComponent {
  /// The title to display in the top border (optional).
  final String title;

  /// The child component to display inside the panel.
  final TuiComponent child;

  /// The theme to use for border styling.
  final TuiTheme? theme;
  final TuiStyle? borderStyle;
  final TuiStyle? titleStyle;
  final bool drawTop;
  final bool drawBottom;
  final bool drawLeft;
  final bool drawRight;
  final bool joinLeft; // use ┬/┴ instead of ┌/└ on the left
  final bool joinRight; // use ┬/┴ instead of ┐/┘ on the right
  final int padding;

  TuiPanelBox({
    required this.title,
    required this.child,
    this.theme,
    this.borderStyle,
    this.titleStyle,
    this.drawTop = true,
    this.drawBottom = true,
    this.drawLeft = true,
    this.drawRight = true,
    this.joinLeft = false,
    this.joinRight = false,
    this.padding = 1,
  });

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    final actualTheme = theme ?? const TuiTheme();
    final b = actualTheme.border;

    // Clear the entire area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    // Draw the border using the surface's drawPanelBorder method
    surface.drawPanelBorder(
      x: rect.x,
      y: rect.y,
      w: rect.width,
      h: rect.height,
      topLeft: b.topLeft,
      topRight: b.topRight,
      bottomLeft: b.bottomLeft,
      bottomRight: b.bottomRight,
      horizontal: b.horizontal,
      vertical: b.vertical,
      style: borderStyle,
      drawTop: drawTop,
      drawBottom: drawBottom,
      drawLeft: drawLeft,
      drawRight: drawRight,
      joinLeft: joinLeft,
      joinRight: joinRight,
    );

    // Draw the title if present
    if (title.isNotEmpty) {
      final titleText = ' $title ';
      final styledTitle = titleStyle?.apply(titleText) ?? titleText;
      final visibleTitleLen = tuiStripAnsi(styledTitle).length;

      if (drawTop && visibleTitleLen < rect.width - 2) {
        // Clear the title area and write the title
        for (int i = 0; i < visibleTitleLen; i++) {
          surface.putChar(rect.x + 1 + i, rect.y, ' ');
        }
        surface.putTextClip(
          rect.x + 1,
          rect.y,
          titleText,
          rect.width - 2,
          style: titleStyle ?? const TuiStyle(),
        );
      }
    }

    // Paint child inside the border, with automatic padding
    final innerRect = TuiRect(
      x: rect.x + (drawLeft ? 1 : 0),
      y: rect.y + (drawTop ? 1 : 0),
      width: rect.width - (drawLeft ? 1 : 0) - (drawRight ? 1 : 0),
      height: rect.height - (drawTop ? 1 : 0) - (drawBottom ? 1 : 0),
    );

    if (!innerRect.isEmpty) {
      if (padding > 0) {
        TuiPadding(
          child: child,
          left: padding,
          right: padding,
          top: padding,
          bottom: padding,
        ).paintSurface(surface, innerRect);
      } else {
        child.paintSurface(surface, innerRect);
      }
    }
  }
}

class TuiBackground extends TuiComponent {
  final TuiStyle style;
  final TuiComponent child;
  TuiBackground({required this.style, required this.child});

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Fill with background color
    surface.fillRect(
      rect.x,
      rect.y,
      rect.width,
      rect.height,
      ' ',
      style: style,
    );

    // Paint child over the background
    child.paintSurface(surface, rect);
  }
}

class TuiSideBySidePanels extends TuiComponent {
  final String leftTitle;
  final String rightTitle;
  final TuiComponent leftChild;
  final TuiComponent rightChild;
  final int leftWidth;
  final TuiTheme? theme;
  final TuiStyle? titleStyle;
  final TuiStyle? leftBorderStyle;
  final TuiStyle? rightBorderStyle;

  TuiSideBySidePanels({
    required this.leftTitle,
    required this.rightTitle,
    required this.leftChild,
    required this.rightChild,
    required this.leftWidth,
    this.theme,
    this.titleStyle,
    this.leftBorderStyle,
    this.rightBorderStyle,
  });

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the entire area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final actualTheme = theme ?? const TuiTheme();
    final actualLeftWidth = leftWidth.clamp(0, rect.width - 1);
    final rightWidth = rect.width - actualLeftWidth;

    if (actualLeftWidth <= 0 || rightWidth <= 0) return;

    final b = actualTheme.border;

    // Create panels without the connecting borders
    final leftPanel = TuiPanelBox(
      title: leftTitle,
      child: leftChild,
      theme: actualTheme,
      borderStyle: leftBorderStyle,
      titleStyle: titleStyle,
      drawRight: false, // Don't draw right border - we'll draw the connection
    );

    final rightPanel = TuiPanelBox(
      title: rightTitle,
      child: rightChild,
      theme: actualTheme,
      borderStyle: rightBorderStyle,
      titleStyle: titleStyle,
      drawLeft: false, // Don't draw left border - we'll draw the connection
    );

    // Paint both panels
    final leftRect = TuiRect(
      x: rect.x,
      y: rect.y,
      width: actualLeftWidth,
      height: rect.height,
    );
    leftPanel.paintSurface(surface, leftRect);

    final rightRect = TuiRect(
      x: rect.x + actualLeftWidth,
      y: rect.y,
      width: rightWidth,
      height: rect.height,
    );
    rightPanel.paintSurface(surface, rightRect);

    // Draw the connecting border at the junction
    final connectionX = rect.x + actualLeftWidth;
    final borderStyle = leftBorderStyle ?? rightBorderStyle ?? const TuiStyle();

    // Top connection
    surface.putChar(connectionX, rect.y, '┬', style: borderStyle);

    // Middle connections (vertical line)
    for (int i = 1; i < rect.height - 1; i++) {
      surface.putChar(connectionX, rect.y + i, b.vertical, style: borderStyle);
    }

    // Bottom connection
    surface.putChar(
      connectionX,
      rect.y + rect.height - 1,
      '┴',
      style: borderStyle,
    );
  }
}

class TuiPadding extends TuiComponent {
  final TuiComponent child;
  final int left;
  final int top;
  final int right;
  final int bottom;

  TuiPadding({
    required this.child,
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });

  TuiPadding.all(int padding, {required this.child})
    : left = padding,
      top = padding,
      right = padding,
      bottom = padding;

  TuiPadding.symmetric({
    required this.child,
    int horizontal = 0,
    int vertical = 0,
  }) : left = horizontal,
       right = horizontal,
       top = vertical,
       bottom = vertical;

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the entire area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    // Calculate inner rect with padding applied
    final innerRect = TuiRect(
      x: rect.x + left,
      y: rect.y + top,
      width: (rect.width - left - right).clamp(0, rect.width),
      height: (rect.height - top - bottom).clamp(0, rect.height),
    );

    if (!innerRect.isEmpty) {
      child.paintSurface(surface, innerRect);
    }
  }
}

class TuiCenter extends TuiComponent {
  final TuiComponent child;
  TuiCenter({required this.child});

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    // For now, just paint the child in the full rect
    child.paintSurface(surface, rect);
  }
}

class TuiBorder extends TuiComponent {
  final TuiComponent child;
  final TuiTheme? theme;
  final TuiStyle? borderStyle;
  final String title;

  TuiBorder({
    required this.child,
    this.theme,
    this.borderStyle,
    this.title = '',
  });

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    // Just delegate to TuiPanelBox which handles borders properly
    final panel = TuiPanelBox(
      title: title,
      child: child,
      theme: theme,
      borderStyle: borderStyle,
    );
    panel.paintSurface(surface, rect);
  }
}
