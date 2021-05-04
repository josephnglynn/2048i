import 'package:shared_preferences/shared_preferences.dart';

class HighScore {
  static int highScore = 0;

  static Future init() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt("highScore") ?? 0;
  }

  static Future setHighScore(int newHighScore) async {
    if (newHighScore <= highScore) return;
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("highScore", newHighScore);
    highScore = newHighScore;
  }
}
