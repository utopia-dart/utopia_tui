import 'events.dart';
import 'context.dart';

/// Base application class for TUI applications.
///
/// This abstract class provides the foundation for building terminal user interface
/// applications using a simple state management pattern inspired by the Bubble Tea
/// framework from Go.
///
/// ## Usage
///
/// ```dart
/// class MyApp extends TuiApp {
///   @override
///   void build(TuiContext context) {
///     // Build your UI here
///   }
/// }
/// ```
abstract class TuiApp {
  /// Called once during application startup to initialize internal state.
  ///
  /// This method is invoked before the first [build] call and can be used
  /// to set up initial state, load configuration, or perform other setup tasks.
  ///
  /// [context] provides access to terminal dimensions and rendering capabilities.
  void init(TuiContext context) {}

  /// Handle incoming events to update internal application state.
  ///
  /// This method is called whenever an event occurs, such as:
  /// - Keyboard input ([TuiKeyEvent])
  /// - Terminal resize ([TuiResizeEvent])
  /// - Timer ticks ([TuiTickEvent])
  ///
  /// Use this method to update your application state based on user input
  /// or other events.
  ///
  /// [event] is the event that occurred
  /// [context] provides access to current terminal state
  void onEvent(TuiEvent event, TuiContext context) {}

  /// Build and render the current UI into the provided context.
  ///
  /// This method is called whenever the UI needs to be redrawn, which happens:
  /// - After initialization
  /// - After handling events
  /// - On timer ticks (if [tickInterval] is set)
  ///
  /// Use [context] to render components and manage the display buffer.
  void build(TuiContext context);

  /// Optional timer interval for periodic updates.
  ///
  /// If this returns a non-null [Duration], the application will generate
  /// [TuiTickEvent]s at the specified interval. This is useful for animations,
  /// progress updates, or other time-based UI changes.
  ///
  /// Return `null` to disable automatic ticking.
  Duration? get tickInterval => null;
}
