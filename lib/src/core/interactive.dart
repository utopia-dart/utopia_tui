import 'component.dart';
import 'events.dart';

/// Base class for components that can handle input events and maintain focus.
///
/// Interactive components can:
/// - Receive and handle input events
/// - Maintain focus state
/// - Provide focus hints for users
/// - Update their internal state in response to input
abstract class TuiInteractiveComponent extends TuiComponent {
  bool focused = false;

  /// Handle input event. Return true if event was consumed, false to pass through.
  ///
  /// When focused, this method will be called for input events before they
  /// are passed to other components. Return true to consume the event and
  /// prevent it from being handled by other components.
  bool handleInput(TuiEvent event) => false;

  /// Get focus hint text for display to help users understand available actions.
  /// This is typically shown in a status bar or help area.
  String get focusHint => '';

  /// Called when the component gains focus
  void onFocus() {}

  /// Called when the component loses focus
  void onBlur() {}

  /// Set focus state and call appropriate lifecycle methods
  void setFocus(bool newFocus) {
    if (focused != newFocus) {
      final oldFocus = focused;
      focused = newFocus;
      if (focused && !oldFocus) {
        onFocus();
      } else if (!focused && oldFocus) {
        onBlur();
      }
      markNeedsRebuild();
    }
  }
}
