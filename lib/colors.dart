import 'package:flutter/material.dart';
import 'package:inzynierka/models/sortElement.dart';

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class AppColors {
  static const primary = Color(0xff9AFFA1);
  static const plastic = Color(0xffFCDF0A);
  static const paper = Color(0xff008CD3);
  static const glass = Color(0xff0A873F);
  static const mixed = Color(0xff1C1B17);
  static const bio = Color(0xff682123);

  static const gray = Color(0xffF8F8F8);
  //static final gray = Color(0xffeeeeee);
  static const positive = Color(0xff21BA45);
}