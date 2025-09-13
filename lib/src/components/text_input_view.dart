import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';
import '../core/style.dart';
import 'text_input.dart';

/// View component for rendering TuiTextInput
class TuiTextInputView extends TuiComponent {
  final TuiTextInput input;

  TuiTextInputView(this.input);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    // Show box if enabled
    if (input.showBox) {
      surface.putText(rect.x, rect.y, '[');
      surface.putText(rect.x + rect.width - 1, rect.y, ']');
    }

    // Calculate text area
    final textX = input.showBox ? rect.x + 1 : rect.x;
    final textWidth = input.showBox ? rect.width - 2 : rect.width;

    // Display text
    var displayText = input.text;
    if (displayText.length > textWidth) {
      // Scroll text if it's too long
      final start = (input.cursor - textWidth + 1).clamp(0, displayText.length);
      displayText = displayText.substring(start);
    }

    surface.putTextClip(textX, rect.y, displayText, textWidth);

    // Show cursor
    if (input.blinkOn) {
      final cursorPos = input.cursor.clamp(0, textWidth - 1);
      final cursorX = textX + cursorPos;
      if (cursorX < rect.x + rect.width) {
        final style = input.cursorStyle ?? const TuiStyle(bg: 255);
        surface.putText(cursorX, rect.y, ' ', style: style);
      }
    }
  }
}
