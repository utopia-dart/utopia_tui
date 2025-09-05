import '../core/style.dart';

class TuiSpinner {
  final List<String> frames;
  int index = 0;
  final TuiStyle? style;

  TuiSpinner({List<String>? frames, this.style})
      : frames = frames ?? const ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

  void tick() {
    index = (index + 1) % frames.length;
  }

  String render() {
    final s = frames[index];
    return style != null ? style!.apply(s) : s;
  }
}
