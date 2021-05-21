import 'package:improved_2048/api/settings.dart';

class Result {
  Object? error;
  bool success;
  Result(this.success, {this.error});
}

class Auth {
  static late bool loggedIn;
  static late String? userName;

  static Future<Result> signUp(String email, String name, String password) async {
    try {
      await Settings.firebaseAuth.signUp(email, password);

      loggedIn = true;
      Settings.storage.write("loggedIn", true);

      userName = name;
      Settings.storage.write("userName", name);

      await Settings.firebaseAuth.updateProfile(displayName: name);

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
