/// A comprehensive, high-performance Terminal User Interface (TUI) library for Dart.
///
/// This library provides a complete framework for building beautiful console applications
/// with rich components, flexible layouts, theming support, and event handling.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:utopia_tui/utopia_tui.dart';
///
/// class MyApp extends TuiApp {
///   @override
///   void build(TuiContext context) {
///     TuiPanelBox(
///       title: ' Hello TUI! ',
///       child: TuiText('Welcome to Utopia TUI!'),
///     ).paint(context, row: 2, col: 2, width: 30, height: 10);
///   }
/// }
///
/// void main() async {
///   final runner = TuiRunner(MyApp());
///   await runner.run();
/// }
/// ```
library;

// Core TUI framework
export 'src/core/events.dart';
export 'src/core/app.dart';
export 'src/core/runner.dart';
export 'src/core/context.dart';
export 'src/core/terminal.dart';
export 'src/core/component.dart';
export 'src/core/interactive.dart';
export 'src/core/theme.dart';
export 'src/core/style.dart';
export 'src/core/layout.dart';
export 'src/core/bindings.dart';
export 'src/core/canvas.dart';
export 'src/core/rect.dart';

// Components
export 'src/components/list_menu.dart';
export 'src/components/list_view.dart';
export 'src/components/text_input.dart';
export 'src/components/text_input_view.dart';
export 'src/components/progress_bar.dart';
export 'src/components/spinner.dart';
export 'src/components/tabs.dart';
export 'src/components/status_bar.dart';
export 'src/components/checkbox.dart';
export 'src/components/button.dart';
export 'src/components/table.dart';
export 'src/components/scroll_view.dart';
export 'src/components/scroll_view_view.dart';
export 'src/components/interactive_scroll_view.dart';
export 'src/components/interactive_text_input.dart';
export 'src/components/interactive_menu.dart';
export 'src/components/composition.dart';
