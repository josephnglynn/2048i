import 'package:improved_2048/ui/themes/baseClass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static late BoardThemeValues boardThemeValues;
  static late double fontSizeScale;
  static late int themeIndex;

  static void _themeSetter(int themeNumber) {
    themeIndex = themeNumber;
    switch (themeNumber) {
      case 0:
        boardThemeValues = DefaultTheme();
        break;
      case 1:
        boardThemeValues = SeanTheme();
        break;
    }
  }

  static Future setTheme(int themeNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("theme", themeNumber);
    _themeSetter(themeNumber);
  }

  static Future setFontSize(double fontSizeScale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("fontSizeScale", fontSizeScale);
  }

  static Future init() async {
    final prefs = await SharedPreferences.getInstance();
    _themeSetter(prefs.getInt("theme") ?? 0);


    fontSizeScale = prefs.getDouble("fontSizeScale") ?? 0.75;
  }
}
