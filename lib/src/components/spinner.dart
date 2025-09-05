class TuiSpinner {
  final List<String> frames;
  int index = 0;

  TuiSpinner({List<String>? frames})
    : frames =
          frames ?? const ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

  void tick() {
    index = (index + 1) % frames.length;
  }

  String render() => frames[index];
}
