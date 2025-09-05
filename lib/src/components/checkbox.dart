import '../core/style.dart';

class TuiCheckbox {
  bool value;
  final String label;
  final TuiStyle? labelStyle;
  final TuiStyle? boxStyle;

  TuiCheckbox({this.value = false, this.label = '', this.labelStyle, this.boxStyle});

  void toggle() => value = !value;

  String render(int width) {
    var box = value ? '[x]' : '[ ]';
    if (boxStyle != null) box = boxStyle!.apply(box);
    var text = labelStyle != null ? labelStyle!.apply(label) : label;
    final line = '$box $text';
    return line.length > width ? line.substring(0, width) : line.padRight(width);
  }
}

