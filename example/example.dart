import 'package:utopia_tui/utopia_tui.dart';

// Minimal demo using the simplified framework and buffered rendering

class DemoApp extends TuiApp {
  final menu = TuiList(const ['Home', 'Search', 'Builds', 'Logs', 'About']);
  final input = TuiTextInput();
  final spinner = TuiSpinner();
  final progress = TuiProgressBar(value: 0);
  double progressValue = 0;
  bool showHelp = true;

  @override
  Duration? get tickInterval => const Duration(milliseconds: 120);

  @override
  void onEvent(TuiEvent event, TuiContext context) {
    if (event is TuiTickEvent) {
      spinner.tick();
      progressValue += 0.01;
      if (progressValue > 1) progressValue = 0;
      progress.value = progressValue;
      return;
    }
    if (event is TuiKeyEvent) {
      if (event.isPrintable) {
        input.insert(event.char!);
        return;
      }
      switch (event.code) {
        case TuiKeyCode.arrowUp:
          menu.moveUp();
          break;
        case TuiKeyCode.arrowDown:
          menu.moveDown();
          break;
        case TuiKeyCode.arrowLeft:
          input.left();
          break;
        case TuiKeyCode.arrowRight:
          input.right();
          break;
        case TuiKeyCode.backspace:
          input.backspace();
          break;
        case TuiKeyCode.delete:
          input.del();
          break;
        case TuiKeyCode.enter:
          showHelp = !showHelp;
          break;
        default:
          break;
      }
    }
  }

  @override
  void build(TuiContext context) {
    final w = context.width;
    final h = context.height;

    // Layout
    final headerH = 1;
    final footerH = 1;
    final contentH = h - headerH - footerH;
    final sideW = (w * 0.28).round().clamp(16, w - 12);
    final contentW = w - sideW;

    // Header
    final title = ' Utopia TUI • Minimal Demo • Ctrl+C to quit ';
    context.writeRow(0, 0, w, title.padRight(w));

    // Sidebar
    final sideLines = menu.render(sideW, contentH);
    final sidePanel = TuiPanel(title: ' Menu ').wrap(sideLines, sideW, contentH);
    for (var i = 0; i < sidePanel.length; i++) {
      context.writeRow(headerH + i, 0, sideW, sidePanel[i]);
    }

    // Main content
    final mainLines = <String>[];
    mainLines.add('Selected: ${menu.items[menu.selectedIndex]}  ${spinner.render()}');
    mainLines.add('');
    mainLines.add('Input:');
    mainLines.add(input.render(contentW - 4));
    mainLines.add('');
    mainLines.add('Progress: ${(progressValue * 100).round()}%');
    mainLines.add(progress.render(contentW - 4));
    mainLines.add('');
    if (showHelp) {
      mainLines.add('Help: ↑/↓ menu • ←/→ cursor • type to edit • Enter toggles help • Ctrl+C quits');
    }
    final contentPanel = TuiPanel(title: ' Content ').wrap(mainLines, contentW, contentH);
    for (var i = 0; i < contentPanel.length; i++) {
      context.writeRow(headerH + i, sideW, contentW, contentPanel[i]);
    }

    // Footer
    final footer = 'Size: ${w}x$h  •  q: not bound  •  Ctrl+C: quit';
    context.writeRow(h - 1, 0, w, footer.padRight(w));
  }
}

void main() async {
  final runner = TuiRunner(DemoApp());
  try {
    await runner.run();
  } catch (_) {}
}
