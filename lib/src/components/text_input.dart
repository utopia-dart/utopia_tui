class TuiTextInput {
  String text;
  int cursor; // 0..text.length
  final int maxLength;

  TuiTextInput({this.text = '', this.cursor = 0, this.maxLength = 256});

  void insert(String ch) {
    if (text.length >= maxLength) return;
    text = text.substring(0, cursor) + ch + text.substring(cursor);
    cursor += ch.length;
  }

  void backspace() {
    if (cursor > 0) {
      text = text.substring(0, cursor - 1) + text.substring(cursor);
      cursor--;
    }
  }

  void del() {
    if (cursor < text.length) {
      text = text.substring(0, cursor) + text.substring(cursor + 1);
    }
  }

  void left() {
    if (cursor > 0) cursor--;
  }

  void right() {
    if (cursor < text.length) cursor++;
  }

  String render(int width) {
    final content = text;
    final clipped = content.length > width
        ? content.substring(0, width)
        : content;
    // Show cursor as block by inverting the char at position if visible
    final cur = cursor.clamp(0, width);
    final before = clipped.substring(0, cur);
    final current = cur < clipped.length ? clipped[cur] : ' ';
    final after = cur < clipped.length - 1 ? clipped.substring(cur + 1) : '';
    final line = '$before[$current]$after'.padRight(width);
    return line.substring(0, width);
  }
}
