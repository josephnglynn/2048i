import 'package:flutter/material.dart';
import 'package:improved_2048/ui/game.dart';
import 'package:improved_2048/ui/highScore.dart';
import 'package:improved_2048/ui/homePage.dart';

import 'api/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.init();
  await HighScore.init();
  runApp(
    MaterialApp(
darkTheme: ThemeData.dark(),
themeMode: ThemeMode.system,
      home: HomePage(),

    )
  );
}
