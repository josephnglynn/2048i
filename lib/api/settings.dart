import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:get_storage/get_storage.dart';
import 'package:improved_2048/api/firebase_info.dart';
import 'package:firedart/firedart.dart';
import 'package:improved_2048/api/pref_store.dart';
import 'package:improved_2048/themes/baseClass.dart';
import 'package:path/path.dart';
import 'package:share/share.dart';

class Settings {
  BoardThemeValues boardThemeValues;
  int themeIndex;
  bool showMovesInsteadOfTime;
  GetStorage storage;
  String storageDirectoryPath;
  FirebaseAuth firebaseAuth;
  Firestore firestore;
  int animationDuration;

  Radius radius = Radius.circular(5);
  double padding = 5;
  late double halfPadding;

  Settings(
    this.boardThemeValues,
    this.themeIndex,
    this.showMovesInsteadOfTime,
    this.storage,
    this.storageDirectoryPath,
    this.firebaseAuth,
    this.firestore,
    this.animationDuration,
  ) {
    halfPadding = padding / 2;
  }

  static Settings? _settings;

  static init() async => await _init();

  static Settings get() => _settings!;

  Future shareCurrentThemeToOtherApps() async {
    String fileName = "${boardThemeValues.getThemeName()}";
    String filePath = join(storageDirectoryPath, fileName);
    File file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(boardThemeValues.toJson());
    Share.shareFiles([filePath]);
  }

  Future<String> exportTheme() async {
    String fileName = "${boardThemeValues.getThemeName()}";
    String filePath = join(storageDirectoryPath, fileName);
    File file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
      print("CREATING FILE");
    }
    await file.writeAsString(boardThemeValues.toJson());
    return filePath;
  }

  Future<bool> canUseName(String name) async {
    if (name == "DefaultTheme" ||
        name == "MaterialTheme" ||
        name == "Default Theme" ||
        name == "Material Theme") return false;
    List<SquareColors> otherThemes = await getOtherSavedThemes();
    for (int i = 0; i < otherThemes.length; ++i) {
      if (otherThemes[i].themeName == name) {
        return false;
      }
    }
    return true;
  }

  Future setShowMovesInsteadOfTime(bool value) async {
    await storage.write("showMovesInsteadOfTime", value);
    showMovesInsteadOfTime = value;
  }

  Future setThemeAsPreInstalledOne(int whichTheme) async {
    try {
      await storage.remove("CurrentTheme");
    } catch (e) {
      print(e);
    }
    if (whichTheme == 0) {
      await storage.write("MaterialTheme", false);
      boardThemeValues = DefaultTheme();
    }
    if (whichTheme == 1) {
      await storage.write("MaterialTheme", true);
      boardThemeValues = MaterialTheme();
    }
  }

  Future<List<SquareColors>> getOtherSavedThemes() async {
    var otherThemes = storage.read("themes") ?? [];
    List<SquareColors> squareColorsList = [];
    otherThemes.forEach((element) {
      squareColorsList.add(SquareColors.fromJson(element));
    });
    return squareColorsList;
  }

  Future<List<String>> getOtherSavedThemesAsString() async {
    return storage.read("themes") ?? [];
  }

  Future setThemeAsNonInstalledOneFromName(String name) async {
    await storage.write("CurrentTheme", name);
    boardThemeValues = FromStorageTheme(
      (await getOtherSavedThemes())
          .firstWhere((element) => element.themeName == name),
    );
  }

  void updateRadius(int size) {
    if (size > 10) {
      radius = Radius.circular(0);
      return;
    }
    final power = pow(0.8, size);
    radius = Radius.circular(
      power.toDouble() * 10,
    );
  }

  Future setAnimationDuration(int value) async {
    animationDuration = value;
    storage.write("animationDuration", value);
  }

  void updatePadding(int size) {
    final newPadding = pow(0.8, size).toDouble() * 10;
    padding = newPadding;
    halfPadding = newPadding / 2;
  }

  static Future _init() async {
    var firebaseAuth = FirebaseAuth.initialize(
      FIREBASE_KEY,
      await PreferencesStore.create(),
    );
    var firestore = Firestore.initialize(FIREBASE_ID);
    var storage = GetStorage();

    String storageDirectoryPath;
    try {
      storageDirectoryPath = (await getExternalStorageDirectory() ??
              await getApplicationDocumentsDirectory())
          .path;
    } catch (e) {
      storageDirectoryPath = (await getApplicationDocumentsDirectory()).path;
    }

    var themeName = storage.read("CurrentTheme");
    BoardThemeValues theme;
    if (themeName == null) {
      theme = storage.read("MaterialTheme") ?? false
          ? MaterialTheme()
          : DefaultTheme();
    } else {
      theme = FromStorageTheme(
        (await storage.read("themes"))
            .firstWhere((element) => element.themeName == themeName),
      );
    }

    var showMovesInsteadOfTime =
        storage.read("showMovesInsteadOfTime") ?? false;

    int ad = storage.read("animationDuration") ?? 250;

    _settings = Settings(
      theme,
      theme == MaterialTheme() ? 1 : 0,
      showMovesInsteadOfTime,
      storage,
      storageDirectoryPath,
      firebaseAuth,
      firestore,
      ad,
    );
  }
}
