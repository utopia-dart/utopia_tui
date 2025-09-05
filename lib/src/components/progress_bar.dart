class TuiProgressBar {
  double value; // 0.0 .. 1.0
  TuiProgressBar({this.value = 0});

  String render(int width) {
    final inner = (width - 2).clamp(1, 1000);
    final filled = (value.clamp(0, 1) * inner).round();
    final bar = '[${'█' * filled}${' ' * (inner - filled)}]';
    return bar.substring(0, width);
  }
}
