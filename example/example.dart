import 'dart:io';
import 'package:utopia_tui/utopia_tui.dart';

// =============================================================================
// MAIN APPLICATION
// =============================================================================

class DemoApp extends TuiApp {
  // Components
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
      'Checkbox',
      'Button',
      'Table',
      'ScrollView',
      'Dialog',
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

  // State
  double progressValue = 0;
  bool isLightTheme = false;

  // Focus management
  late TuiFocusManager focus;
  int _lastTabIndex = -1;
  int _lastMenuIndex = -1;

  DemoApp() {
    _buildFocusTree();
  }

  final _contentPlaceholder = TuiFocusPlaceholder();

  void _buildFocusTree() {
    if (tabs.index == 0) {
      // Example tab: tabs row → [menu | content]
      final selected = menu.items[menu.selectedIndex];
      TuiInteractiveComponent contentComponent;
      switch (selected) {
        case 'TextInput':
          contentComponent = input;
        case 'ScrollView':
          contentComponent = scroll;
        default:
          contentComponent = _contentPlaceholder;
      }

      focus = TuiFocusManager(
        root: TuiFocusNode.column(
          children: [
            TuiFocusNode.leaf(id: 'tabs', component: tabs),
            TuiFocusNode.row(
              id: 'panes',
              children: [
                TuiFocusNode.leaf(id: 'menu', component: menu),
                TuiFocusNode.leaf(id: 'content', component: contentComponent),
              ],
            ),
          ],
        ),
      );
    } else if (tabs.index == 1) {
      // README tab
      focus = TuiFocusManager(
        root: TuiFocusNode.column(
          children: [
            TuiFocusNode.leaf(id: 'tabs', component: tabs),
            TuiFocusNode.leaf(id: 'content', component: scroll),
          ],
        ),
      );
    } else {
      // Keys tab — no interactive content
      focus = TuiFocusManager(
        root: TuiFocusNode.leaf(id: 'tabs', component: tabs),
      );
    }
  }

  void _rebuildFocus() {
    if (_lastTabIndex == tabs.index && _lastMenuIndex == menu.selectedIndex) {
      return;
    }
    _lastTabIndex = tabs.index;
    _lastMenuIndex = menu.selectedIndex;
    final currentId = focus.focusedId;
    _buildFocusTree();
    if (currentId != null) focus.focusById(currentId);
  }

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
      input.tick(focused: input.focused && input.editMode);
      progressValue += 0.01;
      if (progressValue > 1) progressValue = 0;
      progress.value = progressValue;
      return;
    }

    // Dialog input takes priority
    if (context.hasActiveDialog) {
      if (context.handleDialogInput(event)) {
        _handleDialogResult(context);
        return;
      }
    }

    // Delegate to focused component
    if (focus.handleInput(event)) return;

    if (event is! TuiKeyEvent) return;

    // Escape: dismiss dialog or move focus up
    if (event.code == TuiKeyCode.escape) {
      if (context.hasActiveDialog) {
        context.dismissDialog();
        return;
      }
      focus.move(FocusDirection.up);
      return;
    }

    // Arrow / Tab navigation
    switch (event.code) {
      case TuiKeyCode.arrowUp:
        focus.move(FocusDirection.up);
        return;
      case TuiKeyCode.arrowDown:
        focus.move(FocusDirection.down);
        return;
      case TuiKeyCode.arrowLeft:
        focus.move(FocusDirection.left);
        return;
      case TuiKeyCode.arrowRight:
        focus.move(FocusDirection.right);
        return;
      case TuiKeyCode.tab:
        focus.focusNext();
        return;
      default:
        break;
    }

    // Printable key shortcuts
    if (!event.isPrintable) return;
    final ch = event.char!.toLowerCase();

    // Vim navigation
    if (ch == 'j') {
      focus.move(FocusDirection.down);
      return;
    }
    if (ch == 'k') {
      focus.move(FocusDirection.up);
      return;
    }
    if (ch == 'h') {
      focus.move(FocusDirection.left);
      return;
    }
    if (ch == 'l') {
      focus.move(FocusDirection.right);
      return;
    }

    // Quick tab switching
    if (ch == '1' || ch == '2' || ch == '3') {
      tabs.index = int.parse(ch) - 1;
      _rebuildFocus();
      return;
    }

    // Theme toggle
    if (ch == 't' || ch == 'd') {
      isLightTheme = !isLightTheme;
      _updateTheme();
      return;
    }

    // Dialog shortcuts
    if (ch == 'q' && context.hasActiveDialog) {
      context.dismissDialog();
      return;
    }
    if (tabs.index == 0 &&
        focus.focusedId == 'content' &&
        menu.items[menu.selectedIndex] == 'Dialog') {
      _handleDialogShortcut(ch, context);
    }
  }

  void _handleDialogShortcut(String ch, TuiContext context) {
    final theme = isLightTheme ? TuiTheme.light : TuiTheme.dark;
    switch (ch) {
      case 'a':
        context.showDialog(
          TuiDialog.alert(
            title: 'Alert Dialog',
            message:
                'This is an example alert dialog.\nPress Enter to dismiss.',
            theme: theme,
          ),
        );
      case 's':
        context.showDialog(
          TuiDialog.confirm(
            title: 'Confirm Action',
            message:
                'Are you sure you want to proceed?\nThis action cannot be undone.',
            confirmText: 'Yes',
            cancelText: 'No',
            theme: theme,
          ),
        );
      case 'f':
        context.showDialog(
          TuiDialog.input(
            title: 'Enter Your Name',
            message: 'Please enter your name below:',
            defaultValue: 'John Doe',
            confirmText: 'OK',
            cancelText: 'Cancel',
            theme: theme,
          ),
        );
      case 'g':
        context.showDialog(
          TuiDialog.custom(
            title: 'Keybindings Help',
            content: TuiColumn(
              children: [
                TuiText('Navigation:'),
                TuiText(' j/k or ↑↓ = Focus up/down'),
                TuiText(' h/l or ←→ = Focus left/right'),
                TuiText(' Tab = Cycle focus'),
                TuiText(' 1/2/3 = Switch tabs'),
                TuiText(''),
                TuiText('Actions:'),
                TuiText(' e = Enter/toggle edit/scroll mode'),
                TuiText(' Ctrl+E = Toggle edit/scroll mode'),
                TuiText(' t/d = Toggle theme'),
                TuiText(' Ctrl+C = Quit'),
              ],
              heights: const [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
            ),
            width: 45,
            height: 16,
            theme: theme,
          ),
        );
    }
  }

  void _handleDialogResult(TuiContext context) {
    if (context.dialogResult != null) {
      context.dismissDialog();
    }
  }

  void _updateTheme() {
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
    // Force rebuild since components were recreated
    _lastTabIndex = -1;
    _rebuildFocus();
  }

  @override
  void build(TuiContext context) {
    final w = context.width;
    final h = context.height;
    final theme = isLightTheme ? TuiTheme.light : TuiTheme.dark;

    final headerH = 2;
    final footerH = 1;
    final contentH = h - headerH - footerH;

    // Rebuild focus tree when menu selection changes (affects content pane)
    _rebuildFocus();

    // 1. Header
    final titleText = ' Tui Demo - Ctrl+C to quit ';
    final focusedComp = focus.focusedComponent;
    final hintText = focusedComp != null && focusedComp.focusHint.isNotEmpty
        ? ' ${focusedComp.focusHint} '
        : ' ↑↓←→ navigate | Tab cycle | e enter mode ';

    TuiRow(
      children: [
        TuiText(
          titleText,
          style: theme.titleStyle ?? const TuiStyle(bold: true),
        ),
        TuiText(hintText, style: theme.dim ?? const TuiStyle(fg: 245)),
      ],
      widths: [titleText.length, -1],
    ).paintSurface(context.surface, TuiRect(x: 0, y: 0, width: w, height: 1));

    // 2. Tabs
    tabs.focused = focus.focusedId == 'tabs';
    tabs.paintSurface(
      context.surface,
      TuiRect(x: 0, y: 1, width: w, height: 1),
    );

    // 3. Content
    context.surface.clearRect(0, headerH, w, contentH);

    if (tabs.index == 0) {
      _buildExampleTab(context, theme, w, headerH, contentH);
    } else if (tabs.index == 1) {
      _buildFullScreenTab(
        context,
        theme,
        ' README ',
        scroll,
        w,
        headerH,
        contentH,
      );
    } else {
      _buildKeysTab(context, theme, w, headerH, contentH);
    }

    // 4. Status bar
    TuiStatusBar(
      style: const TuiStyle(bg: 240, fg: 16),
      left: 'Size: ${w}x$h',
      center: '←→↑↓ navigate | Tab cycle | Ctrl+C quit',
      right:
          'Tui ${DateTime.now().toLocal().toIso8601String().substring(11, 19)}',
    ).paintSurface(
      context.surface,
      TuiRect(x: 0, y: h - 1, width: w, height: 1),
    );
  }

  void _buildExampleTab(
    TuiContext context,
    TuiTheme theme,
    int w,
    int y,
    int contentH,
  ) {
    final sideW = (w * 0.3).round().clamp(20, w - 20);
    final menuFocused = focus.focusedId == 'menu';
    final contentFocused = focus.focusedId == 'content';

    // Left: menu panel
    final menuBorder = menuFocused && theme.focusBorderStyle != null
        ? theme.focusBorderStyle
        : theme.borderStyle;
    TuiPanelBox(
      title: ' Menu ',
      titleStyle: theme.titleStyle,
      borderStyle: menuBorder,
      child: menu,
    ).paintSurface(
      context.surface,
      TuiRect(x: 0, y: y, width: sideW, height: contentH),
    );

    // Right: content panel
    final selected = menu.items[menu.selectedIndex];
    final contentBorder = contentFocused && theme.focusBorderStyle != null
        ? theme.focusBorderStyle
        : theme.borderStyle;
    TuiPanelBox(
      title: ' $selected Demo ',
      titleStyle: theme.titleStyle,
      borderStyle: contentBorder,
      child: _buildContentComponent(selected, theme),
    ).paintSurface(
      context.surface,
      TuiRect(x: sideW, y: y, width: w - sideW, height: contentH),
    );
  }

  TuiComponent _buildContentComponent(String selected, TuiTheme theme) {
    switch (selected) {
      case 'List':
        return TuiList(
          const ['Alpha', 'Beta', 'Gamma'],
          selectedStyle: theme.accent,
          unselectedStyle: theme.dim,
        );
      case 'Panel':
        return TuiText(
          'Panel demo inside a panel.\nBorders adapt to theme/style.',
        );
      case 'TextInput':
        return TuiColumn(
          children: [TuiText('Input:'), input],
          heights: const [1, -1],
        );
      case 'ProgressBar':
        return TuiColumn(
          children: [
            TuiText('Progress: ${(progressValue * 100).round()}%'),
            progress,
          ],
          heights: const [1, 1],
        );
      case 'Spinner':
        return spinner;
      case 'Checkbox':
        return checkbox;
      case 'Button':
        return button;
      case 'Table':
        return TuiTable(
          headers: const ['Col A', 'Col B', 'Col C'],
          rows: const [
            ['A1', 'B1', 'C1'],
            ['A2', 'B2', 'C2'],
            ['A3', 'B3', 'C3'],
          ],
          columnWidths: const [10, 10, 10],
        );
      case 'ScrollView':
        return scroll;
      case 'Dialog':
        return TuiColumn(
          children: [
            TuiText('Dialog System Demo'),
            TuiText(''),
            TuiText('Keyboard Controls:'),
            TuiText(' A = Alert Dialog'),
            TuiText(' S = Confirm Dialog'),
            TuiText(' F = Input Dialog'),
            TuiText(' G = Keybindings Dialog'),
            TuiText(''),
            TuiText('Press A/S/F/G to show dialogs!'),
          ],
          heights: const [1, 1, 1, 1, 1, 1, 1, 1, -1],
        );
      default:
        return TuiText('Select a component from the menu');
    }
  }

  void _buildFullScreenTab(
    TuiContext context,
    TuiTheme theme,
    String title,
    TuiComponent content,
    int w,
    int y,
    int contentH,
  ) {
    final isFocused = focus.focusedId == 'content';
    final border = isFocused && theme.focusBorderStyle != null
        ? theme.focusBorderStyle
        : theme.borderStyle;
    TuiPanelBox(
      title: title,
      titleStyle: theme.titleStyle,
      borderStyle: border,
      child: content,
    ).paintSurface(
      context.surface,
      TuiRect(x: 0, y: y, width: w, height: contentH),
    );
  }

  void _buildKeysTab(
    TuiContext context,
    TuiTheme theme,
    int w,
    int y,
    int contentH,
  ) {
    final border = theme.borderStyle;
    TuiPanelBox(
      title: ' Key Bindings ',
      titleStyle: theme.titleStyle,
      borderStyle: border,
      child: TuiText(
        'Navigation:\n'
        ' h/l or ←→: focus left/right\n'
        ' j/k or ↑↓: focus up/down\n'
        ' Tab: cycle focus\n'
        ' 1/2/3: quick tab switching\n'
        '\n'
        'Component Interaction:\n'
        ' e: enter/toggle edit/scroll mode\n'
        ' Ctrl+E: toggle edit/scroll mode\n'
        '\n'
        'Dialog System (on Dialog tab):\n'
        ' A/S/F/G: show Alert/Confirm/Input/Help\n'
        ' Y/N: quick yes/no\n'
        ' Tab: navigate dialog buttons\n'
        ' Enter: activate focused button\n'
        ' ESC/Q: cancel/dismiss\n'
        '\n'
        'Application:\n'
        ' t or d: toggle theme\n'
        ' Ctrl+C: quit',
        wrap: true,
      ),
    ).paintSurface(
      context.surface,
      TuiRect(x: 0, y: y, width: w, height: contentH),
    );
  }
}

void main() async {
  await TuiRunner(DemoApp()).run();
}
