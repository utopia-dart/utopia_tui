import '../core/style.dart';

class TuiButton {
  final String label;
  bool focused;
  final TuiStyle? normalStyle;
  final TuiStyle? focusedStyle;

  TuiButton(this.label, {this.focused = false, this.normalStyle, this.focusedStyle});

  String render(int width) {
    final base = ' $label ';
    final styled = focused ? (focusedStyle?.apply(base) ?? base) : (normalStyle?.apply(base) ?? base);
    return styled.length > width ? styled.substring(0, width) : styled.padRight(width);
  }
}

