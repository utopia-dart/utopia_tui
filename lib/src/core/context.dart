import 'terminal.dart';
import 'canvas.dart';
import 'rect.dart';
import '../components/dialog.dart';
import '../components/interactive_dialog.dart';

/// Build context that provides access to terminal state and rendering surface.
///
/// The [TuiContext] is passed to applications during the build phase and
/// provides access to:
/// - Terminal dimensions ([width], [height])
/// - Main rendering surface ([surface])
/// - Utility methods for clearing and capturing output
///
/// ## Usage
///
/// ```dart
/// void build(TuiContext context) {
///   context.surface.putText(0, 0, 'Hello World');
///   // or use the rect property
///   final fullScreen = context.rect;
/// }
/// ```
class TuiContext {
  /// The underlying terminal interface.
  final TuiTerminalInterface terminal;

  /// Width of the terminal in characters.
  late final int width;

  /// Height of the terminal in characters.
  late final int height;

  late final TuiSurface _surface;

  /// Active dialog instance (if any).
  TuiInteractiveDialog? _activeDialog;

  /// Creates a new context for the given [terminal].
  ///
  /// The context will query the terminal for its current dimensions
  /// and create an appropriately sized rendering surface.
  TuiContext(this.terminal) {
    width = terminal.width;
    height = terminal.height;
    _surface = TuiSurface(width: width, height: height);
  }

  /// The main rendering surface for painting UI elements.
  ///
  /// Use this surface to draw text, apply styles, and render components.
  /// The surface automatically handles ANSI escape sequences and styling.
  TuiSurface get surface => _surface;

  /// A rectangle representing the full terminal screen.
  ///
  /// Equivalent to `TuiRect(x: 0, y: 0, width: width, height: height)`.
  /// Useful for components that need to fill the entire screen.
  TuiRect get rect => TuiRect(x: 0, y: 0, width: width, height: height);

  /// Clears the entire surface to empty cells.
  ///
  /// This resets all characters to spaces and removes all styling.
  void clear() {
    _surface.clear();
  }

  /// Captures the current surface content as ANSI-formatted strings.
  ///
  /// Returns a list of strings, one per terminal row, with ANSI escape
  /// sequences for styling and colors.
  /// Captures the current surface content as ANSI-formatted strings.
  ///
  /// Returns a list of strings, one per terminal row, with ANSI escape
  /// sequences for styling and colors.
  List<String> snapshot() {
    return _surface.toAnsiLines();
  }

  /// Captures the current surface content as styled strings.
  ///
  /// This is an alias for [snapshot] since the surface already includes
  /// styling information in its ANSI output.
  List<String> snapshotStyled() {
    return _surface.toAnsiLines();
  }

  // Dialog Management
  // =================

  /// Returns true if a dialog is currently active.
  bool get hasActiveDialog => _activeDialog != null;

  /// Returns the active dialog instance, or null if no dialog is active.
  TuiInteractiveDialog? get activeDialog => _activeDialog;

  /// Shows a dialog.
  ///
  /// Example:
  /// ```dart
  /// // Alert dialog
  /// context.showDialog(TuiDialog.alert(
  ///   title: 'Error',
  ///   message: 'Something went wrong!',
  ///   theme: TuiTheme.dark,
  /// ));
  ///
  /// // Confirm dialog
  /// context.showDialog(TuiDialog.confirm(
  ///   title: 'Confirm Action',
  ///   message: 'Are you sure?',
  ///   confirmText: 'Yes',
  ///   cancelText: 'No',
  ///   theme: TuiTheme.dark,
  /// ));
  ///
  /// // Input dialog
  /// context.showDialog(TuiDialog.input(
  ///   title: 'Enter Name',
  ///   message: 'Please enter your name:',
  ///   defaultValue: 'John Doe',
  ///   theme: TuiTheme.dark,
  /// ));
  ///
  /// // Custom dialog
  /// context.showDialog(TuiDialog.custom(
  ///   title: 'Custom Dialog',
  ///   content: TuiText('Custom content here'),
  ///   width: 50,
  ///   height: 20,
  ///   theme: TuiTheme.dark,
  /// ));
  /// ```
  void showDialog(TuiDialog dialog) {
    _activeDialog = TuiInteractiveDialog(dialog);
    _activeDialog!.focused = true;
  }

  /// Dismisses the currently active dialog.
  void dismissDialog() {
    _activeDialog?.focused = false;
    _activeDialog = null;
  }

  /// Returns the result of the active dialog, or null if no result yet.
  ///
  /// The result will be null while the dialog is still active.
  /// Check this in your event handling to see when the user has responded.
  TuiDialogResult? get dialogResult => _activeDialog?.result;

  /// For input dialogs, returns the entered text.
  String get dialogInputText => _activeDialog?.inputText ?? '';

  /// Handles dialog input events. Returns true if the event was consumed.
  ///
  /// Call this from your app's onEvent method to handle dialog input:
  /// ```dart
  /// void onEvent(TuiEvent event, TuiContext context) {
  ///   if (context.handleDialogInput(event)) {
  ///     return; // Event was consumed by dialog
  ///   }
  ///   // Handle other events...
  /// }
  /// ```
  bool handleDialogInput(dynamic event) {
    if (_activeDialog?.focused == true) {
      return _activeDialog!.handleInput(event);
    }
    return false;
  }

  /// Renders the active dialog overlay if one exists.
  ///
  /// This method is called automatically by the framework after your build()
  /// method completes, so you don't need to call it manually.
  ///
  /// **Internal API**: This method is intended for internal framework use only.
  /// Do not call this method directly in your application code.
  void renderDialogOverlay() {
    if (_activeDialog != null) {
      _activeDialog!.paintSurface(_surface, rect);
    }
  }
}
