import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeColor {
  Color light;
  Color dark;

  ThemeColor(this.light, this.dark);
}

abstract class BoardThemeFunctions {
  void updateDarkTheme();

  Color getBoardBackgroundColor();

  Color getClearTilesColor();

  Paint getClearTilePaint();
}

abstract class BoardThemeValues extends BoardThemeFunctions {
  late ThemeColor _boardBackgroundColor;
  late ThemeColor _clearTilesColor;
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
}
