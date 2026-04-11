import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
        print('Error during app initialization: $e');
      }

      // Prepare terminal: switch to alternate screen buffer
      terminal.write('\x1b[?1049h');
      terminal.clearScreen();
      terminal.hideCursor();

      _lastWidth = terminal.width;
      _lastHeight = terminal.height;

      // Set up raw stdin input (async, no isolate needed)
      stdin.echoMode = false;
      stdin.lineMode = false;

      _keySub = stdin.listen(
        (List<int> bytes) {
          final events = _parseInputBytes(bytes);
          for (final ev in events) {
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
              } catch (_) {}
            }
          }
        },
        onError: (error) {
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
    ctx.clear();
    try {
      app.build(ctx);
      ctx.renderDialogOverlay();
    } catch (e) {
      ctx.surface.putText(
        0,
        0,
        'Build Error: ${e.toString().substring(0, (ctx.width - 12).clamp(10, 100))}',
      );
    }

    final frameVisible = ctx.snapshot();
    final frameStyled = ctx.snapshotStyled();

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
    // Restore stdin mode before cancelling the subscription,
    // because cancel() closes the stream and invalidates the fd.
    try {
      stdin.lineMode = true;
      stdin.echoMode = true;
    } catch (_) {}
    await _keySub?.cancel();
    terminal.write('\x1b[0m');
    terminal.showCursor();
    terminal.write('\x1b[?1049l');
  }
}

// --- Async stdin byte-level key parser ---

List<TuiKeyEvent> _parseInputBytes(List<int> bytes) {
  final events = <TuiKeyEvent>[];
  var i = 0;

  while (i < bytes.length) {
    final b = bytes[i];

    if (b == 27) {
      // ESC - check for escape sequence
      if (i + 1 < bytes.length && bytes[i + 1] == 91) {
        // ESC [ sequence
        i += 2;
        if (i < bytes.length) {
          final seq = bytes[i];
          i++;
          switch (seq) {
            case 65:
              events.add(const TuiKeyEvent(code: TuiKeyCode.arrowUp));
            case 66:
              events.add(const TuiKeyEvent(code: TuiKeyCode.arrowDown));
            case 67:
              events.add(const TuiKeyEvent(code: TuiKeyCode.arrowRight));
            case 68:
              events.add(const TuiKeyEvent(code: TuiKeyCode.arrowLeft));
            case 72:
              events.add(const TuiKeyEvent(code: TuiKeyCode.home));
            case 70:
              events.add(const TuiKeyEvent(code: TuiKeyCode.end));
            case 51: // ESC [ 3 ~ = Delete
              if (i < bytes.length && bytes[i] == 126) {
                i++;
                events.add(const TuiKeyEvent(code: TuiKeyCode.delete));
              }
            case 53: // ESC [ 5 ~ = Page Up
              if (i < bytes.length && bytes[i] == 126) {
                i++;
                events.add(const TuiKeyEvent(code: TuiKeyCode.pageUp));
              }
            case 54: // ESC [ 6 ~ = Page Down
              if (i < bytes.length && bytes[i] == 126) {
                i++;
                events.add(const TuiKeyEvent(code: TuiKeyCode.pageDown));
              }
          }
        }
      } else {
        // Bare ESC
        events.add(const TuiKeyEvent(code: TuiKeyCode.escape));
        i++;
      }
    } else if (b == 13 || b == 10) {
      events.add(const TuiKeyEvent(code: TuiKeyCode.enter));
      i++;
    } else if (b == 9) {
      events.add(const TuiKeyEvent(code: TuiKeyCode.tab));
      i++;
    } else if (b == 127 || b == 8) {
      events.add(const TuiKeyEvent(code: TuiKeyCode.backspace));
      i++;
    } else if (b >= 1 && b <= 26) {
      events.add(TuiKeyEvent(code: _ctrlByteToCode(b)));
      i++;
    } else if (b >= 32 && b < 127) {
      events.add(
        TuiKeyEvent(code: TuiKeyCode.printable, char: String.fromCharCode(b)),
      );
      i++;
    } else if (b >= 128) {
      // UTF-8 multi-byte sequence
      final charLen = _utf8CharLen(b);
      if (i + charLen <= bytes.length) {
        try {
          final ch = utf8.decode(bytes.sublist(i, i + charLen));
          events.add(TuiKeyEvent(code: TuiKeyCode.printable, char: ch));
        } catch (_) {}
        i += charLen;
      } else {
        i++;
      }
    } else {
      i++;
    }
  }

  return events;
}

int _utf8CharLen(int leadByte) {
  if (leadByte < 0xC0) return 1;
  if (leadByte < 0xE0) return 2;
  if (leadByte < 0xF0) return 3;
  return 4;
}

TuiKeyCode _ctrlByteToCode(int byte) {
  const map = <int, TuiKeyCode>{
    1: TuiKeyCode.ctrlA,
    2: TuiKeyCode.ctrlB,
    3: TuiKeyCode.ctrlC,
    4: TuiKeyCode.ctrlD,
    5: TuiKeyCode.ctrlE,
    6: TuiKeyCode.ctrlF,
    7: TuiKeyCode.ctrlG,
    8: TuiKeyCode.ctrlH,
    10: TuiKeyCode.ctrlJ,
    11: TuiKeyCode.ctrlK,
    12: TuiKeyCode.ctrlL,
    14: TuiKeyCode.ctrlN,
    15: TuiKeyCode.ctrlO,
    16: TuiKeyCode.ctrlP,
    17: TuiKeyCode.ctrlQ,
    18: TuiKeyCode.ctrlR,
    19: TuiKeyCode.ctrlS,
    20: TuiKeyCode.ctrlT,
    21: TuiKeyCode.ctrlU,
    22: TuiKeyCode.ctrlV,
    23: TuiKeyCode.ctrlW,
    24: TuiKeyCode.ctrlX,
    25: TuiKeyCode.ctrlY,
    26: TuiKeyCode.ctrlZ,
  };
  return map[byte] ?? TuiKeyCode.unknown;
}
