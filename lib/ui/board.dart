import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:improved_2048/api/game_state.dart';

class BoardPainter extends CustomPainter {
  final GameState gameState;

  BoardPainter(this.gameState);

  @override
  void paint(Canvas canvas, Size size) {
    gameState.update(size);
    gameState.draw(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
