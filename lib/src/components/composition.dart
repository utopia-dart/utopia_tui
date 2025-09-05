import '../core/component.dart';
import '../core/layout.dart';
import '../core/style.dart';
import '../core/theme.dart';
import '../core/canvas.dart';
import '../core/rect.dart';
import 'list_menu.dart';
import 'text_input.dart';
import 'scroll_view.dart';

class TuiRow extends TuiComponent {
  final List<TuiComponent> children;
  final List<int> widths; // >=0 fixed, <0 flex
  final int gap;
  TuiRow({required this.children, required this.widths, this.gap = 0})
    : assert(children.length == widths.length);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty || children.isEmpty) return;

    // Clear the area
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

class TuiColumn extends TuiComponent {
  final List<TuiComponent> children;
  final List<int> heights; // >=0 fixed, <0 flex
  final int gap;
  TuiColumn({required this.children, required this.heights, this.gap = 0})
    : assert(children.length == heights.length);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty || children.isEmpty) return;

    // Clear the area
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

class TuiText extends TuiComponent {
  final String text;
  final TuiStyle? style;
  TuiText(this.text, {this.style});

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
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

class TuiLines extends TuiComponent {
  final List<String> Function(int width, int height) builder;
  final bool stripAnsiCodes;

  TuiLines(this.builder, {this.stripAnsiCodes = true});

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final lines = builder(rect.width, rect.height);
    for (var i = 0; i < rect.height && i < lines.length; i++) {
      var line = lines[i];

      // Strip ANSI escape codes if requested
      if (stripAnsiCodes) {
        line = line.replaceAll(RegExp(r'\x1B\[[0-9;]*[mK]'), '');
      }

      surface.putTextClip(rect.x, rect.y + i, line, rect.width);
    }
  }
}

class TuiPanelBox extends TuiComponent {
  final String title;
  final TuiComponent child;
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

class TuiTextInputView extends TuiComponent {
  final TuiTextInput input;
  TuiTextInputView(this.input);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final text = input.text;
    final idx = input.cursor.clamp(0, text.length);

    // Draw the box if enabled
    int textStartX = rect.x;
    if (input.showBox) {
      surface.putChar(rect.x, rect.y, '[');
      textStartX = rect.x + 1;
      if (rect.width > 2) {
        surface.putChar(rect.x + rect.width - 1, rect.y, ']');
      }
    }

    final availableWidth = rect.width - (input.showBox ? 2 : 0);
    if (availableWidth > 0) {
      // Draw the complete text first
      surface.putTextClip(textStartX, rect.y, text, availableWidth);

      // Then draw cursor over the appropriate character
      if (idx < availableWidth) {
        final cursorChar = input.blinkOn
            ? '_'
            : (idx < text.length ? text[idx] : ' ');
        final cursorStyle = input.cursorStyle ?? const TuiStyle(bold: true);
        surface.putChar(
          textStartX + idx,
          rect.y,
          cursorChar,
          style: cursorStyle,
        );
      }
    }
  }
}

class TuiScrollViewView extends TuiComponent {
  final TuiScrollView scroll;
  TuiScrollViewView(this.scroll);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final lines = scroll.render(rect.width, rect.height);
    for (var i = 0; i < rect.height && i < lines.length; i++) {
      surface.putTextClip(rect.x, rect.y + i, lines[i], rect.width);
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
