import 'package:improved_2048/api/auth.dart';
import 'package:improved_2048/api/settings.dart';

class HighScore {
  static int highScore = 0;
  static int _whatByWhat = 1;

  static Future getHighScore(int whatByWhat) async {
    highScore = Settings.storage.read("highScore$whatByWhat") ?? 0;
    _whatByWhat = whatByWhat;
  }

  static Future tryAndUploadToDataBase(int whatByWhat) async {
    if (Auth.userName == null) return;
    try {
      if (await Settings.firestore
          .collection("users")
          .document("scores")
          .collection("$whatByWhat")
          .document(Auth.userName!)
          .exists) {
        await Settings.firestore
            .collection("users")
            .document("scores")
            .collection("$whatByWhat")
            .document(Auth.userName!)
            .update({
          "highScore": highScore,
        });
      } else {
        await Settings.firestore
            .collection("users")
            .document("scores")
            .collection("$whatByWhat")
            .document(Auth.userName!)
            .create({
          "highScore": highScore,
        });
      }
    } catch (e) {
      print(e);
    }
  }

  static Future checkScoreOnDataBase(int whatByWhat) async {
    if (Auth.userName == null) return;
    try {
      if (await Settings.firestore
          .collection("users")
          .document("scores")
          .collection("$whatByWhat")
          .document(Auth.userName!)
          .exists) {
        final document = await Settings.firestore
            .collection("users")
            .document("scores")
            .collection("$whatByWhat")
            .document(Auth.userName!)
            .get();
        if (document.map["highScore"] > highScore) highScore = document.map["highScore"];
      }
    } catch (e) {
      print(e);
    }
  }

  static Future setHighScore(int newHighScore, int whatByWhat) async {
    if (_whatByWhat != whatByWhat) {
      await getHighScore(whatByWhat);
      await checkScoreOnDataBase(whatByWhat);
    }
    if (newHighScore <= highScore) return;
    await Settings.storage.write("highScore$_whatByWhat", newHighScore);
    highScore = newHighScore;
    await tryAndUploadToDataBase(whatByWhat);
  }
}
