import 'package:firedart/firedart.dart';
import 'package:improved_2048/api/settings.dart';

class Result {
  Object? error;
  bool success;

  Result(this.success, {this.error});
}

class Auth {
  bool loggedIn;
  String? userName;

  Auth(this.loggedIn, this.userName);

  static Auth? _auth;

  static Auth get() => _auth!;

  Future<Result> changeName(String newName) async {
    try {
      await nameIsAlright(newName, true);
    } catch (e) {
      return Result(false, error: e);
    }

    await Settings.get().firestore
        .collection("userNames")
        .document(get().userName!)
        .delete();
    await Settings.get().firestore.collection("userNames").document(newName).update({
      "name": newName,
    });
    await Settings.get().firebaseAuth.updateProfile(displayName: newName);
    Settings.get().storage.write("userName", newName);
    get().userName = newName;
    return Result(true);
  }

  Future<bool> nameIsAlright(
      String userName, bool alreadyLoggedIn) async {
    if (!alreadyLoggedIn) await Settings.get().firebaseAuth.signInAnonymously();
    final Page<Document> collection =
        await Settings.get().firestore.collection("userNames").get();
    for (var doc in collection) {
      if (doc.map["name"] == userName) {
        if (!alreadyLoggedIn) Settings.get().firebaseAuth.signOut();
        throw "Name is taken";
      }
    }
    if (!alreadyLoggedIn) Settings.get().firebaseAuth.signOut();
    return true;
  }

  Future<Result> signUp(
      String email, String name, String password) async {
    try {
      await nameIsAlright(name, false);

      await Settings.get().firebaseAuth.signUp(email, password);

      get().loggedIn = true;
      Settings.get().storage.write("loggedIn", true);

      get().userName = name;
      Settings.get().storage.write("userName", name);

      await Settings.get().firebaseAuth.updateProfile(displayName: name);
      await Settings.get().firestore.collection("userNames").document(name).update({
        "name": name,
      });

      return Result(true);
    } catch (e) {
      print(e);
      return Result(false, error: e);
    }
  }

  Future<Result> login(String email, String password) async {
    try {
      await Settings.get().firebaseAuth.signIn(email, password);

      get().loggedIn = true;
      Settings.get().storage.write("loggedIn", true);

      final user = await Settings.get().firebaseAuth.getUser();
      get().userName = user.displayName!;
      Settings.get().storage.write("userName", user.displayName);

      return Result(true);
    } catch (e) {
      print(e);
      return Result(false, error: e);
    }
  }

  static Future init() async {
    _auth = Auth(
      Settings.get().storage.read("loggedIn") ?? false,
      Settings.get().storage.read("userName"),
    );
  }
}
