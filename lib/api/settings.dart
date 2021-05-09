import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:get_storage/get_storage.dart';
import 'package:improved_2048/ui/themes/baseClass.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class Settings {
  static late BoardThemeValues boardThemeValues;
  static late double fontSizeScale;
  static late int themeIndex;
  static late bool showMovesInsteadOfTime;
  static late GetStorage box;

  static Future setFontSize(double _fontSizeScale) async {
    Settings.box.write("fontSizeScale", _fontSizeScale);
    fontSizeScale = _fontSizeScale;
  }

  static Future shareCurrentThemeToOtherApps() async {
    String fileName = "${boardThemeValues.getThemeName()}.json";
    String filePath = join(
        (await getExternalStorageDirectory() ??
                await getApplicationDocumentsDirectory())
            .path,
        fileName);
    File file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(boardThemeValues.toJson());
    Share.shareFiles([filePath]);
  }

  static Future<String> exportTheme() async {
    String fileName = "${boardThemeValues.getThemeName()}.json";
    String filePath = join(
        (await getExternalStorageDirectory() ??
                await getApplicationDocumentsDirectory())
            .path,
        fileName);
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
    await box.write("showMovesInsteadOfTime", value);
    Settings.showMovesInsteadOfTime = value;
  }

  static Future setThemeAsPreInstalledOne(int whichTheme) async {
    try {
      await box.remove("CurrentTheme");
    } catch (e) {
      print(e);
    }
    if (whichTheme == 0) {
      await box.write("MaterialTheme", false);
      boardThemeValues = DefaultTheme();
    }
    if (whichTheme == 1) {
      await box.write("MaterialTheme", true);
      boardThemeValues = MaterialTheme();
    }
  }

  static Future<List<SquareColors>> getOtherSavedThemes() async {
    List<String> otherThemes = box.read("themes") ?? [];
    List<SquareColors> squareColorsList = [];
    otherThemes.forEach((element) {
      squareColorsList.add(SquareColors.fromJson(element));
    });
    return squareColorsList;
  }

  static Future<List<String>> getOtherSavedThemesAsString() async {
    return box.read("themes") ?? [];
  }

  static Future setThemeAsNonInstalledOneFromName(String name) async {
    await box.write("CurrentTheme", name);
    boardThemeValues = FromStorageTheme((await getOtherSavedThemes())
        .firstWhere((element) => element.themeName == name));
  }

  static Future init() async {
    box = GetStorage();

    String? themeName = box.read("CurrentTheme");
    if (themeName == null) {
      box.read("MaterialTheme") ?? false
          ? await setThemeAsPreInstalledOne(1)
          : await setThemeAsPreInstalledOne(0);
    } else {
      await setThemeAsNonInstalledOneFromName(themeName);
    }
    fontSizeScale = box.read("fontSizeScale") ?? 0.75;
    showMovesInsteadOfTime = box.read("showMovesInsteadOfTime") ?? false;
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
    await Settings.box.write("animationLength", value);
    animationLength = value;
  }

  static Future setNewTileAnimationLength(double value) async {
    await Settings.box.write("newTileAnimationLength", value);
    newTileAnimationLength = value;
  }

  static Future init() async {
    newTileAnimationLength = Settings.box.read("newTileAnimationLength") ?? 0.1;
    animationLength = Settings.box.read("animationLength") ?? 0.1;
  }
}
