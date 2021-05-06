import 'package:shared_preferences/shared_preferences.dart';

class HighScore {
  static int highScore = 0;
  static int _whatByWhat = 1;

  static Future getHighScore(int whatByWhat) async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt("highScore$whatByWhat") ?? 0;
    _whatByWhat = whatByWhat;
  }


  static Future setHighScore(int newHighScore, int whatByWhat) async {
    if (_whatByWhat != whatByWhat) await getHighScore(whatByWhat);
    if (newHighScore <= highScore) return;
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("highScore$_whatByWhat", newHighScore);
    highScore = newHighScore;
  }
}
