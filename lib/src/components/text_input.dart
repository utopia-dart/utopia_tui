import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';
import '../core/style.dart';

class TuiTextInput extends TuiComponent {
  String text;
  int cursor; // 0..text.length
  final int maxLength;
  final TuiStyle? cursorStyle;
  bool blinkOn = true;
  bool showBox = true;

  TuiTextInput({
    this.text = '',
    this.cursor = 0,
    this.maxLength = 256,
    this.cursorStyle,
    this.showBox = true,
  });

  void tick({bool focused = false}) {
    if (focused) {
      blinkOn = !blinkOn;
    } else {
      blinkOn = true; // keep cursor visible when not focused
    }
  }

  void insert(String ch) {
    if (text.length >= maxLength) return;
    text = text.substring(0, cursor) + ch + text.substring(cursor);
    cursor += ch.length;
  }

  void backspace() {
    if (cursor > 0) {
      text = text.substring(0, cursor - 1) + text.substring(cursor);
      cursor--;
    }
  }

  void del() {
    if (cursor < text.length) {
      text = text.substring(0, cursor) + text.substring(cursor + 1);
    }
  }

  void left() {
    if (cursor > 0) cursor--;
  }

  void right() {
    if (cursor < text.length) cursor++;
  }

  String render(int width) {
    // Render whole text inside [ ... ] and show a blinking underscore cursor.
    var inside = text;

    // Ensure there is a placeholder at cursor position if at end
    final idx = cursor.clamp(0, inside.length);
    if (idx == inside.length) inside = '$inside ';

    // Insert a blinking underscore at the cursor position
    final cursorChar = blinkOn ? '_' : ' ';
    final styledCursor = (cursorStyle ?? const TuiStyle(bold: true)).apply(
      cursorChar,
    );
    inside =
        inside.substring(0, idx) + styledCursor + inside.substring(idx + 1);

    final boxed = showBox ? '[$inside]' : inside;
    return boxed;
  }

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);
    if (showBox) {
      surface.putText(rect.x, rect.y, '[');
      surface.putText(rect.x + rect.width - 1, rect.y, ']');
    }
    final textX = showBox ? rect.x + 1 : rect.x;
    final textWidth = showBox ? rect.width - 2 : rect.width;
    var displayText = text;
    if (displayText.length > textWidth) {
      final start = (cursor - textWidth + 1).clamp(0, displayText.length);
      displayText = displayText.substring(start);
    }
    surface.putTextClip(textX, rect.y, displayText, textWidth);
    if (blinkOn) {
      final cursorPos = cursor.clamp(0, textWidth - 1);
      final cursorX = textX + cursorPos;
      if (cursorX < rect.x + rect.width) {
        final cStyle = cursorStyle ?? const TuiStyle(bg: 255);
        surface.putText(cursorX, rect.y, ' ', style: cStyle);
      }
    }
  }
}
