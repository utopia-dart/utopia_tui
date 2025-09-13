import 'package:test/test.dart';
import 'package:utopia_tui/utopia_tui.dart';

void main() {
  group('TuiDialog', () {
    group('TuiAlertDialog', () {
      test('constructor sets properties correctly', () {
        final dialog = TuiDialog.alert(
          title: 'Test Alert',
          message: 'This is a test message',
          okText: 'Got it',
        );

        expect(dialog.title, equals('Test Alert'));
        expect(dialog.message, equals('This is a test message'));
        expect(dialog, isA<TuiAlertDialog>());

        final alertDialog = dialog as TuiAlertDialog;
        expect(alertDialog.okText, equals('Got it'));
      });

      test('uses default values when not specified', () {
        final dialog =
            TuiDialog.alert(title: 'Test', message: 'Message')
                as TuiAlertDialog;

        expect(dialog.okText, equals('OK'));
        expect(dialog.width, equals(0));
        expect(dialog.height, equals(0));
      });

      test('buildDialogContent creates proper structure', () {
        final dialog = TuiDialog.alert(title: 'Test', message: 'Message');

        final content = dialog.buildDialogContent();
        expect(content, isA<TuiColumn>());
      });

      test('calculateDialogRect centers dialog on screen', () {
        final dialog = TuiDialog.alert(title: 'Test', message: 'Message');

        final rect = dialog.calculateDialogRect(80, 24);
        expect(rect.x, greaterThanOrEqualTo(0));
        expect(rect.y, greaterThanOrEqualTo(0));
        expect(rect.width, lessThanOrEqualTo(80));
        expect(rect.height, lessThanOrEqualTo(24));

        // Should be roughly centered
        expect(rect.x, greaterThan(10));
        expect(rect.y, greaterThan(5));
      });
    });

    group('TuiConfirmDialog', () {
      test('constructor sets properties correctly', () {
        final dialog = TuiDialog.confirm(
          title: 'Confirm Action',
          message: 'Are you sure?',
          confirmText: 'Yes, do it',
          cancelText: 'No way',
        );

        expect(dialog.title, equals('Confirm Action'));
        expect(dialog.message, equals('Are you sure?'));
        expect(dialog, isA<TuiConfirmDialog>());

        final confirmDialog = dialog as TuiConfirmDialog;
        expect(confirmDialog.confirmText, equals('Yes, do it'));
        expect(confirmDialog.cancelText, equals('No way'));
      });

      test('uses default button text', () {
        final dialog =
            TuiDialog.confirm(title: 'Test', message: 'Message')
                as TuiConfirmDialog;

        expect(dialog.confirmText, equals('Yes'));
        expect(dialog.cancelText, equals('No'));
      });

      test('buildDialogContent creates proper structure', () {
        final dialog = TuiDialog.confirm(title: 'Test', message: 'Message');

        final content = dialog.buildDialogContent();
        expect(content, isA<TuiColumn>());
      });
    });

    group('TuiInputDialog', () {
      test('constructor sets properties correctly', () {
        final dialog =
            TuiDialog.input(
                  title: 'Enter Name',
                  message: 'Please enter your name:',
                  placeholder: 'Your name...',
                  defaultValue: 'John',
                )
                as TuiInputDialog;

        expect(dialog.title, equals('Enter Name'));
        expect(dialog.message, equals('Please enter your name:'));
        expect(dialog.placeholder, equals('Your name...'));
        expect(dialog.defaultValue, equals('John'));
        expect(dialog.textInput.text, equals('John'));
      });

      test('uses default values', () {
        final dialog = TuiDialog.input(title: 'Test') as TuiInputDialog;

        expect(dialog.placeholder, equals(''));
        expect(dialog.defaultValue, equals(''));
        expect(dialog.confirmText, equals('OK'));
        expect(dialog.cancelText, equals('Cancel'));
      });

      test('buildDialogContent creates proper structure', () {
        final dialog = TuiDialog.input(title: 'Test');

        final content = dialog.buildDialogContent();
        expect(content, isA<TuiColumn>());
      });

      test('textInput is properly initialized', () {
        final dialog =
            TuiDialog.input(title: 'Test', defaultValue: 'initial text')
                as TuiInputDialog;

        expect(dialog.textInput.text, equals('initial text'));
        expect(dialog.textInput.cursor, equals(0));
      });
    });

    group('TuiCustomDialog', () {
      test('constructor sets properties correctly', () {
        final content = TuiText('Custom content');
        final dialog =
            TuiDialog.custom(
                  title: 'Custom Dialog',
                  content: content,
                  width: 50,
                  height: 15,
                )
                as TuiCustomDialog;

        expect(dialog.title, equals('Custom Dialog'));
        expect(dialog.content, equals(content));
        expect(dialog.width, equals(50));
        expect(dialog.height, equals(15));
      });

      test('buildDialogContent returns provided content', () {
        final content = TuiText('Test content');
        final dialog = TuiDialog.custom(title: 'Test', content: content);

        expect(dialog.buildDialogContent(), equals(content));
      });
    });

    group('Dialog Rendering', () {
      test('paintSurface does not throw for alert dialog', () {
        final dialog = TuiDialog.alert(title: 'Test', message: 'Message');
        final surface = TuiSurface(width: 80, height: 24);
        final rect = TuiRect(x: 10, y: 5, width: 40, height: 10);

        expect(() => dialog.paintSurface(surface, rect), returnsNormally);
      });

      test('paintSurface does not throw for confirm dialog', () {
        final dialog = TuiDialog.confirm(title: 'Test', message: 'Message');
        final surface = TuiSurface(width: 80, height: 24);
        final rect = TuiRect(x: 10, y: 5, width: 40, height: 10);

        expect(() => dialog.paintSurface(surface, rect), returnsNormally);
      });

      test('paintSurface does not throw for input dialog', () {
        final dialog = TuiDialog.input(title: 'Test');
        final surface = TuiSurface(width: 80, height: 24);
        final rect = TuiRect(x: 10, y: 5, width: 40, height: 10);

        expect(() => dialog.paintSurface(surface, rect), returnsNormally);
      });

      test('paintBackdrop fills screen area', () {
        final dialog = TuiDialog.alert(title: 'Test', message: 'Message');
        final surface = TuiSurface(width: 20, height: 10);
        final rect = TuiRect(x: 0, y: 0, width: 20, height: 10);

        dialog.paintBackdrop(surface, rect);

        // Check that some backdrop was painted
        final lines = surface.toAnsiLines();
        expect(lines.length, equals(10));
        // Backdrop should fill the area with spaces
        expect(lines[0].length, greaterThan(0));
      });
    });

    group('Dialog Auto-sizing', () {
      test('calculateDialogRect respects minimum size', () {
        final dialog = TuiDialog.alert(title: 'X', message: 'Y');

        final rect = dialog.calculateDialogRect(80, 24);
        expect(rect.width, greaterThanOrEqualTo(20));
        expect(rect.height, greaterThanOrEqualTo(8));
      });

      test('calculateDialogRect respects screen bounds', () {
        final dialog = TuiDialog.alert(
          title: 'Test',
          message: 'Message',
          width: 100, // Larger than screen
          height: 50,
        );

        final rect = dialog.calculateDialogRect(80, 24);
        expect(rect.width, lessThanOrEqualTo(76)); // Screen width - padding
        expect(rect.height, lessThanOrEqualTo(20)); // Screen height - padding
      });

      test('calculateDialogRect uses explicit size when provided', () {
        final dialog = TuiDialog.alert(
          title: 'Test',
          message: 'Message',
          width: 40,
          height: 12,
        );

        final rect = dialog.calculateDialogRect(80, 24);
        expect(rect.width, equals(40));
        expect(rect.height, equals(12));
      });
    });
  });

  group('TuiDialogResult', () {
    test('enum has expected values', () {
      expect(TuiDialogResult.values, contains(TuiDialogResult.cancelled));
      expect(TuiDialogResult.values, contains(TuiDialogResult.confirmed));
      expect(TuiDialogResult.values, contains(TuiDialogResult.dismissed));
    });
  });

  group('TuiInputDialogResult', () {
    test('constructor sets properties correctly', () {
      final result = TuiInputDialogResult(
        TuiDialogResult.confirmed,
        'user input',
      );

      expect(result.result, equals(TuiDialogResult.confirmed));
      expect(result.text, equals('user input'));
    });

    test('can be created with cancelled result', () {
      final result = TuiInputDialogResult(TuiDialogResult.cancelled, '');

      expect(result.result, equals(TuiDialogResult.cancelled));
      expect(result.text, equals(''));
    });
  });
}
