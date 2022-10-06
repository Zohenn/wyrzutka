extension TextOverflowEllipsisFix on String {
  String get overflowFix => replaceAll(' ', '\u{000A0}');
}