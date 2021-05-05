import 'package:flutter/material.dart';
import 'package:improved_2048/ui/game.dart';
import 'package:improved_2048/ui/highScore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HighScore.init();
  runApp(
    MaterialApp(
darkTheme: ThemeData.dark(),
themeMode: ThemeMode.system,
      home: Game(4),
    )
  );
}
