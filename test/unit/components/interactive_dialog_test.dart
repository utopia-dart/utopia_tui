import 'package:test/test.dart';
import 'package:utopia_tui/utopia_tui.dart';

void main() {
  group('TuiInteractiveDialog', () {
    group('Constructor and Initialization', () {
      test('constructor sets dialog correctly', () {
        final dialog = TuiDialog.alert(title: 'Test', message: 'Message');
        final interactiveDialog = TuiInteractiveDialog(dialog);

        expect(interactiveDialog.dialog, equals(dialog));
        expect(interactiveDialog.result, isNull);
        expect(interactiveDialog.inputText, equals(''));
      });

      test('initializes focus elements for alert dialog', () {
        final dialog = TuiDialog.alert(title: 'Test', message: 'Message');
        final interactiveDialog = TuiInteractiveDialog(dialog);

        expect(interactiveDialog.focusHint, contains('Enter=OK'));
        expect(interactiveDialog.focusHint, contains('ESC/Q=Cancel'));
      });

      test('initializes focus elements for confirm dialog', () {
        final dialog = TuiDialog.confirm(title: 'Test', message: 'Message');
        final interactiveDialog = TuiInteractiveDialog(dialog);

        expect(interactiveDialog.focusHint, contains('Tab=Navigate'));
        expect(interactiveDialog.focusHint, contains('Y/N=Quick'));
      });

      test('initializes focus elements for input dialog', () {
        final dialog = TuiDialog.input(title: 'Test', defaultValue: 'initial');
        final interactiveDialog = TuiInteractiveDialog(dialog);

        expect(interactiveDialog.focusHint, contains('Tab=Navigate'));
        expect(interactiveDialog.inputText, equals('initial'));
      });
    });

    group('Input Handling', () {
      test('handleInput returns false when not focused', () {
        final dialog = TuiDialog.alert(title: 'Test', message: 'Message');
        final interactiveDialog = TuiInteractiveDialog(dialog);
        final event = TuiKeyEvent(code: TuiKeyCode.enter);

        interactiveDialog.focused = false;
        final handled = interactiveDialog.handleInput(event);

        expect(handled, isFalse);
        expect(interactiveDialog.result, isNull);
      });

      test('ESC key cancels dialog', () {
        final dialog = TuiDialog.alert(title: 'Test', message: 'Message');
        final interactiveDialog = TuiInteractiveDialog(dialog);
        final event = TuiKeyEvent(code: TuiKeyCode.escape);

        interactiveDialog.focused = true;
        final handled = interactiveDialog.handleInput(event);

        expect(handled, isTrue);
        expect(interactiveDialog.result, equals(TuiDialogResult.cancelled));
      });

      test('Q key cancels dialog', () {
        final dialog = TuiDialog.alert(title: 'Test', message: 'Message');
        final interactiveDialog = TuiInteractiveDialog(dialog);
        final event = TuiKeyEvent(code: TuiKeyCode.printable, char: 'q');

        interactiveDialog.focused = true;
        final handled = interactiveDialog.handleInput(event);

        expect(handled, isTrue);
        expect(interactiveDialog.result, equals(TuiDialogResult.cancelled));
      });

      test('Enter key confirms alert dialog', () {
        final dialog = TuiDialog.alert(title: 'Test', message: 'Message');
        final interactiveDialog = TuiInteractiveDialog(dialog);
        final event = TuiKeyEvent(code: TuiKeyCode.enter);

        interactiveDialog.focused = true;
        final handled = interactiveDialog.handleInput(event);

        expect(handled, isTrue);
        expect(interactiveDialog.result, equals(TuiDialogResult.confirmed));
      });

      test('Y key confirms confirm dialog', () {
        final dialog = TuiDialog.confirm(title: 'Test', message: 'Message');
        final interactiveDialog = TuiInteractiveDialog(dialog);
        final event = TuiKeyEvent(code: TuiKeyCode.printable, char: 'y');

        interactiveDialog.focused = true;
        final handled = interactiveDialog.handleInput(event);

        expect(handled, isTrue);
        expect(interactiveDialog.result, equals(TuiDialogResult.confirmed));
      });

      test('N key cancels confirm dialog', () {
        final dialog = TuiDialog.confirm(title: 'Test', message: 'Message');
        final interactiveDialog = TuiInteractiveDialog(dialog);
        final event = TuiKeyEvent(code: TuiKeyCode.printable, char: 'n');

        interactiveDialog.focused = true;
        final handled = interactiveDialog.handleInput(event);

        expect(handled, isTrue);
        expect(interactiveDialog.result, equals(TuiDialogResult.cancelled));
      });

      test('Tab key navigates focus', () {
        final dialog = TuiDialog.confirm(title: 'Test', message: 'Message');
        final interactiveDialog = TuiInteractiveDialog(dialog);
        final event = TuiKeyEvent(code: TuiKeyCode.tab);

        interactiveDialog.focused = true;
        final handled = interactiveDialog.handleInput(event);

        expect(handled, isTrue);
        expect(interactiveDialog.result, isNull); // Should not close dialog
      });

      test('Arrow keys navigate focus', () {
        final dialog = TuiDialog.confirm(title: 'Test', message: 'Message');
        final interactiveDialog = TuiInteractiveDialog(dialog);
        final leftEvent = TuiKeyEvent(code: TuiKeyCode.arrowLeft);
        final rightEvent = TuiKeyEvent(code: TuiKeyCode.arrowRight);

        interactiveDialog.focused = true;

        final leftHandled = interactiveDialog.handleInput(leftEvent);
        expect(leftHandled, isTrue);

        final rightHandled = interactiveDialog.handleInput(rightEvent);
        expect(rightHandled, isTrue);

        expect(interactiveDialog.result, isNull);
      });
    });

    group('Text Input Handling', () {
      test(
        'text input receives character input when focused on input field',
        () {
          final dialog = TuiDialog.input(title: 'Test', defaultValue: '');
          final interactiveDialog = TuiInteractiveDialog(dialog);
          final event = TuiKeyEvent(code: TuiKeyCode.printable, char: 'a');

          interactiveDialog.focused = true;
          final handled = interactiveDialog.handleInput(event);

          expect(handled, isTrue);
          expect(interactiveDialog.inputText, equals('a'));
        },
      );

      test('backspace works in input field', () {
        final dialog = TuiDialog.input(title: 'Test', defaultValue: 'abc');
        final interactiveDialog = TuiInteractiveDialog(dialog);
        final event = TuiKeyEvent(code: TuiKeyCode.backspace);

        interactiveDialog.focused = true;
        // Position cursor at end
        (dialog as TuiInputDialog).textInput.cursor = 3;

        final handled = interactiveDialog.handleInput(event);

        expect(handled, isTrue);
        expect(interactiveDialog.inputText, equals('ab'));
      });

      test('Enter in input field moves focus to confirm button', () {
        final dialog = TuiDialog.input(title: 'Test');
        final interactiveDialog = TuiInteractiveDialog(dialog);
        final event = TuiKeyEvent(code: TuiKeyCode.enter);

        interactiveDialog.focused = true;
        final handled = interactiveDialog.handleInput(event);

        expect(handled, isTrue);
        expect(interactiveDialog.result, isNull); // Should not confirm yet
      });
    });

    group('Painting', () {
      test('paintSurface does not throw', () {
        final dialog = TuiDialog.alert(title: 'Test', message: 'Message');
        final interactiveDialog = TuiInteractiveDialog(dialog);
        final surface = TuiSurface(width: 80, height: 24);
        final rect = TuiRect(x: 0, y: 0, width: 80, height: 24);

        expect(
          () => interactiveDialog.paintSurface(surface, rect),
          returnsNormally,
        );
      });

      test('paintSurface paints backdrop', () {
        final dialog = TuiDialog.alert(title: 'Test', message: 'Message');
        final interactiveDialog = TuiInteractiveDialog(dialog);
        final surface = TuiSurface(width: 40, height: 20);
        final rect = TuiRect(x: 0, y: 0, width: 40, height: 20);

        interactiveDialog.paintSurface(surface, rect);

        // Check that content was painted to the surface
        final lines = surface.toAnsiLines();
        expect(lines.length, equals(20));
        expect(lines[0].length, greaterThan(0));
      });

      test('paintSurface handles small screen sizes', () {
        final dialog = TuiDialog.alert(title: 'Test', message: 'Message');
        final interactiveDialog = TuiInteractiveDialog(dialog);
        final surface = TuiSurface(width: 30, height: 15);
        final rect = TuiRect(x: 0, y: 0, width: 30, height: 15);

        expect(
          () => interactiveDialog.paintSurface(surface, rect),
          returnsNormally,
        );
      });
    });

    group('Focus Management', () {
      test('focus hint changes based on dialog type', () {
        final alertDialog = TuiDialog.alert(title: 'Test', message: 'Message');
        final alertInteractive = TuiInteractiveDialog(alertDialog);
        expect(alertInteractive.focusHint, contains('Enter=OK'));

        final confirmDialog = TuiDialog.confirm(
          title: 'Test',
          message: 'Message',
        );
        final confirmInteractive = TuiInteractiveDialog(confirmDialog);
        expect(confirmInteractive.focusHint, contains('Tab=Navigate'));

        final inputDialog = TuiDialog.input(title: 'Test');
        final inputInteractive = TuiInteractiveDialog(inputDialog);
        expect(inputInteractive.focusHint, contains('Tab=Navigate'));
      });
    });

    group('Integration', () {
      test('interactive dialog can be focused and unfocused', () {
        final dialog = TuiDialog.alert(title: 'Test', message: 'Message');
        final interactiveDialog = TuiInteractiveDialog(dialog);

        expect(interactiveDialog.focused, isFalse);

        interactiveDialog.focused = true;
        expect(interactiveDialog.focused, isTrue);

        interactiveDialog.focused = false;
        expect(interactiveDialog.focused, isFalse);
      });

      test('result remains null until dialog is dismissed', () {
        final dialog = TuiDialog.confirm(title: 'Test', message: 'Message');
        final interactiveDialog = TuiInteractiveDialog(dialog);

        expect(interactiveDialog.result, isNull);

        interactiveDialog.focused = true;
        final tabEvent = TuiKeyEvent(code: TuiKeyCode.tab);
        interactiveDialog.handleInput(tabEvent);

        expect(interactiveDialog.result, isNull);
      });

      test('input text is accessible for input dialogs', () {
        final dialog = TuiDialog.input(title: 'Test', defaultValue: 'initial');
        final interactiveDialog = TuiInteractiveDialog(dialog);

        expect(interactiveDialog.inputText, equals('initial'));

        // Simulate typing at the end
        interactiveDialog.focused = true;
        final inputDialog = dialog as TuiInputDialog;
        inputDialog.textInput.cursor =
            inputDialog.textInput.text.length; // Move to end
        inputDialog.textInput.insert('X');

        expect(interactiveDialog.inputText, equals('initialX'));
      });

      test('input text is empty for non-input dialogs', () {
        final alertDialog = TuiDialog.alert(title: 'Test', message: 'Message');
        final alertInteractive = TuiInteractiveDialog(alertDialog);
        expect(alertInteractive.inputText, equals(''));

        final confirmDialog = TuiDialog.confirm(
          title: 'Test',
          message: 'Message',
        );
        final confirmInteractive = TuiInteractiveDialog(confirmDialog);
        expect(confirmInteractive.inputText, equals(''));
      });
    });
  });
}
