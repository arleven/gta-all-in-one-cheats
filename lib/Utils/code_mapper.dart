String getXboxImagePath(String code) {
  final cleaned = code.trim().toUpperCase();
  return 'assets/images/xbox_$cleaned.png';
}

String getPlaystationImagePath(String code) {
  final cleaned = code.trim().toUpperCase();
  return 'assets/images/ps_$cleaned.png';
}
