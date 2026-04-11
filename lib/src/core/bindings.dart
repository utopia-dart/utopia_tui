import 'events.dart';
import '../components/text_input.dart';

class TuiBindings {
  static bool textEdit(TuiKeyEvent e, TuiTextInput input) {
    if (e.isPrintable) {
      input.insert(e.char!);
      return true;
    }
    switch (e.code) {
      case TuiKeyCode.arrowLeft:
        input.left();
        return true;
      case TuiKeyCode.arrowRight:
        input.right();
        return true;
      case TuiKeyCode.backspace:
        input.backspace();
        return true;
      case TuiKeyCode.delete:
        input.del();
        return true;
      default:
        return false;
    }
  }
}
