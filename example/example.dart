import 'dart:io';
import 'package:utopia_tui/utopia_tui.dart';

// =============================================================================
// APPLICATION-SPECIFIC COMPONENTS - Built using library components
// =============================================================================

/// Simple header component with title and focus hint
class HeaderComponent extends TuiComponent {
  final String title;
  final String hint;
  final TuiTheme theme;

  HeaderComponent({
    required this.title,
    required this.hint,
    required this.theme,
  });

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    TuiRow(
      children: [
        TuiText(title, style: theme.titleStyle ?? const TuiStyle(bold: true)),
        TuiText(hint, style: theme.dim ?? const TuiStyle(fg: 245)),
      ],
      widths: [title.length, -1],
    ).paintSurface(surface, rect);
  }
}

/// Navigation tabs component with focus state
class NavigationTabs extends TuiComponent {
  final TuiTabs tabs;
  final bool focused;

  NavigationTabs({required this.tabs, required this.focused});

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    TuiTabsView(tabs, focused: focused).paintSurface(surface, rect);
  }
}

/// Menu sidebar component with interactive menu
class MenuSidebar extends TuiComponent {
  final TuiInteractiveMenu interactiveMenu;
  final String title;
  final TuiTheme theme;

  MenuSidebar({
    required this.interactiveMenu,
    required this.title,
    required this.theme,
  });

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    final borderStyle =
        interactiveMenu.focused && theme.focusBorderStyle != null
        ? theme.focusBorderStyle
        : theme.borderStyle;

    TuiPanelBox(
      title: title,
      titleStyle: theme.titleStyle,
      borderStyle: borderStyle,
      child: interactiveMenu,
    ).paintSurface(surface, rect);
  }
}

/// Dynamic content area that shows different components based on selection
class ContentArea extends TuiComponent {
  final String selectedComponent;
  final TuiTheme theme;
  final TuiInteractiveComponent? activeInteractiveComponent;
  final Map<String, dynamic> componentData;

  ContentArea({
    required this.selectedComponent,
    required this.theme,
    required this.activeInteractiveComponent,
    required this.componentData,
  });

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    final borderStyle =
        (activeInteractiveComponent?.focused ?? false) &&
            theme.focusBorderStyle != null
        ? theme.focusBorderStyle
        : theme.borderStyle;

    TuiComponent contentChild = _buildContent();

    TuiPanelBox(
      title: ' $selectedComponent Demo ',
      titleStyle: theme.titleStyle,
      borderStyle: borderStyle,
      child: contentChild,
    ).paintSurface(surface, rect);
  }

  TuiComponent _buildContent() {
    switch (selectedComponent) {
      case 'List':
        return TuiListView(
          TuiList(
            const ['Alpha', 'Beta', 'Gamma'],
            selectedStyle: theme.accent,
            unselectedStyle: theme.dim,
          ),
        );
      case 'Panel':
        return TuiText(
          'Panel demo inside a panel.\nBorders adapt to theme/style.',
        );
      case 'TextInput':
        final interactiveInput =
            componentData['interactiveInput'] as TuiInteractiveTextInput?;
        return TuiColumn(
          children: [
            TuiText('Input:'),
            interactiveInput ?? TuiText('Input component not available'),
          ],
          heights: const [1, -1],
        );
      case 'ProgressBar':
        final progress = componentData['progress'] as double;
        return TuiColumn(
          children: [
            TuiText('Progress: ${(progress * 100).round()}%'),
            TuiProgressBarView(componentData['progressBar']),
          ],
          heights: const [1, 1],
        );
      case 'Spinner':
        return TuiSpinnerView(componentData['spinner']);
      case 'Checkbox':
        return TuiCheckboxView(componentData['checkbox']);
      case 'Button':
        return TuiButtonView(componentData['button']);
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
        return TuiTableView(table);
      case 'ScrollView':
        final interactiveScroll =
            componentData['interactiveScroll'] as TuiInteractiveScrollView?;
        return interactiveScroll ??
            TuiText('ScrollView component not available');
      default:
        return TuiText('Select a component from the menu');
    }
  }
}

/// Full-screen content for non-example tabs
class FullScreenContent extends TuiComponent {
  final String title;
  final TuiComponent content;
  final TuiTheme theme;
  final bool focused;

  FullScreenContent({
    required this.title,
    required this.content,
    required this.theme,
    required this.focused,
  });

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    final borderStyle = focused && theme.focusBorderStyle != null
        ? theme.focusBorderStyle
        : theme.borderStyle;

    TuiPanelBox(
      title: title,
      titleStyle: theme.titleStyle,
      borderStyle: borderStyle,
      child: content,
    ).paintSurface(surface, rect);
  }
}

/// Status bar component
class StatusBar extends TuiComponent {
  final int width;
  final int height;

  StatusBar({required this.width, required this.height});

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    final left = 'Size: ${width}x$height';
    final center = 'Arrows move | Enter toggles help | Ctrl+C quits';
    final right =
        'Tui ${DateTime.now().toLocal().toIso8601String().substring(11, 19)}';

    TuiStatusBarView(
      style: const TuiStyle(bg: 240, fg: 16),
      left: left,
      center: center,
      right: right,
    ).paintSurface(surface, rect);
  }
}

/// Two-panel layout component for side-by-side display
class TwoPanelLayout extends TuiComponent {
  final TuiComponent leftPanel;
  final TuiComponent rightPanel;
  final int leftWidth;

  TwoPanelLayout({
    required this.leftPanel,
    required this.rightPanel,
    required this.leftWidth,
  });

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Left panel
    leftPanel.paintSurface(
      surface,
      TuiRect(x: rect.x, y: rect.y, width: leftWidth, height: rect.height),
    );

    // Right panel
    final rightX = rect.x + leftWidth;
    final rightWidth = rect.width - leftWidth;
    if (rightWidth > 0) {
      rightPanel.paintSurface(
        surface,
        TuiRect(x: rightX, y: rect.y, width: rightWidth, height: rect.height),
      );
    }
  }
}

/// Example of TuiTextComponent for building text-based content
class HelpTextComponent extends TuiTextComponent {
  final String title;
  final List<String> helpLines;

  HelpTextComponent({required this.title, required this.helpLines});

  @override
  List<String> buildLines(int width, int height) {
    final lines = <String>[];

    // Add title with underline
    lines.add(title);
    lines.add('=' * title.length);
    lines.add('');

    // Add help content, wrapping long lines if needed
    for (final helpLine in helpLines) {
      if (helpLine.isEmpty) {
        lines.add('');
      } else if (helpLine.length <= width) {
        lines.add(helpLine);
      } else {
        // Simple word wrapping
        final words = helpLine.split(' ');
        var currentLine = '';
        for (final word in words) {
          if (currentLine.isEmpty) {
            currentLine = word;
          } else if (currentLine.length + 1 + word.length <= width) {
            currentLine += ' $word';
          } else {
            lines.add(currentLine);
            currentLine = word;
          }
        }
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
        }
      }
    }

    // Return only what fits in the available height
    return lines.take(height).toList();
  }
}

// =============================================================================
// MAIN APPLICATION - Composed of reusable components
// =============================================================================

class DemoApp extends TuiApp {
  // Core components
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
    ],
    selectedStyle: const TuiStyle(bold: true, fg: 39),
    unselectedStyle: const TuiStyle(fg: 250),
  );

  // Interactive components
  late final TuiInteractiveMenu interactiveMenu;
  late final TuiInteractiveTextInput interactiveTextInput;
  late final TuiInteractiveScrollView interactiveScrollView;

  // Regular components
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
  int focusLevel = 0; // 0 = Tabs, 1 = Content
  int bottomPane = 0; // 0 = left (menu), 1 = right (content)

  // Focus management
  List<TuiInteractiveComponent> get currentFocusableComponents {
    if (tabs.index == 0) {
      // Example tab
      if (bottomPane == 0) {
        return [interactiveMenu];
      } else {
        final selectedComp = menu.items[menu.selectedIndex];
        switch (selectedComp) {
          case 'TextInput':
            return [interactiveTextInput];
          case 'ScrollView':
            return [interactiveScrollView];
          default:
            return [];
        }
      }
    } else if (tabs.index == 1) {
      // README tab
      return [interactiveScrollView];
    }
    return [];
  }

  DemoApp() {
    // Initialize interactive components
    interactiveMenu = TuiInteractiveMenu(menu);
    interactiveTextInput = TuiInteractiveTextInput(input);
    interactiveScrollView = TuiInteractiveScrollView(scroll);
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

      // Update interactive component focus and tick
      final focusableComponents = currentFocusableComponents;
      for (var comp in focusableComponents) {
        comp.focused = focusLevel == 1;
      }

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

    // First try to delegate input to focused interactive components
    if (focusLevel == 1) {
      final focusableComponents = currentFocusableComponents;
      for (var comp in focusableComponents) {
        if (comp.focused && comp.handleInput(event)) {
          return; // Event was consumed
        }
      }
    }

    // Handle global navigation if no component consumed the event
    if (event is TuiKeyEvent && event.isPrintable) {
      final ch = event.char!.toLowerCase();

      // Quick tab switching
      if (ch == '1') {
        tabs.index = 0;
        _updateFocus();
        return;
      }
      if (ch == '2') {
        tabs.index = 1;
        _updateFocus();
        return;
      }
      if (ch == '3') {
        tabs.index = 2;
        _updateFocus();
        return;
      }

      // Theme toggle
      if (ch == 't' || ch == 'd') {
        isLightTheme = !isLightTheme;
        _updateTheme();
        return;
      }

      // Focus navigation
      if (ch == 'j') {
        focusLevel = 1;
        _updateFocus();
        return;
      }
      if (ch == 'k') {
        focusLevel = 0;
        _updateFocus();
        return;
      }

      // Horizontal navigation
      if (focusLevel == 0) {
        if (ch == 'h' && tabs.index > 0) {
          tabs.index--;
          _updateFocus();
        }
        if (ch == 'l' && tabs.index < tabs.tabs.length - 1) {
          tabs.index++;
          _updateFocus();
        }
      }

      if (focusLevel == 1 && tabs.index == 0) {
        if (ch == 'h') {
          bottomPane = 0;
          _updateFocus();
        }
        if (ch == 'l') {
          bottomPane = 1;
          _updateFocus();
        }
      }
    }
  }

  void _updateFocus() {
    // Clear all component focus
    interactiveMenu.focused = false;
    interactiveTextInput.focused = false;
    interactiveScrollView.focused = false;

    // Set focus for current components
    if (focusLevel == 1) {
      final focusableComponents = currentFocusableComponents;
      for (var comp in focusableComponents) {
        comp.focused = true;
      }
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
  }

  @override
  void build(TuiContext context) {
    final w = context.width;
    final h = context.height;
    final theme = isLightTheme ? TuiTheme.light : TuiTheme.dark;

    // Layout dimensions
    final headerH = 2; // title + tabs
    final footerH = 1; // status bar
    final contentH = h - headerH - footerH;
    final bool showSidebar = tabs.index == 0;
    final sideW = showSidebar ? (w * 0.3).round().clamp(20, w - 20) : 0;

    // 1. Header component with dynamic focus hints
    final focusNames = ['Tabs', 'Content'];
    final titleText = ' Tui Demo - Ctrl+C to quit ';

    // Get focus hint from active interactive component
    String hintText =
        ' Focus: ${focusNames[focusLevel]} (j/k to switch, h/l sideways) ';
    if (focusLevel == 1) {
      final focusableComponents = currentFocusableComponents;
      if (focusableComponents.isNotEmpty) {
        final activeComp = focusableComponents.first;
        final compHint = activeComp.focusHint;
        if (compHint.isNotEmpty) {
          hintText = ' Focus: Content - $compHint ';
        }
      }
    }

    HeaderComponent(
      title: titleText,
      hint: hintText,
      theme: theme,
    ).paintSurface(context.surface, TuiRect(x: 0, y: 0, width: w, height: 1));

    // 2. Navigation tabs
    NavigationTabs(
      tabs: tabs,
      focused: focusLevel == 0,
    ).paintSurface(context.surface, TuiRect(x: 0, y: 1, width: w, height: 1));

    // Clear content area
    context.surface.clearRect(0, headerH, w, contentH);

    // 3. Main content area
    if (tabs.index == 0) {
      // Example tab with sidebar
      final leftPanel = MenuSidebar(
        interactiveMenu: interactiveMenu,
        title: ' Menu ',
        theme: theme,
      );

      // Determine active interactive component for right panel
      TuiInteractiveComponent? activeInteractiveComponent;
      final selectedComp = menu.items[menu.selectedIndex];
      switch (selectedComp) {
        case 'TextInput':
          activeInteractiveComponent = interactiveTextInput;
          break;
        case 'ScrollView':
          activeInteractiveComponent = interactiveScrollView;
          break;
      }

      final rightPanel = ContentArea(
        selectedComponent: selectedComp,
        theme: theme,
        activeInteractiveComponent: activeInteractiveComponent,
        componentData: {
          'input': input,
          'interactiveInput': interactiveTextInput,
          'progress': progressValue,
          'progressBar': progress,
          'spinner': spinner,
          'checkbox': checkbox,
          'button': button,
          'scroll': scroll,
          'interactiveScroll': interactiveScrollView,
        },
      );

      TwoPanelLayout(
        leftPanel: leftPanel,
        rightPanel: rightPanel,
        leftWidth: sideW,
      ).paintSurface(
        context.surface,
        TuiRect(x: 0, y: headerH, width: w, height: contentH),
      );
    } else {
      // Full-screen content for README and Keys tabs
      TuiComponent content;
      String title;

      if (tabs.index == 1) {
        content = interactiveScrollView;
        title = ' README ';
      } else {
        content = HelpTextComponent(
          title: 'Key Bindings',
          helpLines: [
            'Navigation:',
            ' h/l: tabs left/right when tabs focused',
            ' j/k: focus Tabs ↔ Content',
            ' 1/2/3: quick tab switching',
            '',
            'Component Interaction:',
            ' e: enter component mode (scroll/edit)',
            ' j/k: scroll up/down in scroll mode',
            ' arrow keys: also scroll in scroll mode',
            ' ESC: exit component mode',
            '',
            'Application:',
            ' t or d: toggle theme (dark/light)',
            ' Ctrl+C: quit',
            '',
            'This demonstrates the TuiTextComponent pattern',
            'for building text-based help content that',
            'automatically wraps and fits the available space.',
          ],
        );
        title = ' Key Bindings ';
      }

      FullScreenContent(
        title: title,
        content: content,
        theme: theme,
        focused: focusLevel == 1,
      ).paintSurface(
        context.surface,
        TuiRect(x: 0, y: headerH, width: w, height: contentH),
      );
    }

    // 4. Status bar
    StatusBar(width: w, height: h).paintSurface(
      context.surface,
      TuiRect(x: 0, y: h - 1, width: w, height: 1),
    );
  }
}

void main() async {
  await TuiRunner(DemoApp()).run();
}
