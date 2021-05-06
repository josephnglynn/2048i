import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


// ignore_for_file: unused_field

class ThemeColor {
  Color light;
  Color dark;

  ThemeColor(this.light, this.dark);
}

class SquareColors {
  Map<int, Color> light;
  Map<int, Color> dark;

  SquareColors(this.light, this.dark);
}

abstract class BoardThemeFunctions {
  void updateDarkTheme();

  Map<int, Color> getSquareColors();

  Color getBoardBackgroundColor();

  Color getClearTilesColor();

  Paint getClearTilePaint();
}

abstract class BoardThemeValues extends BoardThemeFunctions {
  late ThemeColor _boardBackgroundColor;
  late ThemeColor _clearTilesColor;
  late SquareColors _squareColors;
}

class DefaultTheme implements BoardThemeValues {
  @override
  void updateDarkTheme() => darkTheme =
      true;

  bool darkTheme =
      SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;

  @override
  ThemeColor _boardBackgroundColor = ThemeColor(
    Color.fromRGBO(187, 173, 160, 1),
    Color.fromRGBO(108, 100, 94, 1.0),
  );

  @override
  Color getBoardBackgroundColor() =>
      darkTheme ? _boardBackgroundColor.dark : _boardBackgroundColor.light;

  @override
  ThemeColor _clearTilesColor = ThemeColor(
    Color.fromRGBO(205, 193, 180, 1),
    Color.fromRGBO(135, 125, 120, 1.0),
  );

  @override
  Color getClearTilesColor() =>
      darkTheme ? _clearTilesColor.dark : _clearTilesColor.light;

  @override
  Paint getClearTilePaint() => Paint()..color = getClearTilesColor();

  @override
  SquareColors _squareColors = SquareColors({
    0: Colors.orange.shade100,
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
  }, {
    0: Colors.orange.shade200,
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
  });

  @override
  Map<int, Color> getSquareColors() =>
      darkTheme ? _squareColors.dark : _squareColors.light;
}

class SeanTheme implements BoardThemeValues {
  @override
  void updateDarkTheme() => darkTheme =
      SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;

  bool darkTheme =
      SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;

  @override
  ThemeColor _boardBackgroundColor = ThemeColor(
    Color.fromRGBO(187, 173, 160, 1),
    Color.fromRGBO(108, 100, 94, 1.0),
  );

  @override
  Color getBoardBackgroundColor() =>
      darkTheme ? _boardBackgroundColor.dark : _boardBackgroundColor.light;

  @override
  ThemeColor _clearTilesColor = ThemeColor(
    Color.fromRGBO(205, 193, 180, 1),
    Color.fromRGBO(135, 125, 120, 1.0),
  );

  @override
  Color getClearTilesColor() =>
      darkTheme ? _clearTilesColor.dark : _clearTilesColor.light;

  @override
  Paint getClearTilePaint() => Paint()..color = getClearTilesColor();

  @override
  SquareColors _squareColors = SquareColors({
    0: Color.fromRGBO(171, 250, 209, 1),
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
  }, {
    0: Color.fromRGBO(171, 250, 209, 1),
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
  });

  @override
  Map<int, Color> getSquareColors() =>
      darkTheme ? _squareColors.dark : _squareColors.light;
}
