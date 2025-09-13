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
