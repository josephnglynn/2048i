import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:get_storage/get_storage.dart';
import 'package:improved_2048/ui/themes/baseClass.dart';
import 'package:path/path.dart';
import 'package:share/share.dart';

class Settings {
  static late BoardThemeValues boardThemeValues;
  static late double fontSizeScale;
  static late int themeIndex;
  static late bool showMovesInsteadOfTime;
  static late GetStorage storage;
  static late String storageDirectoryPath;

  static Future setFontSize(double _fontSizeScale) async {
    Settings.storage.write("fontSizeScale", _fontSizeScale);
    fontSizeScale = _fontSizeScale;
  }

  static Future shareCurrentThemeToOtherApps() async {
    String fileName = "${boardThemeValues.getThemeName()}";
    String filePath = join(storageDirectoryPath, fileName);
    File file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(boardThemeValues.toJson());
    Share.shareFiles([filePath]);
  }

  static Future<String> exportTheme() async {
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

  static Future<bool> canUseName(String name) async {
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

  static Future setShowMovesInsteadOfTime(bool value) async {
    await storage.write("showMovesInsteadOfTime", value);
    Settings.showMovesInsteadOfTime = value;
  }

  static Future setThemeAsPreInstalledOne(int whichTheme) async {
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

  static Future<List<SquareColors>> getOtherSavedThemes() async {
    var otherThemes = storage.read("themes") ?? [];
    List<SquareColors> squareColorsList = [];
    otherThemes.forEach((element) {
      squareColorsList.add(SquareColors.fromJson(element));
    });
    return squareColorsList;
  }

  static Future<List<String>> getOtherSavedThemesAsString() async {
    return storage.read("themes") ?? [];
  }

  static Future setThemeAsNonInstalledOneFromName(String name) async {
    await storage.write("CurrentTheme", name);
    boardThemeValues = FromStorageTheme((await getOtherSavedThemes())
        .firstWhere((element) => element.themeName == name));
  }

  static Future init() async {
    storage = GetStorage();


    try {
      storageDirectoryPath = (await getExternalStorageDirectory() ??
              await getApplicationDocumentsDirectory())
          .path;
    } catch (e) {
      storageDirectoryPath = (await getApplicationDocumentsDirectory()).path;
    }

    var themeName = storage.read("CurrentTheme");
    if (themeName == null) {
      storage.read("MaterialTheme") ?? false
          ? await setThemeAsPreInstalledOne(1)
          : await setThemeAsPreInstalledOne(0);
    } else {
      await setThemeAsNonInstalledOneFromName(themeName);
    }
    fontSizeScale = storage.read("fontSizeScale") ?? 0.75;
    showMovesInsteadOfTime = storage.read("showMovesInsteadOfTime") ?? false;
  }
}

class ImportantValues {
  static Radius radius = Radius.circular(5);
  static double padding = 5;
  static double halfPadding = padding / 2;

  static late double newTileAnimationLength;
  static late double animationLength;

  static void updateRadius(int size) {
    if (size > 10) {
      radius = Radius.circular(0);
      return;
    }
    final power = pow(0.8, size);
    radius = Radius.circular(
      power.toDouble() * 10,
    );
  }

  static void updatePadding(int size) {
    final newPadding = pow(0.8, size).toDouble() * 10;
    padding = newPadding;
    halfPadding = newPadding / 2;
  }

  static Future setAnimationLength(double value) async {
    await Settings.storage.write("animationLength", value);
    animationLength = value;
  }

  static Future setNewTileAnimationLength(double value) async {
    await Settings.storage.write("newTileAnimationLength", value);
    newTileAnimationLength = value;
  }

  static Future init() async {
    newTileAnimationLength =
        Settings.storage.read("newTileAnimationLength") ?? 0.1;
    animationLength = Settings.storage.read("animationLength") ?? 0.1;
  }
}
