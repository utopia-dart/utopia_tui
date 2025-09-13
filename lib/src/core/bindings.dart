import 'events.dart';
import '../components/list_menu.dart';
import '../components/text_input.dart';
import '../components/tabs.dart';

class TuiBindings {
  static bool listNavigation(TuiKeyEvent e, TuiList list) {
    switch (e.code) {
      case TuiKeyCode.arrowUp:
        list.moveUp();
        return true;
      case TuiKeyCode.arrowDown:
        list.moveDown();
        return true;
      default:
        return false;
    }
  }

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

  static bool tabNavigation(TuiKeyEvent e, TuiTabs tabs) {
    switch (e.code) {
      case TuiKeyCode.arrowLeft:
        if (tabs.index > 0) tabs.index--;
        return true;
      case TuiKeyCode.arrowRight:
        if (tabs.index < tabs.tabs.length - 1) tabs.index++;
        return true;
      default:
        return false;
    }
  }
}
