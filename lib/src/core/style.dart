// Simple styling utilities built on ANSI escape sequences.

class TuiStyle {
  final int? fg; // 0..255 8-bit color
  final int? bg; // 0..255 8-bit color
  final bool bold;
  final bool italic;
  final bool underline;

  const TuiStyle({this.fg, this.bg, this.bold = false, this.italic = false, this.underline = false});

  TuiStyle merge(TuiStyle other) => TuiStyle(
        fg: other.fg ?? fg,
        bg: other.bg ?? bg,
        bold: bold || other.bold,
        italic: italic || other.italic,
        underline: underline || other.underline,
      );

  TuiStyle copyWith({int? fg, int? bg, bool? bold, bool? italic, bool? underline}) => TuiStyle(
        fg: fg ?? this.fg,
        bg: bg ?? this.bg,
        bold: bold ?? this.bold,
        italic: italic ?? this.italic,
        underline: underline ?? this.underline,
      );

  String apply(String text) {
    final buf = StringBuffer();
    if (bold || italic || underline || fg != null || bg != null) {
      buf.write('\x1b[');
      final parts = <String>[];
      if (bold) parts.add('1');
      if (italic) parts.add('3');
      if (underline) parts.add('4');
      if (fg != null) parts.add('38;5;$fg');
      if (bg != null) parts.add('48;5;$bg');
      buf.write(parts.join(';'));
      buf.write('m');
      buf.write(text);
      buf.write('\x1b[0m');
      return buf.toString();
    }
    return text;
  }
}

// Strip ANSI escape sequences for width calculations.
String tuiStripAnsi(String input) {
  final re = RegExp(r'\x1B\[[0-9;]*m');
  return input.replaceAll(re, '');
}

// Clip a styled string to a target visible width (characters), preserving ANSI.
String tuiClipAnsi(String input, int visibleWidth) {
  if (visibleWidth <= 0) return '';
  final re = RegExp(r'\x1B\[[0-9;]*m');
  final out = StringBuffer();
  var visible = 0;
  for (var i = 0; i < input.length; i++) {
    final ch = input[i];
    if (ch == '\x1B') {
      // copy ANSI sequence as-is
      final match = re.matchAsPrefix(input, i);
      if (match != null) {
        out.write(match.group(0));
        i = match.end - 1; // -1 because loop will i++
        continue;
      }
    }
    if (visible >= visibleWidth) break;
    out.write(ch);
    visible++;
  }
  // ensure reset at end if there was any ansi start
  if (out.toString().contains('\x1B[') && !out.toString().endsWith('\x1b[0m')) {
    out.write('\x1b[0m');
  }
  return out.toString();
}
