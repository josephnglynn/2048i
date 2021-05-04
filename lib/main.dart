import 'package:flutter/material.dart';
import 'package:improved_2048/ui/game.dart';
import 'package:improved_2048/ui/highScore.dart';
import 'package:improved_2048/ui/homePage.dart';

void main() async {
  await HighScore.init();
  runApp(
    MaterialApp(
      home: Game(4),
    )
  );
}
