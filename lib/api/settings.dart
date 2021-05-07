import 'dart:math';
import 'dart:ui';

import 'package:improved_2048/ui/themes/baseClass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static late BoardThemeValues boardThemeValues;
  static late double fontSizeScale;
  static late int themeIndex;
  static late bool showMovesInsteadOfTime;

  static void _themeSetter(int themeNumber) {
    themeIndex = themeNumber;
    switch (themeNumber) {
      case 0:
        boardThemeValues = DefaultTheme();
        break;
      case 1:
        boardThemeValues = SeanTheme();
        break;
      case 2:
        boardThemeValues = DefaultTheme();
        break;
    }
  }

  static Future setTheme(int themeNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("theme", themeNumber);
    _themeSetter(themeNumber);
  }

  static Future setFontSize(double _fontSizeScale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("fontSizeScale", _fontSizeScale);
    fontSizeScale =  _fontSizeScale;
  }
  
  static Future setShowMovesInsteadOfTime(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("showMovesInsteadOfTime", value);
    Settings.showMovesInsteadOfTime = value;
  }

  static Future init() async {
    final prefs = await SharedPreferences.getInstance();

    _themeSetter(prefs.getInt("theme") ?? 0);
    fontSizeScale = prefs.getDouble("fontSizeScale") ?? 0.75;
    showMovesInsteadOfTime = prefs.getBool("showMovesInsteadOfTime") ?? false;
  }
}


class ImportantValues {
  static Radius radius = Radius.circular(5);
  static double padding = 5;
  static double halfPadding = padding / 2;

  static late double newTileAnimationLength;
  static late double animationLength;

  static void updateRadius(int size) {
    if (size > 10) {
      radius = Radius.circular(0);
      return;
    }
    final power = pow(0.8, size);
    radius = Radius.circular(
      power.toDouble() * 10,
    );
  }

  static void updatePadding(int size) {
    final newPadding = pow(0.8, size).toDouble() * 10;
    padding = newPadding;
    halfPadding = newPadding / 2;
  }


  static Future setAnimationLength(double value) async  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble("animationLength", value);
    animationLength = value;
  }

  static Future setNewTileAnimationLength(double value) async  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble("newTileAnimationLength", value);
    newTileAnimationLength = value;
  }

  static Future init() async {
    final prefs = await SharedPreferences.getInstance();
    newTileAnimationLength = prefs.getDouble("newTileAnimationLength") ?? 0.1;
    animationLength = prefs.getDouble("animationLength") ?? 0.1;
  }
}