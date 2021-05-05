import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
      SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;

  bool darkTheme =
      SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;

  @override
  ThemeColor _boardBackgroundColor = ThemeColor(
    Color.fromRGBO(187, 173, 160, 1),
    Color.fromRGBO(187, 173, 160, 1),
  );

  @override
  Color getBoardBackgroundColor() =>
      darkTheme ? _boardBackgroundColor.dark : _boardBackgroundColor.light;

  @override
  ThemeColor _clearTilesColor = ThemeColor(
    Color.fromRGBO(205, 193, 180, 1),
    Color.fromRGBO(205, 193, 180, 1),
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
    64: Colors.orange.shade600,
    128: Colors.orange.shade700,
    256: Colors.orange.shade700,
    512: Colors.orange.shade800,
    1024: Colors.orange.shade800,
    2048: Colors.orange.shade900,
  }, {
    0: Colors.orange.shade100,
    2: Colors.orange.shade200,
    4: Colors.orange.shade300,
    8: Colors.orange.shade400,
    16: Colors.orange.shade500,
    32: Colors.orange.shade600,
    64: Colors.orange.shade600,
    128: Colors.orange.shade700,
    256: Colors.orange.shade700,
    512: Colors.orange.shade800,
    1024: Colors.orange.shade800,
    2048: Colors.orange.shade900,
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
    Color.fromRGBO(187, 173, 160, 1),
  );

  @override
  Color getBoardBackgroundColor() =>
      darkTheme ? _boardBackgroundColor.dark : _boardBackgroundColor.light;

  @override
  ThemeColor _clearTilesColor = ThemeColor(
    Color.fromRGBO(205, 193, 180, 1),
    Color.fromRGBO(205, 193, 180, 1),
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
    64: Colors.orange.shade600,
    128: Colors.orange.shade700,
    256: Colors.orange.shade700,
    512: Colors.orange.shade800,
    1024: Colors.orange.shade800,
    2048: Colors.orange.shade900,
  }, {
    0: Colors.orange.shade100,
    2: Colors.orange.shade200,
    4: Colors.orange.shade300,
    8: Colors.orange.shade400,
    16: Colors.orange.shade500,
    32: Colors.orange.shade600,
    64: Colors.orange.shade600,
    128: Colors.orange.shade700,
    256: Colors.orange.shade700,
    512: Colors.orange.shade800,
    1024: Colors.orange.shade800,
    2048: Colors.orange.shade900,
  });

  @override
  Map<int, Color> getSquareColors() =>
      darkTheme ? _squareColors.dark : _squareColors.light;
}
