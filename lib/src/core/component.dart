import 'context.dart';
import 'events.dart';
import 'canvas.dart';
import 'rect.dart';

/// Base component contract. All UI components extend this class.
///
/// Components are responsible for rendering themselves into a rectangular area
/// on a TuiSurface. They follow a simple paint-based rendering model.
abstract class TuiComponent {
  /// Paint this component into the given rect on the surface.
  ///
  /// Components should:
  /// 1. Clear their area if needed: surface.clearRect(rect.x, rect.y, rect.width, rect.height)
  /// 2. Render their content within the bounds of [rect]
  /// 3. Not draw outside the provided rectangle
  void paintSurface(TuiSurface surface, TuiRect rect);

  /// Called when an event occurs. Override to handle global events.
  /// Most components should use TuiInteractiveComponent for input handling instead.
  void onEvent(TuiEvent event, TuiContext context) {}

  /// Called when the component needs to update/rebuild.
  /// Override this for components that need to respond to state changes.
  void markNeedsRebuild() {}
}

/// Base class for components that render text content.
///
/// This provides a convenient pattern for components that need to build
/// lines of text and render them. Useful for creating custom text-based
/// components without dealing with low-level surface operations.
abstract class TuiTextComponent extends TuiComponent {
  /// Build the lines of text to display given the available space.
  ///
  /// Return a list of strings, one per line. The implementation should
  /// respect the width and height constraints and not return more lines
  /// than will fit in the available height.
  List<String> buildLines(int width, int height);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    // Clear the area first
    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final lines = buildLines(rect.width, rect.height);
    for (var i = 0; i < rect.height && i < lines.length; i++) {
      surface.putTextClip(rect.x, rect.y + i, lines[i], rect.width);
    }
  }
}
