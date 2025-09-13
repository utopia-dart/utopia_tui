import '../core/interactive.dart';
import '../core/canvas.dart';
import '../core/rect.dart';
import '../core/events.dart';
import '../core/bindings.dart';
import 'text_input.dart';
import 'text_input_view.dart';

/// Interactive text input with enhanced input handling
class TuiInteractiveTextInput extends TuiInteractiveComponent {
  final TuiTextInput textInput;
  bool _editMode = false;

  /// Whether the text input is in edit mode (accepting text input)
  bool get editMode => _editMode;

  TuiInteractiveTextInput(this.textInput);

  @override
  bool handleInput(TuiEvent event) {
    if (!focused) return false;

    if (event is TuiKeyEvent && event.isPrintable) {
      final ch = event.char!.toLowerCase();

      // Toggle edit mode with 'e'
      if (ch == 'e') {
        _editMode = !_editMode;
        markNeedsRebuild();
        return true;
      }

      // Handle edit mode inputs
      if (_editMode) {
        TuiBindings.textEdit(event, textInput);
        markNeedsRebuild();
        return true;
      }
    }

    // Handle special keys in edit mode
    if (event is TuiKeyEvent && _editMode) {
      switch (event.code) {
        case TuiKeyCode.backspace:
          textInput.backspace();
          markNeedsRebuild();
          return true;
        case TuiKeyCode.delete:
          textInput.del();
          markNeedsRebuild();
          return true;
        case TuiKeyCode.escape:
          _editMode = false;
          markNeedsRebuild();
          return true;
        default:
          break;
      }
    }

    return false;
  }

  @override
  String get focusHint =>
      _editMode ? 'EDIT MODE: type text, ESC=exit, e=exit' : 'e=edit mode';

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    TuiTextInputView(textInput).paintSurface(surface, rect);
  }
}
