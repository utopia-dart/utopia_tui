import 'context.dart';
import 'events.dart';
import 'canvas.dart';
import 'rect.dart';

/// Base class for all UI components in the TUI framework.
///
/// Components are responsible for rendering themselves into a rectangular area
/// on a [TuiSurface]. They follow a simple paint-based rendering model where
/// each component implements [paintSurface] to draw its content.
///
/// ## Creating Custom Components
///
/// ```dart
/// class MyComponent extends TuiComponent {
///   @override
///   void paintSurface(TuiSurface surface, TuiRect rect) {
///     surface.clearRect(rect.x, rect.y, rect.width, rect.height);
///     surface.putText(rect.x, rect.y, 'Hello World');
///   }
/// }
/// ```
abstract class TuiComponent {
  /// Paints this component into the given [rect] on the [surface].
  ///
  /// Components should:
  /// 1. Clear their area if needed using [TuiSurface.clearRect]
  /// 2. Render their content within the bounds of [rect]
  /// 3. Never draw outside the provided rectangle
  ///
  /// The [rect] parameter defines both the position and size constraints
  /// for the component's rendering area.
  void paintSurface(TuiSurface surface, TuiRect rect);

  /// Called when a global event occurs.
  ///
  /// Most components should extend [TuiInteractiveComponent] for input
  /// handling instead of overriding this method directly.
  ///
  /// [event] is the event that occurred
  /// [context] provides access to the application state
  void onEvent(TuiEvent event, TuiContext context) {}

  /// Called when the component needs to update or rebuild.
  ///
  /// Override this method for components that need to respond to state
  /// changes or perform cleanup when their content becomes stale.
  void markNeedsRebuild() {}
}

/// Base class for components that render text content.
///
/// This provides a convenient pattern for components that need to build
/// lines of text and render them. It handles the low-level surface operations
/// and allows subclasses to focus on generating the text content.
///
/// ## Usage
///
/// ```dart
/// class MyTextComponent extends TuiTextComponent {
///   @override
///   List<String> buildLines(int width, int height) {
///     return ['Line 1', 'Line 2', 'Line 3'];
///   }
/// }
/// ```
abstract class TuiTextComponent extends TuiComponent {
  /// Builds the lines of text to display given the available space.
  ///
  /// Should return a list of strings, one per line. The implementation
  /// must respect the [width] and [height] constraints and should not
  /// return more lines than will fit in the available [height].
  ///
  /// [width] is the maximum characters per line
  /// [height] is the maximum number of lines
  List<String> buildLines(int width, int height);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final lines = buildLines(rect.width, rect.height);
    for (var i = 0; i < rect.height && i < lines.length; i++) {
      surface.putTextClip(rect.x, rect.y + i, lines[i], rect.width);
    }
  }
}
