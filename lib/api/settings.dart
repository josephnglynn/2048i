import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:improved_2048/ui/themes/baseClass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static late BoardThemeValues boardThemeValues;
  static late double fontSizeScale;
  static late int themeIndex;
  static late bool showMovesInsteadOfTime;

  static Future setFontSize(double _fontSizeScale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("fontSizeScale", _fontSizeScale);
    fontSizeScale = _fontSizeScale;
  }

  static Future setShowMovesInsteadOfTime(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("showMovesInsteadOfTime", value);
    Settings.showMovesInsteadOfTime = value;
  }

  static Future setThemeAsPreInstalledOne(int whichTheme) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.remove("CurrentTheme");
    } catch (e) {
      print(e);
    }
    if (whichTheme == 0) {
      await prefs.setBool("MaterialTheme", false);
      boardThemeValues = DefaultTheme();
    }
    if (whichTheme == 1) {
      await prefs.setBool("MaterialTheme", true);
      boardThemeValues = MaterialTheme();
    }
  }

  static Future<List<SquareColors>> getOtherSavedThemes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> otherThemes = prefs.getStringList("themes") ?? [];
    List<SquareColors> squareColorsList = [];
    otherThemes.forEach((element) {
      squareColorsList.add(SquareColors.fromJson(element));
    });
    return squareColorsList;
  }

  static Future<List<String>> getOtherSavedThemesAsString() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList("themes") ?? [];
  }

  static Future setThemeAsNonInstalledOneFromName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("CurrentTheme", name);
    boardThemeValues = FromStorageTheme((await getOtherSavedThemes())
        .firstWhere((element) => element.themeName == name));
  }

  static Future setThemeAsNonInstalledOneFromPath(String location) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      SquareColors squareColors = SquareColors.fromJson(await File(location).readAsString());
      prefs.setStringList("themes", [squareColors.toJson()]..addAll(await getOtherSavedThemesAsString()));
      prefs.setString("CurrentTheme", squareColors.themeName);
      boardThemeValues = FromStorageTheme(squareColors);
    } catch(e) {
      print(e);
    }
  }

  static Future init() async {
    final prefs = await SharedPreferences.getInstance();

    String? themeName = prefs.getString("CurrentTheme");
    if (themeName == null) {
      prefs.getBool("MaterialTheme") ?? false
          ? await setThemeAsPreInstalledOne(1)
          : await setThemeAsPreInstalledOne(0);
    } else {
      await setThemeAsNonInstalledOneFromName(themeName);
    }
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

  static Future setAnimationLength(double value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble("animationLength", value);
    animationLength = value;
  }

  static Future setNewTileAnimationLength(double value) async {
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
