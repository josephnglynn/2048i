import 'package:improved_2048/api/settings.dart';

class Auth {
  static late bool loggedIn;
  static late String userName;

  static Future<bool> login(String name, String password) async {
    final result = await Settings.client.auth.signIn(
      email: name,
      password: password,
    );
    if (result.error != null) {
      return false;
    }
    userName = name;
    loggedIn = true;
    return true;
  }

  static Future<bool> signUp(String name, String password) async {
    final result = await Settings.client.auth.signUp(
      name,
      password,
    );
    if (result.error != null) {
      return false;
    }
    userName = name;
    loggedIn = true;
    return true;
  }


  static Future init() async {
    loggedIn = Settings.storage.read("loggedIn") ?? false;
    userName = Settings.storage.read("userName") ?? "";
  }
}
