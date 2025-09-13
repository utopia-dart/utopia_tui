import 'dart:async';
import 'dart:isolate';

import 'package:dart_console/dart_console.dart' as dc;
import 'app.dart';
import 'events.dart';
import 'context.dart';
import 'terminal.dart';

/// Application runner that orchestrates the TUI event loop and rendering.
///
/// The [TuiRunner] is responsible for:
/// - Setting up the terminal environment
/// - Managing the event loop (keyboard input, resize events, ticks)
/// - Coordinating between events and UI updates
/// - Handling cleanup when the application exits
///
/// ## Usage
///
/// ```dart
/// final app = MyApp();
/// final runner = TuiRunner(app);
/// await runner.run(); // Blocks until app exits
/// ```
class TuiRunner {
  /// The TUI application to run.
  final TuiApp app;

  /// Terminal interface for low-level operations.
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

  /// Creates a new TUI runner for the given [app].
  ///
  /// Optionally specify a custom [terminal] interface for testing or
  /// alternative terminal implementations. If not provided, uses the
  /// default [TuiTerminal].
  TuiRunner(this.app, {TuiTerminalInterface? terminal})
    : terminal = terminal ?? TuiTerminal();

  /// Runs the TUI application until it exits.
  ///
  /// This method:
  /// 1. Initializes the terminal and application
  /// 2. Sets up event listeners for keyboard input and terminal resize
  /// 3. Starts the main event loop
  /// 4. Handles cleanup when the application exits
  ///
  /// The method returns when the user presses Ctrl+C or the application
  /// explicitly calls [stop].
  ///
  /// Throws exceptions if terminal setup fails or other critical errors occur.
  Future<void> run() async {
    var ctx = TuiContext(terminal);
    List<String>? lastVisible;
    List<String>? lastStyled;

    try {
      // Initialize the app
      try {
        app.init(ctx);
      } catch (e) {
        // If init fails, we still want to show something useful
        print('Error during app initialization: $e');
      }

      // Prepare terminal
      terminal.clearScreen();
      terminal.hideCursor();

      _lastWidth = terminal.width;
      _lastHeight = terminal.height;

      // Start input reader isolate
      _keyPort = ReceivePort();
      _keyIsolate = await Isolate.spawn(_keyReaderMain, _keyPort!.sendPort);

      // Wire key stream with error handling
      _keySub = _keyPort!.listen(
        (dynamic data) {
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
              _redraw(
                ctx,
                refLastVisible: lastVisible,
                refLastStyled: lastStyled,
                outLastVisible: (v) => lastVisible = v,
                outLastStyled: (s) => lastStyled = s,
                forceFull: true,
              );
            } catch (e) {
              // Log the error but don't crash the TUI
              try {
                ctx.clear();
                ctx.surface.putText(
                  0,
                  0,
                  'Error: ${e.toString().substring(0, ctx.width.clamp(0, 100))}',
                );
                final frameStyled = ctx.snapshotStyled();
                for (var r = 0; r < 1; r++) {
                  terminal.setCursor(r, 0);
                  terminal.write(frameStyled[r]);
                }
              } catch (_) {
                // If even error display fails, just continue
              }
            }
          }
        },
        onError: (error) {
          // Handle stream errors gracefully
          if (!_stopped) {
            _stopped = true;
            _stopCompleter.completeError('Input stream error: $error');
          }
        },
      );

      // Ticks with error handling
      final tickEvery = app.tickInterval;
      if (tickEvery != null) {
        _tickSub =
            Stream.periodic(
              tickEvery,
              (_) => TuiTickEvent(DateTime.now()),
            ).listen(
              (e) {
                try {
                  app.onEvent(e, ctx);
                  _redraw(
                    ctx,
                    refLastVisible: lastVisible,
                    refLastStyled: lastStyled,
                    outLastVisible: (v) => lastVisible = v,
                    outLastStyled: (s) => lastStyled = s,
                    forceFull: false,
                  );
                } catch (e) {
                  // Log tick errors but continue
                }
              },
              onError: (error) {
                // Handle tick stream errors
              },
            );
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
          lastVisible = null;
          lastStyled = null;
          terminal.clearScreen();
          _redraw(
            ctx,
            refLastVisible: lastVisible,
            refLastStyled: lastStyled,
            outLastVisible: (v) => lastVisible = v,
            outLastStyled: (s) => lastStyled = s,
            forceFull: true,
          );
        }
      });

      // Initial draw and wait for stop signal
      _redraw(
        ctx,
        refLastVisible: lastVisible,
        refLastStyled: lastStyled,
        outLastVisible: (v) => lastVisible = v,
        outLastStyled: (s) => lastStyled = s,
        forceFull: true,
      );
      _stopCompleter = Completer<void>();
      await _stopCompleter.future;
    } finally {
      await _dispose();
    }
  }

  void _redraw(
    TuiContext ctx, {
    List<String>? refLastVisible,
    List<String>? refLastStyled,
    required void Function(List<String>) outLastVisible,
    required void Function(List<String>) outLastStyled,
    bool forceFull = false,
  }) {
    // Build into buffer
    ctx.clear();
    try {
      app.build(ctx);
    } catch (e) {
      // If build fails, show error message
      ctx.surface.putText(
        0,
        0,
        'Build Error: ${e.toString().substring(0, (ctx.width - 12).clamp(10, 100))}',
      );
    }

    final frameVisible = ctx.snapshot();
    final frameStyled = ctx.snapshotStyled();

    // Diff and render changes: update if visible OR style changed OR forcing full redraw
    for (var r = 0; r < frameVisible.length; r++) {
      final lineV = frameVisible[r];
      final prevV = (refLastVisible != null && r < refLastVisible.length)
          ? refLastVisible[r]
          : null;
      final lineS = frameStyled[r];
      final prevS = (refLastStyled != null && r < refLastStyled.length)
          ? refLastStyled[r]
          : null;

      if (forceFull ||
          prevV == null ||
          prevS == null ||
          prevV != lineV ||
          prevS != lineS) {
        terminal.setCursor(r, 0);
        terminal.write(lineS);
      }
    }
    outLastVisible(frameVisible);
    outLastStyled(frameStyled);
  }

  Future<void> _dispose() async {
    await _tickSub?.cancel();
    await _resizeSub?.cancel();
    await _keySub?.cancel();
    _keyPort?.close();
    _keyIsolate?.kill(priority: Isolate.immediate);
    // Do not clear the screen; restore cursor + attributes and print newline
    terminal.write('\x1b[0m'); // reset attributes
    terminal.showCursor();
    terminal.write('\n'); // ensure prompt appears on a new line
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
