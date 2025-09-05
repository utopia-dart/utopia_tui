import 'dart:async';
import 'dart:isolate';

import 'package:dart_console/dart_console.dart' as dc;
import 'app.dart';
import 'events.dart';
import 'context.dart';
import 'terminal.dart';

// Runner orchestrates input, ticks, resize detection and rendering

class TuiRunner {
  final TuiApp app;
  final TuiTerminalInterface terminal;

  StreamSubscription? _tickSub;
  StreamSubscription? _resizeSub;
  StreamSubscription? _keySub;
  Isolate? _keyIsolate;
  ReceivePort? _keyPort;
  late final Completer<void> _stopCompleter;
  bool _stopped = false;

  int _lastWidth = 0;
  int _lastHeight = 0;

  TuiRunner(this.app, {TuiTerminalInterface? terminal})
      : terminal = terminal ?? TuiTerminal();

  Future<void> run() async {
    var ctx = TuiContext(terminal);
    app.init(ctx);
    List<String>? lastFrame;

    try {
      // Prepare terminal
      terminal.clearScreen();
      terminal.hideCursor();

      _lastWidth = terminal.width;
      _lastHeight = terminal.height;

      // Start input reader isolate
      _keyPort = ReceivePort();
      _keyIsolate = await Isolate.spawn(_keyReaderMain, _keyPort!.sendPort);

      // Wire key stream
      _keySub = _keyPort!.listen((dynamic data) {
        final ev = _decodeKeyPayload(data);
        if (ev != null) {
          if (ev.code == TuiKeyCode.ctrlC) {
            if (!_stopped) {
              _stopped = true;
              _stopCompleter.complete();
            }
            return;
          }
          try {
            app.onEvent(ev, ctx);
            _redraw(ctx, refLast: lastFrame, outLast: (f) => lastFrame = f);
          } catch (e) {
            if (!_stopped) {
              _stopped = true;
              _stopCompleter.completeError(e);
            }
          }
        }
      });

      // Ticks
      final tickEvery = app.tickInterval;
      if (tickEvery != null) {
        _tickSub = Stream.periodic(tickEvery, (_) => TuiTickEvent(DateTime.now()))
            .listen((e) {
          app.onEvent(e, ctx);
          _redraw(ctx, refLast: lastFrame, outLast: (f) => lastFrame = f);
        });
      }

      // Poll for resize
      _resizeSub = Stream.periodic(const Duration(milliseconds: 150)).listen((
        _,
      ) {
        final w = terminal.width;
        final h = terminal.height;
        if (w != _lastWidth || h != _lastHeight) {
          _lastWidth = w;
          _lastHeight = h;
          final e = TuiResizeEvent(w, h);
          // recreate context with new size and redraw fully
          ctx = TuiContext(terminal);
          app.onEvent(e, ctx);
          lastFrame = null;
          terminal.clearScreen();
          _redraw(ctx, refLast: lastFrame, outLast: (f) => lastFrame = f, forceFull: true);
        }
      });

      // Initial draw and wait for stop signal
      _redraw(ctx, refLast: lastFrame, outLast: (f) => lastFrame = f, forceFull: true);
      _stopCompleter = Completer<void>();
      await _stopCompleter.future;
    } finally {
      await _dispose();
    }
  }

  void _redraw(
    TuiContext ctx, {
    List<String>? refLast,
    required void Function(List<String>) outLast,
    bool forceFull = false,
  }) {
    // Build into buffer
    ctx.clear();
    app.build(ctx);
    final frame = ctx.snapshot();

    // Diff and render changes only
    for (var r = 0; r < frame.length; r++) {
      final line = frame[r];
      final prev = (refLast != null && r < refLast.length) ? refLast[r] : null;
      if (forceFull || prev == null || prev != line) {
        terminal.setCursor(r, 0);
        terminal.write(line);
      }
    }
    outLast(frame);
  }

  Future<void> _dispose() async {
    await _tickSub?.cancel();
    await _resizeSub?.cancel();
    await _keySub?.cancel();
    _keyPort?.close();
    _keyIsolate?.kill(priority: Isolate.immediate);
    terminal.showCursor();
  }
}

// --- Key reader isolate + mapping ---

void _keyReaderMain(SendPort sp) {
  final console = dc.Console();
  while (true) {
    final key = console.readKey();
    if (key.isControl) {
      final code = key.controlChar.toString();
      sp.send({'t': 'ctrl', 'code': code});
    } else {
      sp.send({'t': 'char', 'char': key.char});
    }
  }
}

TuiKeyEvent? _decodeKeyPayload(dynamic data) {
  if (data is! Map) return null;
  final t = data['t'] as String?;
  if (t == 'char') {
    final ch = data['char'] as String?;
    if (ch == null || ch.isEmpty) return null;
    return TuiKeyEvent(code: TuiKeyCode.printable, char: ch);
  }
  if (t == 'ctrl') {
    final codeStr = data['code'] as String?;
    if (codeStr == null) return null;
    return TuiKeyEvent(code: _mapControl(codeStr));
  }
  return null;
}

TuiKeyCode _mapControl(String controlName) {
  // Names like 'ControlCharacter.arrowUp'
  final n = controlName.split('.').last;
  switch (n) {
    case 'enter':
      return TuiKeyCode.enter;
    case 'escape':
      return TuiKeyCode.escape;
    case 'backspace':
      return TuiKeyCode.backspace;
    case 'delete':
      return TuiKeyCode.delete;
    case 'home':
      return TuiKeyCode.home;
    case 'end':
      return TuiKeyCode.end;
    case 'tab':
      return TuiKeyCode.tab;
    case 'arrowUp':
      return TuiKeyCode.arrowUp;
    case 'arrowDown':
      return TuiKeyCode.arrowDown;
    case 'arrowLeft':
      return TuiKeyCode.arrowLeft;
    case 'arrowRight':
      return TuiKeyCode.arrowRight;
    case 'pageUp':
      return TuiKeyCode.pageUp;
    case 'pageDown':
      return TuiKeyCode.pageDown;
    case 'ctrlA':
      return TuiKeyCode.ctrlA;
    case 'ctrlB':
      return TuiKeyCode.ctrlB;
    case 'ctrlC':
      return TuiKeyCode.ctrlC;
    case 'ctrlD':
      return TuiKeyCode.ctrlD;
    case 'ctrlE':
      return TuiKeyCode.ctrlE;
    case 'ctrlF':
      return TuiKeyCode.ctrlF;
    case 'ctrlG':
      return TuiKeyCode.ctrlG;
    case 'ctrlH':
      return TuiKeyCode.ctrlH;
    case 'ctrlJ':
      return TuiKeyCode.ctrlJ;
    case 'ctrlK':
      return TuiKeyCode.ctrlK;
    case 'ctrlL':
      return TuiKeyCode.ctrlL;
    case 'ctrlN':
      return TuiKeyCode.ctrlN;
    case 'ctrlO':
      return TuiKeyCode.ctrlO;
    case 'ctrlP':
      return TuiKeyCode.ctrlP;
    case 'ctrlQ':
      return TuiKeyCode.ctrlQ;
    case 'ctrlR':
      return TuiKeyCode.ctrlR;
    case 'ctrlS':
      return TuiKeyCode.ctrlS;
    case 'ctrlT':
      return TuiKeyCode.ctrlT;
    case 'ctrlU':
      return TuiKeyCode.ctrlU;
    case 'ctrlV':
      return TuiKeyCode.ctrlV;
    case 'ctrlW':
      return TuiKeyCode.ctrlW;
    case 'ctrlX':
      return TuiKeyCode.ctrlX;
    case 'ctrlY':
      return TuiKeyCode.ctrlY;
    case 'ctrlZ':
      return TuiKeyCode.ctrlZ;
    default:
      return TuiKeyCode.unknown;
  }
}
