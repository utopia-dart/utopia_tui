// Core Tui event types and key codes

sealed class TuiEvent {
  const TuiEvent();
}

class TuiTickEvent extends TuiEvent {
  final DateTime at;
  const TuiTickEvent(this.at);
}

class TuiResizeEvent extends TuiEvent {
  final int width;
  final int height;
  const TuiResizeEvent(this.width, this.height);
}

enum TuiKeyCode {
  // Printable is represented via [char]
  printable,

  // Control/navigation
  enter,
  escape,
  backspace,
  delete,
  home,
  end,
  tab,
  arrowUp,
  arrowDown,
  arrowLeft,
  arrowRight,
  pageUp,
  pageDown,
  ctrlA,
  ctrlB,
  ctrlC,
  ctrlD,
  ctrlE,
  ctrlF,
  ctrlG,
  ctrlH,
  ctrlJ,
  ctrlK,
  ctrlL,
  ctrlN,
  ctrlO,
  ctrlP,
  ctrlQ,
  ctrlR,
  ctrlS,
  ctrlT,
  ctrlU,
  ctrlV,
  ctrlW,
  ctrlX,
  ctrlY,
  ctrlZ,

  unknown,
}

class TuiKeyEvent extends TuiEvent {
  final TuiKeyCode code;
  final String? char; // set only for printable
  const TuiKeyEvent({required this.code, this.char});

  bool get isPrintable => code == TuiKeyCode.printable && char != null;
}
