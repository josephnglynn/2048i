import 'package:improved_2048/api/auth.dart';
import 'package:improved_2048/api/settings.dart';

class HighScore {
  int highScore = 0;
  int _cachedHighScore = 1;

  static HighScore _highScore = HighScore();

  static HighScore get() => _highScore;

  Future getHighScore(int whatByWhat) async {
    highScore = Settings.get().storage.read("highScore$whatByWhat") ?? 0;
    _cachedHighScore = whatByWhat;
  }

  Future tryAndUploadToDataBase(int whatByWhat) async {
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
          "highScore": highScore,
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
          "highScore": highScore,
          "name": Auth.get().userName,
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future checkScoreOnDataBase(int whatByWhat) async {
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
        if (document.map["highScore"] > highScore)
          highScore = document.map["highScore"];
      }
    } catch (e) {
      print(e);
    }
  }

  Future setHighScore(int newHighScore, int whatByWhat) async {
    if (_cachedHighScore != whatByWhat) {
      await getHighScore(whatByWhat);
      await checkScoreOnDataBase(whatByWhat);
    }
    if (newHighScore <= highScore) return;
    await Settings.get()
        .storage
        .write("highScore${_cachedHighScore}", newHighScore);
    highScore = newHighScore;
    await tryAndUploadToDataBase(whatByWhat);
  }
}
