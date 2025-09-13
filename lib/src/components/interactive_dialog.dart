/// Interactive dialog manager for handling dialog input and state.
///
/// Provides a high-level interface for displaying dialogs with keyboard
/// navigation, focus management, and result handling. Supports multiple
/// dialog types and customizable input handling.
///
/// ## Usage
///
/// ```dart
/// final manager = TuiDialogManager();
///
/// // Show an alert dialog
/// final result = await manager.showAlert(
///   title: 'Error',
///   message: 'Something went wrong!',
/// );
///
/// // Show an input dialog
/// final inputResult = await manager.showInput(
///   title: 'Enter Name',
///   message: 'Please enter your name:',
/// );
/// if (inputResult.result == TuiDialogResult.confirmed) {
///   print('User entered: ${inputResult.text}');
/// }
/// ```
library;

import '../core/interactive.dart';
import '../core/canvas.dart';
import '../core/rect.dart';
import '../core/events.dart';
import '../core/bindings.dart';
import 'dialog.dart';

/// Interactive dialog component that handles input and focus management.
class TuiInteractiveDialog extends TuiInteractiveComponent {
  final TuiDialog dialog;
  TuiDialogResult? _result;
  int _focusIndex = 0;
  final List<String> _focusableElements = [];

  /// The result of the dialog interaction (null while active).
  TuiDialogResult? get result => _result;

  /// For input dialogs, the entered text.
  String get inputText =>
      dialog is TuiInputDialog ? (dialog as TuiInputDialog).textInput.text : '';

  TuiInteractiveDialog(this.dialog) {
    _initializeFocusableElements();
  }

  void _initializeFocusableElements() {
    _focusableElements.clear();

    if (dialog is TuiAlertDialog) {
      _focusableElements.add('ok');
    } else if (dialog is TuiConfirmDialog) {
      _focusableElements.addAll(['cancel', 'confirm']);
    } else if (dialog is TuiInputDialog) {
      _focusableElements.addAll(['input', 'cancel', 'confirm']);
    }

    _focusIndex = 0;
  }

  @override
  bool handleInput(TuiEvent event) {
    if (!focused) return false;

    if (event is TuiKeyEvent) {
      // Handle ESC key to cancel
      if (event.code == TuiKeyCode.escape) {
        _result = TuiDialogResult.cancelled;
        markNeedsRebuild();
        return true;
      }

      // Handle Enter key
      if (event.code == TuiKeyCode.enter) {
        _handleEnterKey();
        return true;
      }

      // Handle Tab or Arrow keys for focus navigation
      if (event.code == TuiKeyCode.tab ||
          event.code == TuiKeyCode.arrowLeft ||
          event.code == TuiKeyCode.arrowRight) {
        _navigateFocus(event.code == TuiKeyCode.arrowLeft ? -1 : 1);
        markNeedsRebuild();
        return true;
      }

      // Handle input for text input dialogs
      if (dialog is TuiInputDialog && _getCurrentFocus() == 'input') {
        final inputDialog = dialog as TuiInputDialog;
        TuiBindings.textEdit(event, inputDialog.textInput);
        markNeedsRebuild();
        return true;
      }

      // Handle printable characters for quick navigation
      if (event.isPrintable) {
        final ch = event.char!.toLowerCase();
        switch (ch) {
          case 'y':
            if (dialog is TuiConfirmDialog) {
              _result = TuiDialogResult.confirmed;
              markNeedsRebuild();
              return true;
            }
            break;
          case 'n':
            if (dialog is TuiConfirmDialog) {
              _result = TuiDialogResult.cancelled;
              markNeedsRebuild();
              return true;
            }
            break;
          case 'q':
            // Q key always cancels/dismisses any dialog
            _result = TuiDialogResult.cancelled;
            markNeedsRebuild();
            return true;
        }
      }
    }

    return false;
  }

  void _handleEnterKey() {
    final currentFocus = _getCurrentFocus();

    switch (currentFocus) {
      case 'ok':
      case 'confirm':
        _result = TuiDialogResult.confirmed;
        break;
      case 'cancel':
        _result = TuiDialogResult.cancelled;
        break;
      case 'input':
        // Move focus to confirm button on Enter in input field
        _focusIndex = _focusableElements.indexOf('confirm');
        break;
    }

    markNeedsRebuild();
  }

  void _navigateFocus(int direction) {
    if (_focusableElements.isEmpty) return;

    _focusIndex = (_focusIndex + direction) % _focusableElements.length;
    if (_focusIndex < 0) {
      _focusIndex = _focusableElements.length - 1;
    }
  }

  String _getCurrentFocus() {
    if (_focusIndex >= 0 && _focusIndex < _focusableElements.length) {
      return _focusableElements[_focusIndex];
    }
    return '';
  }

  @override
  String get focusHint {
    if (dialog is TuiAlertDialog) {
      return 'Enter=OK | ESC/Q=Cancel';
    } else if (dialog is TuiConfirmDialog) {
      return 'Tab=Navigate | Enter=Select | Y/N=Quick | ESC/Q=Cancel';
    } else if (dialog is TuiInputDialog) {
      return 'Tab=Navigate | Enter=Confirm | ESC/Q=Cancel';
    }
    return 'Enter=OK | ESC/Q=Cancel';
  }

  @override
  void paintSurface(TuiSurface surface, TuiRect rect) {
    // Paint backdrop
    dialog.paintBackdrop(surface, rect);

    // Calculate dialog position
    final dialogRect = dialog.calculateDialogRect(rect.width, rect.height);

    // Update the dialog's focus state before rendering
    dialog.focusedElement = _getCurrentFocus();

    // Paint the dialog
    dialog.paintSurface(surface, dialogRect);
  }
}
