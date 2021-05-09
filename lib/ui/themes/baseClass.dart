import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// ignore_for_file: unused_field

class ThemeColor {
  Color light;
  Color dark;

  ThemeColor(this.light, this.dark);
}

//0 is background - 1 is empty square
class SquareColors {
  Map<int, Color> light;
  Map<int, Color> dark;
  String themeName;

  SquareColors(this.light, this.dark, this.themeName);

  String toJson() {
    Map<String, String> mapAsJson = {
      "themeName": themeName,
    };
    light.forEach((key, value) {
      mapAsJson["light=$key"] = "r=${value.red} g=${value.green} b=${value.blue} o=${value.opacity}";
    });
    dark.forEach((key, value) {
      mapAsJson["dark=$key"] = "r=${value.red} g=${value.green} b=${value.blue} o=${value.opacity}";
    });
    return json.encode(mapAsJson);
  }

  static SquareColors fromJson(String source) {
    Map<int, Color> light = {};
    Map<int, Color> dark = {};
    String themeName = "";

    Map<String, String> savedData = Map<String, String>.from(json.decode(source));
    savedData.forEach((key, value) {
      if (key == "themeName") themeName = value;
      if (key.contains("light")) {
        int red = int.parse(value.substring(value.indexOf("=") + 1, value.indexOf("g") - 1));
        value = value.substring(value.indexOf("g"));
        int green = int.parse(value.substring(value.indexOf("=")  + 1, value.indexOf("b") - 1));
        value = value.substring(value.indexOf("b"));
        int blue = int.parse(value.substring(value.indexOf("=")  + 1, value.indexOf("o") - 1));
        value = value.substring(value.indexOf("o"));
        double opacity = double.parse(value.substring(value.indexOf("=")  + 1));
        light[int.parse(key.substring(key.indexOf("=") + 1))] = Color.fromRGBO(red, green, blue, opacity);
      }
      if (key.contains("dark")) {
        int red = int.parse(value.substring(value.indexOf("=") + 1, value.indexOf("g") - 1));
        value = value.substring(value.indexOf("g"));
        int green = int.parse(value.substring(value.indexOf("=")  + 1, value.indexOf("b") - 1));
        value = value.substring(value.indexOf("b"));
        int blue = int.parse(value.substring(value.indexOf("=")  + 1, value.indexOf("o") - 1));
        value = value.substring(value.indexOf("o"));
        double opacity = double.parse(value.substring(value.indexOf("=")  + 1));
        dark[int.parse(key.substring(key.indexOf("=") + 1))] = Color.fromRGBO(red, green, blue, opacity);
      }
    });
    return SquareColors(light, dark, themeName);
  }
}

abstract class BoardThemeFunctions {
  void updateDarkTheme();
  String toJson();

  Map<int, Color> getSquareColors();
}

abstract class BoardThemeValues extends BoardThemeFunctions {
  late SquareColors _squareColors;
  late bool darkTheme;
  String getThemeName();
}

class DefaultTheme implements BoardThemeValues {
  @override
  void updateDarkTheme() =>
      SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;

  @override
  bool darkTheme =
      SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;

  @override
  SquareColors _squareColors = SquareColors(
    {
      0: Color.fromRGBO(187, 173, 160, 1),
      1: Color.fromRGBO(205, 193, 180, 1),
      2: Colors.orange.shade200,
      4: Colors.orange.shade300,
      8: Colors.orange.shade400,
      16: Colors.orange.shade500,
      32: Colors.orange.shade600,
      64: Colors.orange.shade700,
      128: Colors.orange.shade800,
      256: Colors.orange.shade900,
      512: Colors.tealAccent.shade200,
      1024: Colors.tealAccent.shade400,
      2048: Colors.tealAccent.shade700,
    },
    {
      0: Color.fromRGBO(108, 100, 94, 1.0),
      1: Color.fromRGBO(135, 125, 120, 1.0),
      2: Colors.orange.shade300,
      4: Colors.orange.shade400,
      8: Colors.orange.shade500,
      16: Colors.orange.shade600,
      32: Colors.orange.shade700,
      64: Colors.orange.shade800,
      128: Colors.orange.shade900,
      256: Colors.tealAccent.shade200,
      512: Colors.tealAccent.shade400,
      1024: Colors.tealAccent.shade700,
      2048: Colors.tealAccent.shade700,
    },
    "DefaultTheme",
  );

  @override
  Map<int, Color> getSquareColors() =>
      darkTheme ? _squareColors.dark : _squareColors.light;

  @override
  String getThemeName() => _squareColors.themeName;

  @override
  String toJson() => _squareColors.toJson();
}

class MaterialTheme implements BoardThemeValues {
  @override
  void updateDarkTheme() => darkTheme =
      SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;

  @override
  bool darkTheme =
      SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;

  @override
  SquareColors _squareColors = SquareColors(
    {
      0: Color.fromRGBO(187, 173, 160, 1),
      1: Color.fromRGBO(205, 193, 180, 1),
      2: Color.fromRGBO(171, 250, 209, 1),
      4: Color.fromRGBO(91, 227, 166, 1),
      8: Color.fromRGBO(0, 225, 234, 1),
      16: Color.fromRGBO(0, 201, 227, 1),
      32: Color.fromRGBO(238, 184, 255, 1),
      64: Color.fromRGBO(230, 148, 225, 1),
      128: Color.fromRGBO(247, 185, 148, 1),
      256: Color.fromRGBO(255, 156, 99, 1),
      512: Color.fromRGBO(255, 115, 87, 1),
      1024: Color.fromRGBO(255, 87, 87, 1),
      2048: Color.fromRGBO(56, 56, 56, 1),
    },
    {
      0: Color.fromRGBO(108, 100, 94, 1.0),
      1: Color.fromRGBO(135, 125, 120, 1.0),
      2: Color.fromRGBO(171, 250, 209, 1),
      4: Color.fromRGBO(91, 227, 166, 1),
      8: Color.fromRGBO(0, 225, 234, 1),
      16: Color.fromRGBO(0, 201, 227, 1),
      32: Color.fromRGBO(238, 184, 255, 1),
      64: Color.fromRGBO(230, 148, 225, 1),
      128: Color.fromRGBO(247, 185, 148, 1),
      256: Color.fromRGBO(255, 156, 99, 1),
      512: Color.fromRGBO(255, 115, 87, 1),
      1024: Color.fromRGBO(255, 87, 87, 1),
      2048: Color.fromRGBO(201, 201, 201, 1),
    },
    "MaterialTheme",
  );

  @override
  Map<int, Color> getSquareColors() =>
      darkTheme ? _squareColors.dark : _squareColors.light;

  @override
  String getThemeName() => _squareColors.themeName;

  @override
  String toJson() => _squareColors.toJson();
}

class FromStorageTheme implements BoardThemeValues {
  FromStorageTheme(this._squareColors);

  @override
  SquareColors _squareColors;

  @override
  bool darkTheme =
      SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;

  @override
  Map<int, Color> getSquareColors() =>
      darkTheme ? _squareColors.dark : _squareColors.light;

  @override
  void updateDarkTheme() => darkTheme =
      SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;

  static Future<BoardThemeValues> createStorageTheme(String filePath) async {
    File file = File(filePath);
    if (!await file.exists()) return DefaultTheme();

    SquareColors? squareColors;
    try {
      squareColors =       SquareColors.fromJson(
        await file.readAsString(),
      );
    } catch (e) {
      print(e);
      return DefaultTheme();
    }


    return FromStorageTheme(
      squareColors
    );
  }

  @override
  String getThemeName() => _squareColors.themeName;

  @override
  String toJson() => _squareColors.toJson();
}
