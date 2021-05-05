import 'package:improved_2048/ui/themes/baseClass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static late BoardThemeValues boardThemeValues;
  static late double fontSizeScale;


  static Future init() async {
    final prefs = await SharedPreferences.getInstance();

    int themeNumber = prefs.getInt("theme") ?? 0;
    switch (themeNumber) {
      case 0:
        boardThemeValues = DefaultTheme();
        break;
    }

    fontSizeScale = prefs.getDouble("fontSizeScale") ?? 0.75;
  }
}
