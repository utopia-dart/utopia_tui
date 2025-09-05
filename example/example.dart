import 'package:utopia_tui/utopia_tui.dart';

// Styled demo using the Tui API, buffered rendering, and components

class DemoApp extends TuiApp {
  // Components and state
  var tabs = TuiTabs(
    const ['Home', 'Search', 'Builds'],
    activeStyle: const TuiStyle(bold: true, fg: 39),
    inactiveStyle: const TuiStyle(fg: 250),
  );
  var menu = TuiList(
    const ['Overview', 'System Info', 'Tasks', 'Logs', 'About'],
    selectedStyle: const TuiStyle(bold: true, fg: 39),
    unselectedStyle: const TuiStyle(fg: 250),
  );
  final input = TuiTextInput(cursorStyle: const TuiStyle(bold: true, fg: 39));
  final spinner = TuiSpinner(style: const TuiStyle(fg: 39));
  final progress = TuiProgressBar(
    value: 0,
    barStyle: const TuiStyle(fg: 250),
    fillStyle: const TuiStyle(fg: 39),
  );
  final statusBar = TuiStatusBar(style: const TuiStyle(bg: 240, fg: 16));
  final checkbox = TuiCheckbox(label: 'Enable feature', labelStyle: const TuiStyle(fg: 252), boxStyle: const TuiStyle(fg: 39));
  final button = TuiButton('Run', focused: true, normalStyle: const TuiStyle(fg: 252), focusedStyle: const TuiStyle(bold: true, fg: 39));

  double progressValue = 0;
  bool showHelp = true;
  bool isLightTheme = false;
  bool contentBg = false;
  int focus = 1; // 0=tabs,1=menu,2=input,3=button

  @override
  Duration? get tickInterval => const Duration(milliseconds: 120);

  @override
  void onEvent(TuiEvent event, TuiContext context) {
    if (event is TuiTickEvent) {
      spinner.tick();
      input.tick(focused: focus == 2);
      progressValue += 0.01;
      if (progressValue > 1) progressValue = 0;
      progress.value = progressValue;
      return;
    }
    if (event is TuiKeyEvent) {
      // Printable keys
      if (event.isPrintable) {
        final ch = event.char!.toLowerCase();
        if (ch == '1') tabs.index = 0;
        if (ch == '2') tabs.index = 1;
        if (ch == '3') tabs.index = 2;
        if (ch == 't') {
          isLightTheme = !isLightTheme;
          final theme = isLightTheme ? TuiTheme.light : TuiTheme.dark;
          tabs = TuiTabs(tabs.tabs,
              index: tabs.index,
              activeStyle: theme.accent,
              inactiveStyle: theme.dim);
          menu = TuiList(menu.items,
              selectedIndex: menu.selectedIndex,
              selectedStyle: theme.accent,
              unselectedStyle: theme.dim);
          return;
        }
        if (ch == 'g') {
          contentBg = !contentBg;
          return;
        }
        if (focus == 2) {
          // Send text to input only when focused
          TuiBindings.textEdit(event, input);
        }
        return;
      }
      // Non-printable
      switch (event.code) {
        case TuiKeyCode.arrowUp:
        case TuiKeyCode.arrowDown:
          if (focus == 1) TuiBindings.listNavigation(event, menu);
          break;
        case TuiKeyCode.arrowLeft:
        case TuiKeyCode.arrowRight:
          if (focus == 0) TuiBindings.tabNavigation(event, tabs);
          if (focus == 2) TuiBindings.textEdit(event, input);
          break;
        case TuiKeyCode.backspace:
        case TuiKeyCode.delete:
          if (focus == 2) TuiBindings.textEdit(event, input);
          break;
        case TuiKeyCode.enter:
          if (focus == 3) {
            checkbox.toggle();
          } else {
            showHelp = !showHelp;
          }
          break;
        case TuiKeyCode.tab:
          focus = (focus + 1) % 4;
          button.focused = (focus == 3);
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
    final headerH = 2; // title + tabs
    final footerH = 1; // status bar
    final contentH = h - headerH - footerH;
    final sideW = (w * 0.28).round().clamp(16, w - 12);
    final contentW = w - sideW;

    // Title + focus hint (theme aware)
    final theme = isLightTheme ? TuiTheme.light : TuiTheme.dark;
    final focusNames = ['Tabs', 'Menu', 'Input', 'Button'];
    final title = (theme.titleStyle ?? const TuiStyle(bold: true)).apply(' Tui Demo - Ctrl+C to quit ');
    final hint = (theme.dim ?? const TuiStyle(fg: 245)).apply(' Focus: ${focusNames[focus]} (Tab to cycle) ');
    context.writeRow(0, 0, w, (title + hint).padRight(w));
    // Tabs line (underline active when focused)
    context.writeRow(1, 0, w, tabs.render(w, focused: focus == 0));

    // Sidebar + focus bg
    final sideLines = menu.render(sideW, contentH);
    final sidePanel = TuiPanel(
            title: ' Menu ',
            titleStyle: theme.titleStyle,
            borderStyle: focus == 1 && theme.focusBorderStyle != null
                ? theme.focusBorderStyle
                : theme.borderStyle)
        .wrap(sideLines, sideW, contentH);
    for (var i = 0; i < sidePanel.length; i++) {
      context.writeRow(headerH + i, 0, sideW, sidePanel[i]);
    }

    // Main content varies by tab
    final mainLines = <String>[];
    if (tabs.index == 0) {
      mainLines.add('Selected: ${menu.items[menu.selectedIndex]}   ${spinner.render()}');
      mainLines.add('');
      mainLines.add('Input:');
      mainLines.add(input.render(contentW - 4));
      mainLines.add('');
      mainLines.add('Progress: ${(progressValue * 100).round()}%');
      mainLines.add(progress.render(contentW - 4));
      mainLines.add('');
      mainLines.add(checkbox.render(contentW - 4));
      mainLines.add(button.render(12));
      mainLines.add('');
      final table = TuiTable(
        headers: const ['Branch', 'Status', 'Duration'],
        rows: const [
          ['main', 'passing', '4m 12s'],
          ['develop', 'queued', '--'],
          ['feature-x', 'failed', '2m 03s'],
        ],
        columnWidths: const [14, 10, 10],
      );
      for (final line in table.render(contentW)) {
        mainLines.add(line);
      }
    } else if (tabs.index == 1) {
      mainLines.add('Search');
      mainLines.add('');
      mainLines.add('Query:');
      mainLines.add(input.render(contentW - 4));
      mainLines.add('');
      mainLines.add('Results:');
      for (var i = 0; i < 10; i++) {
        mainLines.add('- Result item ${i + 1}');
      }
    } else {
      mainLines.add('Recent builds');
      mainLines.add('');
      final table = TuiTable(
        headers: const ['Build', 'Status', 'When'],
        rows: const [
          ['#421', 'passing', '10m ago'],
          ['#420', 'failed', '1h ago'],
          ['#419', 'queued', '1h ago'],
        ],
        columnWidths: const [10, 10, 14],
      );
      for (final line in table.render(contentW)) {
        mainLines.add(line);
      }
    }
    if (showHelp) {
      mainLines.add('');
      mainLines.add('Help: arrows=move, enter=toggle/help-click, tab=cycle focus');
    }
    final panelLines = TuiPanel(
            title: ' Content ',
            titleStyle: theme.titleStyle,
            borderStyle: focus == 2 && theme.focusBorderStyle != null
                ? theme.focusBorderStyle
                : theme.borderStyle)
        .wrap(mainLines, contentW, contentH);
    // Content bg toggle
    Iterable<String> contentApplied = panelLines;
    if (contentBg) {
      final bg = TuiStyle(bg: isLightTheme ? 254 : 236);
      contentApplied = contentApplied.map((l) => bg.apply(l));
    }
    final contentLines = contentApplied.toList();
    for (var i = 0; i < contentLines.length; i++) {
      context.writeRow(headerH + i, sideW, contentW, contentLines[i]);
    }

    // Status bar
    final left = 'Size: ${w}x$h';
    final center = 'Arrows move | Enter toggles help | Ctrl+C quits';
    final right = 'Tui ${DateTime.now().toLocal().toIso8601String().substring(11, 19)}';
    context.writeRow(h - 1, 0, w, statusBar.render(w, left: left, center: center, right: right));
  }
}

void main() async {
  final runner = TuiRunner(DemoApp());
  try {
    await runner.run();
  } catch (_) {}
}
