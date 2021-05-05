import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:improved_2048/api/settings.dart';
import 'package:improved_2048/ui/highScore.dart';
import 'package:improved_2048/ui/homePage.dart';
import 'package:improved_2048/ui/types.dart';

import 'board.dart';

class Game extends StatefulWidget {
  final int whatByWhat;

  Game(this.whatByWhat);

  @override
  _GameState createState() => _GameState(whatByWhat);
}

class _GameState extends State<Game> {
  static const double padding = 40;
  static const double times2Padding = padding * 2;
  
  final int whatByWhat;
  _GameState(this.whatByWhat);


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - times2Padding;
    final height = MediaQuery.of(context).size.height - times2Padding;
    final smaller = width > height ? height : width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "2048 -- Points: ${BoardPainter.points} -- HighScore: ${HighScore.highScore}",
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (value) {
            Direction? direction;
            switch (value.data.logicalKey.keyLabel) {
              case "A":
                direction = Direction.Left;
                break;
              case "W":
                direction = Direction.Up;
                break;
              case "D":
                direction = Direction.Right;
                break;
              case "S":
                direction = Direction.Down;
                break;
              case "Arrow Left":
                direction = Direction.Left;
                break;
              case "Arrow Up":
                direction = Direction.Up;
                break;
              case "Arrow Right":
                direction = Direction.Right;
                break;
              case "Arrow Down":
                direction = Direction.Down;
                break;
            }
            if (direction != null)
              BoardPainter.handleInput(direction, whatByWhat);
          },
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity == 0) return;
              BoardPainter.handleInput(
                  details.primaryVelocity! < 0
                      ? Direction.Left
                      : Direction.Right,
                  whatByWhat);
            },
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity == 0) return;
              BoardPainter.handleInput(
                  details.primaryVelocity! < 0 ? Direction.Up : Direction.Down,
                  whatByWhat);
            },
            child: Container(
              padding: EdgeInsets.all(padding),
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.all(ImportantValues.HalfPadding),
                decoration: BoxDecoration(
                  color: Settings.boardThemeValues.getBoardBackgroundColor(),
                  borderRadius:
                      BorderRadius.all(ImportantValues.radius),
                ),
                width: smaller,
                height: smaller,
                  child:  CustomPaint(
                    painter: BoardPainter(
                      whatByWhat,
                          () {
                        BoardPainter.cleanUp();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                              (route) => false,
                        );
                      },
                          () => setState(() {}),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }
}
