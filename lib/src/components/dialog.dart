/// A comprehensive dialog system for TUI applications.
///
/// Provides various types of dialogs including alerts, confirmations,
/// input dialogs, and custom content dialogs. All dialogs support
/// theming, keyboard navigation, and focus management.
///
/// ## Usage
///
/// ```dart
/// // Alert dialog
/// final alertDialog = TuiDialog.alert(
///   title: 'Error',
///   message: 'Something went wrong!',
/// );
///
/// // Confirmation dialog
/// final confirmDialog = TuiDialog.confirm(
///   title: 'Confirm Action',
///   message: 'Are you sure?',
///   confirmText: 'Yes',
///   cancelText: 'No',
/// );
///
/// // Input dialog
/// final inputDialog = TuiDialog.input(
///   title: 'Enter Name',
///   message: 'Please enter your name:',
///   placeholder: 'Your name...',
/// );
/// ```
library;

import '../core/component.dart';
import '../core/canvas.dart';
import '../core/rect.dart';
import '../core/style.dart';
import '../core/theme.dart';
import 'composition.dart';
import 'button.dart';
import 'text_input.dart';
import 'text_input_view.dart';

/// Result returned when a dialog is dismissed.
enum TuiDialogResult {
  /// Dialog was cancelled (ESC or Cancel button)
  cancelled,

  /// Dialog was confirmed (Enter or OK/Yes button)
  confirmed,

  /// Dialog was dismissed by clicking outside (if enabled)
  dismissed,
}

/// Data returned from an input dialog.
class TuiInputDialogResult {
  /// The result type (confirmed, cancelled, etc.)
  final TuiDialogResult result;

  /// The text entered by the user (only valid if result is confirmed)
  final String text;

  const TuiInputDialogResult(this.result, this.text);
}

/// Base dialog class that provides common dialog functionality.
abstract class TuiDialog extends TuiComponent {
  /// Dialog title
  final String title;

  /// Optional dialog message/content
  final String? message;

  /// Dialog width (0 = auto-size)
  final int width;

  /// Dialog height (0 = auto-size)
  final int height;

  /// Whether the dialog can be dismissed by clicking outside
  final bool dismissOnOutsideClick;

  /// Theme for styling the dialog
  final TuiTheme theme;

  /// Current focused element (for interactive dialogs)
  String? focusedElement;

  TuiDialog({
    required this.title,
    this.message,
    this.width = 0,
    this.height = 0,
    this.dismissOnOutsideClick = true,
    this.theme = const TuiTheme(),
    this.focusedElement,
  });

  /// Creates an alert dialog with a single OK button.
  factory TuiDialog.alert({
    required String title,
    required String message,
    String okText,
    int width,
    int height,
    TuiTheme theme,
  }) = TuiAlertDialog;

  /// Creates a confirmation dialog with Yes/No or OK/Cancel buttons.
  factory TuiDialog.confirm({
    required String title,
    required String message,
    String confirmText,
    String cancelText,
    int width,
    int height,
    TuiTheme theme,
  }) = TuiConfirmDialog;

  /// Creates an input dialog with a text input field.
  factory TuiDialog.input({
    required String title,
    String? message,
    String placeholder,
    String defaultValue,
    String confirmText,
    String cancelText,
    int width,
    int height,
    TuiTheme theme,
  }) = TuiInputDialog;

  /// Creates a custom dialog with user-provided content.
  factory TuiDialog.custom({
    required String title,
    required TuiComponent content,
    int width,
    int height,
    bool dismissOnOutsideClick,
    TuiTheme theme,
  }) = TuiCustomDialog;

  /// Calculates the actual dialog size based on content and constraints.
  TuiRect calculateDialogRect(int screenWidth, int screenHeight) {
    int dialogWidth = width > 0 ? width : _calculateAutoWidth();
    int dialogHeight = height > 0 ? height : _calculateAutoHeight();

    // Ensure dialog fits on screen with some padding
    dialogWidth = dialogWidth.clamp(20, screenWidth - 4);
    dialogHeight = dialogHeight.clamp(8, screenHeight - 4);

    // Center the dialog
    final x = (screenWidth - dialogWidth) ~/ 2;
    final y = (screenHeight - dialogHeight) ~/ 2;

    return TuiRect(x: x, y: y, width: dialogWidth, height: dialogHeight);
  }

  /// Calculate automatic width based on content
  int _calculateAutoWidth() {
    int maxWidth = title.length + 4; // Title + padding
    if (message != null) {
      final lines = message!.split('\n');
      for (final line in lines) {
        maxWidth = maxWidth.clamp(line.length + 4, 80);
      }
    }
    return maxWidth.clamp(30, 80);
  }

  /// Calculate automatic height based on content
  int _calculateAutoHeight() {
    int lines = 3; // Border + title + border
    if (message != null) {
      lines += message!.split('\n').length + 1; // Message + padding
    }
    lines += 3; // Buttons + padding
    return lines.clamp(8, 25);
  }

  /// Renders the dialog backdrop (dimmed background)
  void paintBackdrop(TuiSurface surface, TuiRect screenRect) {
    final backdropStyle = TuiStyle(bg: 0, fg: 8); // Dark backdrop
    for (int y = screenRect.y; y < screenRect.bottom; y++) {
      for (int x = screenRect.x; x < screenRect.right; x++) {
        surface.putText(x, y, ' ', style: backdropStyle);
      }
    }
  }

  /// Builds the dialog content component
  TuiComponent buildDialogContent();
}

/// Alert dialog with a single OK button.
class TuiAlertDialog extends TuiDialog {
  final String okText;

  TuiAlertDialog({
    required super.title,
    required String super.message,
    this.okText = 'OK',
    super.width = 0,
    super.height = 0,
    super.theme = const TuiTheme(),
  });

  @override
  TuiComponent buildDialogContent() {
    final button = TuiButton(
      okText,
      focused: focusedElement == 'ok',
      normalStyle: theme.dim ?? const TuiStyle(),
      focusedStyle: theme.accent ?? const TuiStyle(bold: true),
    );

    return TuiColumn(
      children: [
        if (message != null) ...[
          TuiText(message!),
          TuiText(''), // Spacer
        ],
        TuiRow(
          children: [TuiText(''), TuiButtonView(button)],
          widths: const [-1, 10],
        ),
      ],
      heights: message != null ? const [-1, 1, 3] : const [3],
    );
  }

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    final content = buildDialogContent();

    TuiPanelBox(
      title: ' $title ',
      titleStyle: theme.titleStyle,
      borderStyle: theme.borderStyle,
      child: content,
    ).paintSurface(surface, rect);
  }
}

/// Confirmation dialog with Yes/No buttons.
class TuiConfirmDialog extends TuiDialog {
  final String confirmText;
  final String cancelText;

  TuiConfirmDialog({
    required super.title,
    required String super.message,
    this.confirmText = 'Yes',
    this.cancelText = 'No',
    super.width = 0,
    super.height = 0,
    super.theme = const TuiTheme(),
  });

  @override
  TuiComponent buildDialogContent() {
    final confirmButton = TuiButton(
      confirmText,
      focused: focusedElement == 'confirm',
      normalStyle: theme.dim ?? const TuiStyle(),
      focusedStyle: theme.accent ?? const TuiStyle(bold: true),
    );

    final cancelButton = TuiButton(
      cancelText,
      focused: focusedElement == 'cancel',
      normalStyle: theme.dim ?? const TuiStyle(),
      focusedStyle: theme.accent ?? const TuiStyle(bold: true),
    );

    return TuiColumn(
      children: [
        if (message != null) ...[
          TuiText(message!),
          TuiText(''), // Spacer
        ],
        TuiRow(
          children: [
            TuiText(''),
            TuiButtonView(cancelButton),
            TuiText(' '),
            TuiButtonView(confirmButton),
          ],
          widths: const [-1, 10, 1, 10],
        ),
      ],
      heights: message != null ? const [-1, 1, 3] : const [3],
    );
  }

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    final content = buildDialogContent();

    TuiPanelBox(
      title: ' $title ',
      titleStyle: theme.titleStyle,
      borderStyle: theme.borderStyle,
      child: content,
    ).paintSurface(surface, rect);
  }
}

/// Input dialog with a text input field.
class TuiInputDialog extends TuiDialog {
  final String placeholder;
  final String defaultValue;
  final String confirmText;
  final String cancelText;
  final TuiTextInput textInput;

  TuiInputDialog({
    required super.title,
    super.message,
    this.placeholder = '',
    this.defaultValue = '',
    this.confirmText = 'OK',
    this.cancelText = 'Cancel',
    super.width = 0,
    super.height = 0,
    super.theme = const TuiTheme(),
  }) : textInput = TuiTextInput(
         text: defaultValue,
         cursorStyle: theme.accent ?? const TuiStyle(bold: true),
       );

  @override
  TuiComponent buildDialogContent() {
    final confirmButton = TuiButton(
      confirmText,
      focused: focusedElement == 'confirm',
      normalStyle: theme.dim ?? const TuiStyle(),
      focusedStyle: theme.accent ?? const TuiStyle(bold: true),
    );

    final cancelButton = TuiButton(
      cancelText,
      focused: focusedElement == 'cancel',
      normalStyle: theme.dim ?? const TuiStyle(),
      focusedStyle: theme.accent ?? const TuiStyle(bold: true),
    );

    return TuiColumn(
      children: [
        if (message != null) ...[
          TuiText(message!),
          TuiText(''), // Spacer
        ],
        TuiTextInputView(textInput),
        TuiText(''), // Spacer
        TuiRow(
          children: [
            TuiText(''),
            TuiButtonView(cancelButton),
            TuiText(' '),
            TuiButtonView(confirmButton),
          ],
          widths: const [-1, 10, 1, 10],
        ),
      ],
      heights: message != null ? const [-1, 1, 1, 1, 3] : const [1, 1, 3],
    );
  }

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    final content = buildDialogContent();

    TuiPanelBox(
      title: ' $title ',
      titleStyle: theme.titleStyle,
      borderStyle: theme.borderStyle,
      child: content,
    ).paintSurface(surface, rect);
  }
}

/// Custom dialog with user-provided content.
class TuiCustomDialog extends TuiDialog {
  final TuiComponent content;

  TuiCustomDialog({
    required super.title,
    required this.content,
    super.width = 0,
    super.height = 0,
    super.dismissOnOutsideClick = true,
    super.theme = const TuiTheme(),
  });

  @override
  TuiComponent buildDialogContent() => content;

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    TuiPanelBox(
      title: ' $title ',
      titleStyle: theme.titleStyle,
      borderStyle: theme.borderStyle,
      child: content,
    ).paintSurface(surface, rect);
  }
}
