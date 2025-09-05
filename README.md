<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

# Utopia TUI - A Powerful Dart Terminal UI Library 🚀

A comprehensive, high-performance Terminal User Interface (TUI) library for Dart that makes building beautiful console applications effortless.

## ✨ Features

- **Rich Component System**: Pre-built components including panels, lists, text inputs, progress bars, spinners, tables, tabs, and more
- **Advanced Layout Management**: Flexible row/column layouts with padding, centering, and responsive sizing
- **Beautiful Theming**: Multiple built-in themes (dark, light, contrast, monokai, oceanic) with full customization support
- **Seamless Panel Connections**: Perfect border rendering with connected side-by-side panels
- **ANSI Styling**: Full support for colors, bold, italic, underline with 256-color palette
- **Event-Driven Architecture**: Keyboard input handling, tick-based animations, and resize detection
- **Error-Resilient**: Robust error handling that keeps your TUI running smoothly
- **High Performance**: Optimized buffered rendering with differential updates

## 🎯 Quick Start

### Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  utopia_tui: ^1.0.0
```

### Basic Usage

```dart
import 'package:utopia_tui/utopia_tui.dart';

class MyApp extends TuiApp {
  @override
  void build(TuiContext context) {
    // Create a simple panel with content
    TuiPanelBox(
      title: ' Hello TUI! ',
      titleStyle: TuiTheme.dark.titleStyle,
      borderStyle: TuiTheme.dark.borderStyle,
      child: TuiText('Welcome to Utopia TUI!

Press Ctrl+C to quit.'),
    ).paint(context, row: 2, col: 2, width: context.width - 4, height: context.height - 4);
  }
}

void main() async {
  final runner = TuiRunner(MyApp());
  await runner.run();
}
```

## 🎨 Themes

Choose from several beautiful pre-built themes:

```dart
final theme = TuiTheme.dark;     // Classic dark theme
final theme = TuiTheme.light;    // Clean light theme  
final theme = TuiTheme.contrast; // High contrast theme
final theme = TuiTheme.monokai;  // Monokai-inspired theme
final theme = TuiTheme.oceanic;  // Ocean-blue theme
```

## 🧱 Components

### Panels and Layout

```dart
// Side-by-side panels with perfect border connections
TuiSideBySidePanels(
  leftTitle: ' Menu ',
  rightTitle: ' Content ',
  leftChild: TuiListView(myList),
  rightChild: TuiText('Content goes here'),
  leftWidth: 30,
  theme: TuiTheme.dark,
).paint(context, row: 0, col: 0, width: 80, height: 24);

// Flexible layouts
TuiRow(
  children: [widget1, widget2, widget3],
  widths: [20, -1, 15], // Fixed, flexible, fixed
).paint(context, row: 0, col: 0, width: 80, height: 10);

// Padding and spacing
TuiPadding.all(2, 
  child: TuiCenter(
    child: TuiText('Centered content with padding')
  )
).paint(context, row: 0, col: 0, width: 40, height: 10);
```

### Interactive Components

```dart
// Lists with selection
final list = TuiList(
  ['Option 1', 'Option 2', 'Option 3'],
  selectedStyle: TuiStyle(bold: true, fg: 39),
  unselectedStyle: TuiStyle(fg: 250),
);

// Text input with cursor
final input = TuiTextInput(
  cursorStyle: TuiStyle(bold: true, fg: 39)
);

// Progress indicators
final progress = TuiProgressBar(
  value: 0.75,
  barStyle: TuiStyle(fg: 250),
  fillStyle: TuiStyle(fg: 39),
);

// Tables
final table = TuiTable(
  headers: ['Name', 'Age', 'City'],
  rows: [
    ['Alice', '30', 'NYC'],
    ['Bob', '25', 'LA'],
  ],
  columnWidths: [15, 5, 10],
);
```

### Advanced Components

```dart
// Tabbed interface
final tabs = TuiTabs(
  ['Home', 'Settings', 'Help'],
  activeStyle: TuiStyle(bold: true, fg: 39),
  inactiveStyle: TuiStyle(fg: 250),
);

// Scrollable content
final scrollView = TuiScrollView();
scrollView.setText(longText);

// Status bar
final statusBar = TuiStatusBar(
  style: TuiStyle(bg: 240, fg: 16)
);
```

## 🎮 Event Handling

```dart
class InteractiveApp extends TuiApp {
  @override
  void onEvent(TuiEvent event, TuiContext context) {
    if (event is TuiKeyEvent) {
      if (event.isPrintable) {
        // Handle character input
        final char = event.char!;
        // ... handle typing
      } else {
        // Handle special keys
        switch (event.code) {
          case TuiKeyCode.arrowUp:
            // Handle up arrow
            break;
          case TuiKeyCode.enter:
            // Handle enter
            break;
          case TuiKeyCode.escape:
            // Handle escape
            break;
        }
      }
    } else if (event is TuiTickEvent) {
      // Handle periodic updates (animations, etc.)
    }
  }
}
```

## 🎨 Styling

Create beautiful interfaces with the comprehensive styling system:

```dart
const style = TuiStyle(
  fg: 39,           // Foreground color (0-255)
  bg: 235,          // Background color (0-255)  
  bold: true,       // Bold text
  italic: true,     // Italic text
  underline: true,  // Underlined text
);

// Apply styles to text
final styledText = style.apply('Beautiful text!');

// Combine styles
final combined = baseStyle.merge(additionalStyle);
```

## 📐 Layout System

Build complex layouts with the flexible layout system:

```dart
// Vertical layout
TuiColumn(
  children: [header, content, footer],
  heights: [3, -1, 2], // Fixed, flexible, fixed
  gap: 1, // Space between components
);

// Horizontal layout  
TuiRow(
  children: [sidebar, main, toolbar],
  widths: [20, -1, 15], // Fixed, flexible, fixed
);

// Nested layouts
TuiColumn(
  children: [
    TuiText('Header'),
    TuiRow(
      children: [
        TuiPanelBox(title: 'Left', child: leftContent),
        TuiPanelBox(title: 'Right', child: rightContent),
      ],
      widths: [-1, -1], // Equal flexible sizing
    ),
  ],
  heights: [1, -1],
);
```

## 🔧 Advanced Usage

### Custom Themes

```dart
const myTheme = TuiTheme(
  border: TuiBorderChars.rounded,
  accent: TuiStyle(bold: true, fg: 196), // Bright red
  dim: TuiStyle(fg: 244),
  borderStyle: TuiStyle(fg: 238),
  titleStyle: TuiStyle(bold: true, fg: 196),
  focusBorderStyle: TuiStyle(fg: 196),
);
```

### Custom Components

```dart
class MyCustomComponent extends TuiComponent {
  @override
  void paint(TuiContext context, {
    required int row,
    required int col, 
    required int width,
    required int height
  }) {
    // Custom rendering logic
    context.writeRow(row, col, width, 'Custom content!');
  }
}
```

### Performance Optimization

The library automatically optimizes rendering performance through:
- **Differential updates**: Only redraws changed regions
- **ANSI-aware clipping**: Efficient text processing
- **Buffered rendering**: Smooth animations
- **Error isolation**: Robust error handling

## 📋 Full Example

See the complete example in `/example/example.dart` which demonstrates:
- Side-by-side connected panels
- Interactive menu navigation  
- Multiple tabs with different content
- Theme switching
- Keyboard navigation
- Progress bars and spinners
- Text input handling
- Scrollable content

Run it with: `dart run example/example.dart`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## 📄 License

MIT License - see LICENSE file for details.

---

**Built with ❤️ for the Dart community**

Transform your console applications from boring command-line tools into beautiful, interactive experiences! 🎨✨

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
