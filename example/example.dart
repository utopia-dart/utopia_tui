import 'dart:io';
import 'package:utopia_tui/utopia_tui.dart';

// Styled demo using the Tui API, buffered rendering, and components

class DemoApp extends TuiApp {
  // Components and state
  var tabs = TuiTabs(
    const ['Example', 'README', 'Keys'],
    activeStyle: const TuiStyle(bold: true, fg: 39),
    inactiveStyle: const TuiStyle(fg: 250),
  );
  var menu = TuiList(
    const [
      'List',
      'Panel',
      'TextInput',
      'ProgressBar',
      'Spinner',
      'Tabs',
      'StatusBar',
      'Checkbox',
      'Button',
      'Table',
      'ScrollView',
    ],
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
  final checkbox = TuiCheckbox(
    label: 'Enable feature',
    labelStyle: const TuiStyle(fg: 252),
    boxStyle: const TuiStyle(fg: 39),
  );
  final button = TuiButton(
    'Run',
    focused: true,
    normalStyle: const TuiStyle(fg: 252),
    focusedStyle: const TuiStyle(bold: true, fg: 39),
  );
  final scroll = TuiScrollView();

  double progressValue = 0;
  bool showHelp = true;
  bool isLightTheme = false;
  bool contentBg = false;
  // Focus model: 0 = Tabs (top), 1 = Bottom area (panels)
  int focusLevel = 0;
  // When on Example tab, which bottom pane is active: 0=left (menu), 1=right (content)
  int bottomPane = 0;
  String? _lastChar; // for vim 'gg'
  int contentHCache = 0;

  @override
  void init(TuiContext context) {
    try {
      final readme = File('README.md');
      if (readme.existsSync()) {
        scroll.setText(readme.readAsStringSync());
      } else {
        scroll.setText('README.md not found');
      }
    } catch (_) {
      scroll.setText('Unable to load README.md');
    }
  }

  @override
  Duration? get tickInterval => const Duration(milliseconds: 120);

  @override
  void onEvent(TuiEvent event, TuiContext context) {
    if (event is TuiTickEvent) {
      spinner.tick();
      final isInputFocused =
          (tabs.index == 0 &&
          focusLevel == 1 &&
          bottomPane == 1 &&
          menu.items[menu.selectedIndex] == 'TextInput');
      input.tick(focused: isInputFocused);
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
        if (ch == 't' || ch == 'd') {
          isLightTheme = !isLightTheme;
          final theme = isLightTheme ? TuiTheme.light : TuiTheme.dark;
          tabs = TuiTabs(
            tabs.tabs,
            index: tabs.index,
            activeStyle: theme.accent,
            inactiveStyle: theme.dim,
          );
          menu = TuiList(
            menu.items,
            selectedIndex: menu.selectedIndex,
            selectedStyle: theme.accent,
            unselectedStyle: theme.dim,
          );
          return;
        }
        if (ch == 'g' &&
            !(focusLevel == 1 && (tabs.index != 0 || bottomPane == 1))) {
          contentBg = !contentBg;
          return;
        }
        // When Example/left (menu) is focused, j/k navigate the menu
        if (tabs.index == 0 && focusLevel == 1 && bottomPane == 0) {
          if (ch == 'j') {
            menu.moveDown();
            return;
          }
          if (ch == 'k') {
            menu.moveUp();
            return;
          }
        }
        // Otherwise, j/k switch focus top/bottom
        if (ch == 'j') {
          focusLevel = 1;
          return;
        }
        if (ch == 'k') {
          focusLevel = 0;
          return;
        }
        // Horizontal navigation
        if (focusLevel == 0 && ch == 'h') {
          if (tabs.index > 0) tabs.index--;
          return;
        }
        if (focusLevel == 0 && ch == 'l') {
          if (tabs.index < tabs.tabs.length - 1) tabs.index++;
          return;
        }
        if (focusLevel == 1) {
          if (tabs.index == 0) {
            if (ch == 'h') {
              bottomPane = 0;
              return;
            }
            if (ch == 'l') {
              bottomPane = 1;
              return;
            }
          }
          // Scroll view in README or ScrollView demo
          final inScroll =
              tabs.index == 1 ||
              (tabs.index == 0 &&
                  bottomPane == 1 &&
                  menu.items[menu.selectedIndex] == 'ScrollView');
          if (inScroll) {
            if (_lastChar == 'g' && ch == 'g') {
              scroll.scrollTop();
              _lastChar = null;
              return;
            }
            if (ch == 'g') {
              _lastChar = 'g';
              return;
            }
            if (ch == 'G') {
              scroll.scrollBottom(contentHCache);
              return;
            }
          }
          // Text input typing
          if (tabs.index == 0 &&
              bottomPane == 1 &&
              menu.items[menu.selectedIndex] == 'TextInput') {
            TuiBindings.textEdit(event, input);
            return;
          }
        }
        return;
      }
      // Non-printable
      switch (event.code) {
        case TuiKeyCode.arrowUp:
          if (focusLevel == 1 && tabs.index == 0 && bottomPane == 0) {
            menu.moveUp();
          } else if (focusLevel == 1) {
            scroll.scrollBy(-1, contentHCache);
          }
          break;
        case TuiKeyCode.arrowDown:
          if (focusLevel == 1 && tabs.index == 0 && bottomPane == 0) {
            menu.moveDown();
          } else if (focusLevel == 1) {
            scroll.scrollBy(1, contentHCache);
          }
          break;
        case TuiKeyCode.arrowLeft:
          if (focusLevel == 0) {
            if (tabs.index > 0) tabs.index--;
          }
          break;
        case TuiKeyCode.arrowRight:
          if (focusLevel == 0) {
            if (tabs.index < tabs.tabs.length - 1) tabs.index++;
          }
          break;
        case TuiKeyCode.backspace:
          if (focusLevel == 1 &&
              tabs.index == 0 &&
              bottomPane == 1 &&
              menu.items[menu.selectedIndex] == 'TextInput') {
            input.backspace();
          }
          break;
        case TuiKeyCode.delete:
          if (focusLevel == 1 &&
              tabs.index == 0 &&
              bottomPane == 1 &&
              menu.items[menu.selectedIndex] == 'TextInput') {
            input.del();
          }
          break;
        case TuiKeyCode.enter:
          showHelp = !showHelp;
          break;
        case TuiKeyCode.escape:
          focusLevel = 0; // ESC to top (Tabs)
          break;
        case TuiKeyCode.tab:
          // Disabled: use j/k to switch top/bottom
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
    final bool showSidebar = tabs.index == 0; // Only Example tab has sidebar
    final sideW = showSidebar ? (w * 0.28).round().clamp(16, w - 12) : 0;

    // Title + focus hint (theme aware)
    final theme = isLightTheme ? TuiTheme.light : TuiTheme.dark;
    final focusNames = ['Tabs', 'Bottom'];

    // Create header as two separate styled components in a row
    final titleText = ' Tui Demo - Ctrl+C to quit ';
    final hintText =
        ' Focus: ${focusNames[focusLevel]} (j/k to switch, h/l sideways) ';

    final headerComponent = TuiRow(
      children: [
        TuiText(
          titleText,
          style: theme.titleStyle ?? const TuiStyle(bold: true),
        ),
        TuiText(hintText, style: theme.dim ?? const TuiStyle(fg: 245)),
      ],
      widths: [titleText.length, -1],
    );

    final tabsComponent = TuiTabsView(tabs, focused: focusLevel == 0);

    // Paint header components to surface
    headerComponent.paintSurface(
      context.surface,
      TuiRect(x: 0, y: 0, width: w, height: 1),
    );

    tabsComponent.paintSurface(
      context.surface,
      TuiRect(x: 0, y: 1, width: w, height: 1),
    );

    // Clear the entire bottom area before drawing panels (prevents leftovers on tab switch)
    context.surface.clearRect(0, headerH, w, contentH);

    // Cache content height for scroll ops
    contentHCache = contentH;

    // Border style for focused content
    final rightBorderStyle =
        (focusLevel == 1 && (tabs.index != 0 || bottomPane == 1)) &&
            theme.focusBorderStyle != null
        ? theme.focusBorderStyle
        : theme.borderStyle;

    // Build content based on active tab
    TuiComponent contentChild;
    String contentTitle = ' Content ';

    if (tabs.index == 0) {
      // Example tab - show menu content
      final comp = menu.items[menu.selectedIndex];
      switch (comp) {
        case 'List':
          contentChild = TuiListView(
            TuiList(
              const ['Alpha', 'Beta', 'Gamma'],
              selectedStyle: theme.accent,
              unselectedStyle: theme.dim,
            ),
          );
          break;
        case 'Panel':
          contentChild = TuiText(
            'Panel demo inside a panel.\nBorders adapt to theme/style.',
          );
          break;
        case 'TextInput':
          contentChild = TuiColumn(
            children: [TuiText('Input:'), TuiTextInputView(input)],
            heights: const [1, -1],
          );
          break;
        case 'ProgressBar':
          contentChild = TuiColumn(
            children: [
              TuiText('Progress: ${(progressValue * 100).round()}%'),
              TuiProgressBarView(progress),
            ],
            heights: const [1, 1],
          );
          break;
        case 'Spinner':
          contentChild = TuiSpinnerView(spinner);
          break;
        case 'Tabs':
          contentChild = TuiTabsView(tabs, focused: (focusLevel == 0));
          break;
        case 'StatusBar':
          contentChild = TuiStatusBarView(
            style: const TuiStyle(bg: 240, fg: 16),
            left: 'Left',
            center: 'Center',
            right: 'Right',
          );
          break;
        case 'Checkbox':
          contentChild = TuiCheckboxView(checkbox);
          break;
        case 'Button':
          contentChild = TuiButtonView(button);
          break;
        case 'Table':
          final table = TuiTable(
            headers: const ['Col A', 'Col B', 'Col C'],
            rows: const [
              ['A1', 'B1', 'C1'],
              ['A2', 'B2', 'C2'],
              ['A3', 'B3', 'C3'],
            ],
            columnWidths: const [10, 10, 10],
          );
          contentChild = TuiTableView(table);
          break;
        case 'ScrollView':
          contentChild = TuiScrollViewView(scroll);
          break;
        default:
          contentChild = TuiText('');
      }
    } else if (tabs.index == 1) {
      // README tab
      contentChild = TuiScrollViewView(scroll);
      contentTitle = ' README ';
    } else {
      // Keys tab
      contentChild = TuiText(
        'Key bindings (Vim style):\n'
        ' h/l: tabs left/right when tabs focused\n'
        ' j/k: focus Tabs ↔ Panels (Example) or Tabs ↔ Content (others)\n'
        ' j/k: scroll down/up in README/ScrollView when content focused\n'
        ' gg / G: top / bottom\n'
        ' t or d: toggle theme (dark/light); g: toggle content background\n'
        ' w: toggle wrap in README/ScrollView\n'
        ' Ctrl+C: quit',
      );
      contentTitle = ' Key Bindings ';
    }

    // Apply optional content background
    if (contentBg) {
      final bg = TuiStyle(bg: isLightTheme ? 254 : 236);
      contentChild = TuiBackground(style: bg, child: contentChild);
    }

    // Render panels - use side-by-side component if sidebar is shown, otherwise single panel
    if (showSidebar) {
      final leftBorderStyle =
          (focusLevel == 1 && tabs.index == 0 && bottomPane == 0) &&
              theme.focusBorderStyle != null
          ? theme.focusBorderStyle
          : theme.borderStyle;

      TuiSideBySidePanels(
        leftTitle: ' Menu ',
        rightTitle: contentTitle,
        leftChild: TuiListView(menu),
        rightChild: contentChild,
        leftWidth: sideW,
        theme: theme,
        titleStyle: theme.titleStyle,
        leftBorderStyle: leftBorderStyle,
        rightBorderStyle: rightBorderStyle,
      ).paintSurface(
        context.surface,
        TuiRect(x: 0, y: headerH, width: w, height: contentH),
      );
    } else {
      TuiPanelBox(
        title: contentTitle,
        titleStyle: theme.titleStyle,
        borderStyle: rightBorderStyle,
        child: contentChild,
      ).paintSurface(
        context.surface,
        TuiRect(x: 0, y: headerH, width: w, height: contentH),
      );
    }

    // Status bar
    final left = 'Size: ${w}x$h';
    final center = 'Arrows move | Enter toggles help | Ctrl+C quits';
    final right =
        'Tui ${DateTime.now().toLocal().toIso8601String().substring(11, 19)}';

    final statusBarComponent = TuiStatusBarView(
      style: const TuiStyle(bg: 240, fg: 16),
      left: left,
      center: center,
      right: right,
    );

    statusBarComponent.paintSurface(
      context.surface,
      TuiRect(x: 0, y: h - 1, width: w, height: 1),
    );
  }
}

void main() async {
  final runner = TuiRunner(DemoApp());
  try {
    await runner.run();
  } catch (_) {}
}
