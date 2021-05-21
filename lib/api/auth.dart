import 'package:firedart/firedart.dart';
import 'package:improved_2048/api/settings.dart';

class Result {
  Object? error;
  bool success;

  Result(this.success, {this.error});
}

class Auth {
  static late bool loggedIn;
  static late String? userName;

  static Future<Result> changeName(String newName) async {
    try {
     await nameIsAlright(newName, true);

    } catch (e){
      return Result(false, error: e);
    }

    await Settings.firestore
        .collection("userNames")
        .document(userName!)
        .delete();
    await Settings.firestore.collection("userNames").document(newName).update({
      "name": newName,
    });
    await Settings.firebaseAuth.updateProfile(displayName: newName);
    Settings.storage.write("userName", newName);
    userName = newName;
    return Result(true);
  }

  static Future<bool> nameIsAlright(
      String userName, bool alreadyLoggedIn) async {
    if (!alreadyLoggedIn) await Settings.firebaseAuth.signInAnonymously();
    final Page<Document> collection =
        await Settings.firestore.collection("userNames").get();
    for (var doc in collection) {
      if (doc.map["name"] == userName) {
        if (!alreadyLoggedIn) Settings.firebaseAuth.signOut();
        throw "Name is taken";
      }
    }
    if (!alreadyLoggedIn) Settings.firebaseAuth.signOut();
    return true;
  }

  static Future<Result> signUp(
      String email, String name, String password) async {
    try {
      await nameIsAlright(name, false);

      await Settings.firebaseAuth.signUp(email, password);

      loggedIn = true;
      Settings.storage.write("loggedIn", true);

      userName = name;
      Settings.storage.write("userName", name);

      await Settings.firebaseAuth.updateProfile(displayName: name);
      await Settings.firestore.collection("userNames").document(name).update({
        "name": name,
      });

      return Result(true);
    } catch (e) {
      print(e);
      return Result(false, error: e);
    }
  }

  static Future<Result> login(String email, String password) async {
    try {
      await Settings.firebaseAuth.signIn(email, password);

      loggedIn = true;
      Settings.storage.write("loggedIn", true);

      final user = await Settings.firebaseAuth.getUser();
      userName = user.displayName!;
      Settings.storage.write("userName", user.displayName);

      return Result(true);
    } catch (e) {
      print(e);
      return Result(false, error: e);
    }
  }

  static Future init() async {
    loggedIn = Settings.storage.read("loggedIn") ?? false;
    userName = Settings.storage.read("userName");
  }
}
