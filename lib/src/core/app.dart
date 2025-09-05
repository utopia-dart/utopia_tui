import 'events.dart';
import 'context.dart';

// Minimal, Bubble Tea–inspired app interface

/// Minimal app interface with simple, object-contained state.
abstract class TuiApp {
  /// Called once to initialize internal state.
  void init(TuiContext context) {}

  /// Handle an incoming event to update internal state.
  void onEvent(TuiEvent event, TuiContext context) {}

  /// Draw the current UI into the provided context buffer.
  void build(TuiContext context);

  /// Optional tick interval; return null to disable ticking.
  Duration? get tickInterval => null;
}
