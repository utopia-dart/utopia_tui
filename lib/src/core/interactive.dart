import 'component.dart';
import 'events.dart';

/// Base class for components that can handle input events
abstract class TuiInteractiveComponent extends TuiComponent {
  bool focused = false;

  /// Handle input event. Return true if event was consumed, false to pass through
  bool handleInput(TuiEvent event) => false;

  /// Get focus hint text for display
  String get focusHint => '';
}
