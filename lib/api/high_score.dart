import 'package:improved_2048/api/auth.dart';
import 'package:improved_2048/api/settings.dart';

class HighScore {
  int highScore = 0;
  int _whatByWhat = 1;
  static HighScore? _highScore;

  static HighScore get() => _highScore!;

  static Future getHighScore(int whatByWhat) async {
    get().highScore = Settings.get().storage.read("highScore$whatByWhat") ?? 0;
    get()._whatByWhat = whatByWhat;
  }

  static Future tryAndUploadToDataBase(int whatByWhat) async {
    if (Auth.get().userName == null) return;
    try {
      if (await Settings.get()
          .firestore
          .collection("users")
          .document("scores")
          .collection("$whatByWhat")
          .document(Auth.get().userName!)
          .exists) {
        await Settings.get()
            .firestore
            .collection("users")
            .document("scores")
            .collection("$whatByWhat")
            .document(Auth.get().userName!)
            .update({
          "highScore": get().highScore,
          "name": Auth.get().userName,
        });
      } else {
        await Settings.get()
            .firestore
            .collection("users")
            .document("scores")
            .collection("$whatByWhat")
            .document(Auth.get().userName!)
            .create({
          "highScore": get().highScore,
          "name": Auth.get().userName,
        });
      }
    } catch (e) {
      print(e);
    }
  }

  static Future checkScoreOnDataBase(int whatByWhat) async {
    if (Auth.get().userName == null) return;
    try {
      if (await Settings.get()
          .firestore
          .collection("users")
          .document("scores")
          .collection("$whatByWhat")
          .document(Auth.get().userName!)
          .exists) {
        final document = await Settings.get()
            .firestore
            .collection("users")
            .document("scores")
            .collection("$whatByWhat")
            .document(Auth.get().userName!)
            .get();
        if (document.map["highScore"] > get().highScore)
          get().highScore = document.map["highScore"];
      }
    } catch (e) {
      print(e);
    }
  }

  static Future setHighScore(int newHighScore, int whatByWhat) async {
    if (get()._whatByWhat != whatByWhat) {
      await getHighScore(whatByWhat);
      await checkScoreOnDataBase(whatByWhat);
    }
    if (newHighScore <= get().highScore) return;
    await Settings.get()
        .storage
        .write("highScore${get()._whatByWhat}", newHighScore);
    get().highScore = newHighScore;
    await tryAndUploadToDataBase(whatByWhat);
  }
}
