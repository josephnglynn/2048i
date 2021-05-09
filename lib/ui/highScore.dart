

import 'package:improved_2048/api/settings.dart';

class HighScore {
  static int highScore = 0;
  static int _whatByWhat = 1;

  static Future getHighScore(int whatByWhat) async {
    highScore =  Settings.box.read("highScore$whatByWhat") ?? 0;
    _whatByWhat = whatByWhat;
  }


  static Future setHighScore(int newHighScore, int whatByWhat) async {
    if (_whatByWhat != whatByWhat) await getHighScore(whatByWhat);
    if (newHighScore <= highScore) return;
    await Settings.box.write("highScore$_whatByWhat", newHighScore);
    highScore = newHighScore;
  }
}
