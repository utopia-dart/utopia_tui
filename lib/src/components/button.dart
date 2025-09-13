import '../core/style.dart';
import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';

/// A button component with focus state and styling.
///
/// Represents a clickable button with a text label that can be styled
/// differently when focused vs unfocused. Provides text rendering with
/// width constraints and padding.
///
/// ## Usage
///
/// ```dart
/// final button = TuiButton(
///   'Click Me',
///   normalStyle: TuiStyle(fg: 15),
///   focusedStyle: TuiStyle(fg: 0, bg: 15, bold: true),
/// );
/// ```
class TuiButton {
  /// The text label displayed on the button.
  final String label;

  /// Whether the button currently has focus.
  bool focused;

  /// Style applied when the button is not focused.
  final TuiStyle? normalStyle;

  /// Style applied when the button has focus.
  final TuiStyle? focusedStyle;

  /// Creates a button with the given [label] and optional styling.
  ///
  /// [focused] determines the initial focus state (default false).
  /// [normalStyle] and [focusedStyle] define the appearance in different states.
  TuiButton(
    this.label, {
    this.focused = false,
    this.normalStyle,
    this.focusedStyle,
  });

  /// Renders the button as a string with the given [width].
  ///
  /// The button text is padded with spaces and styled based on the focus state.
  /// If the styled text is longer than [width], it will be truncated.
  /// If shorter, it will be right-padded to fill the width.
  String render(int width) {
    final base = ' $label ';
    final styled = focused
        ? (focusedStyle?.apply(base) ?? base)
        : (normalStyle?.apply(base) ?? base);
    return styled.length > width
        ? styled.substring(0, width)
        : styled.padRight(width);
  }
}

/// A surface-based view component for rendering [TuiButton].
///
/// This component handles the actual rendering of a [TuiButton] onto a
/// [TuiSurface] with proper positioning and styling. The button text
/// is automatically centered within the available space.
///
/// ## Usage
///
/// ```dart
/// final button = TuiButton('Save');
/// final buttonView = TuiButtonView(button);
/// buttonView.paintSurface(surface, rect);
/// ```
class TuiButtonView extends TuiComponent {
  /// The button model to render.
  final TuiButton button;

  /// Creates a button view for the given [button].
  TuiButtonView(this.button);

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    if (rect.isEmpty) return;

    surface.clearRect(rect.x, rect.y, rect.width, rect.height);

    final text = ' ${button.label} ';
    final style = button.focused
        ? (button.focusedStyle ?? const TuiStyle())
        : (button.normalStyle ?? const TuiStyle());

    final startX = text.length < rect.width
        ? rect.x + (rect.width - text.length) ~/ 2
        : rect.x;

    surface.putTextClip(startX, rect.y, text, rect.width, style: style);
  }
}
