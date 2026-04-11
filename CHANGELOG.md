## [2.0.0]

### Breaking Changes
- **Removed `dart_console` dependency** - library now uses `dart:io` directly with zero external dependencies
- **Removed interactive wrapper classes** - `InteractiveMenu`, `InteractiveTextInput`, `InteractiveScrollView` are removed; interactive behavior is now built into `TuiList`, `TuiTextInput`, and `TuiScrollView` directly
- **`TuiCell` API changed** - now stores a `String char` (grapheme cluster) instead of `int codePoint`; use `TuiCell(char: 'A')` instead of `TuiCell(codePoint: 65)`
- **Edit/scroll mode uses Ctrl+E** instead of ESC (ESC is unreliable with `dart_console`-style input)

### Added
- **`TuiFocusManager`** - declarative tree-based focus navigation with directional movement (up/down/left/right), Tab cycling, and `focusById`
- **`TuiFocusNode`** - sealed class hierarchy (`.leaf()`, `.row()`, `.column()`) for spatial focus layout
- **`TuiFocusPlaceholder`** - focusable component for panes without interactive content
- **Wide character support** - proper handling of emoji, CJK, and fullwidth characters in rendering and word wrapping
- **Grapheme cluster support** - zero-width characters (variation selectors, combining marks, ZWJ) are grouped with their base character
- **`TuiSurface.displayWidth()`** - accurate terminal display width calculation
- **Alternate screen buffer** - clean terminal restore on Ctrl+C exit
- **RGB color support** - `TuiStyle` now supports `fgRgb` and `bgRgb`

### Fixed
- Terminal not restoring properly on Ctrl+C exit (stuck in raw mode)
- Wide characters (emoji) overwriting panel right borders
- Zero-width characters (❤️ variation selector) causing column misalignment
- Focus highlighting only working for TextInput/ScrollView, now works for all panes
- Edit mode in TextInput intercepting 'e' key instead of allowing typing

### Improved
- Components (`TuiList`, `TuiTextInput`, `TuiScrollView`, `TuiTabs`) now extend `TuiInteractiveComponent` directly
- Async stdin key reading - no more isolate-based input, fully cancellable
- Word wrapping accounts for display width of wide characters
- Vim-style navigation (h/j/k/l) alongside arrow keys in interactive components

## [1.1.0]

- Dialog support with modal overlays

## [1.0.0]

### Added

#### Core Framework
- **TuiApp**: Base application class with event loop and rendering pipeline
- **TuiRunner**: Application runner with terminal setup and cleanup
- **TuiContext**: Application context with dimensions and event management
- **TuiSurface**: High-performance canvas for character-based rendering
- **TuiCanvas**: Advanced surface with border rendering capabilities

#### Component System
- **TuiComponent**: Base component class for paintSurface architecture
- **Layout Components**:
  - `TuiRow`: Horizontal layout with flexible widths and gap support
  - `TuiColumn`: Vertical layout with flexible heights and gap support
  - `TuiPadding`: Padding wrapper component
  - `TuiCenter`: Center alignment component
- **UI Components**:
  - `TuiText`: Text rendering with multiline support
  - `TuiButton`: Interactive button with hover and click states
  - `TuiList` / `TuiListView`: Selectable list component
  - `TuiTextInput` / `TuiTextInputView`: Text input with cursor and editing
  - `TuiProgressBar`: Progress indicator with customizable styling
  - `TuiSpinner`: Animated loading spinners
  - `TuiStatusBar`: Status bar with left/center/right sections
  - `TuiTable`: Data table with headers and styling
  - `TuiTabs`: Tab navigation component
  - `TuiScrollView`: Scrollable content container
  - `TuiCheckbox`: Interactive checkbox component
  - `TuiPanelBox`: Container with borders and title

#### Styling & Theming
- **TuiStyle**: Comprehensive styling with ANSI color support (256 colors)
- **TuiTheme**: Built-in themes (dark, light, contrast, monokai, oceanic)
- **TuiBorderChars**: Border character sets (ASCII, rounded, thick, double)
- **Styling Features**:
  - Foreground and background colors
  - Bold, italic, underline, strikethrough
  - Custom border styles and characters

#### Event System
- **TuiKeyEvent**: Keyboard input handling with special key support
- **TuiResizeEvent**: Terminal resize detection
- **TuiTickEvent**: Timer-based events for animations
- **Interactive Components**: Focus management and input routing

#### Core Utilities
- **TuiRect**: Rectangle geometry for layouts and clipping
- **TuiLayout**: Flexible layout algorithms for rows and columns
- **Terminal Integration**: Cross-platform terminal control
- **ANSI Support**: Full ANSI escape sequence generation

### Technical Features
- **High Performance**: Optimized rendering with minimal screen updates
- **Memory Efficient**: Efficient character cell management
- **Error Resilient**: Robust error handling throughout the framework
- **Well Tested**: Comprehensive unit test suite with 140+ tests
- **Type Safe**: Full Dart type safety with null safety support

### Documentation
- Complete API documentation with examples
- Quick start guide and comprehensive README
- Example applications demonstrating key features

### Development
- Dart 3.9+ compatibility
- Linting with official Dart lints
- Comprehensive test coverage for all components
