import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  final Stopwatch stopwatch = Stopwatch()..start();

  _GameState(this.whatByWhat);

  void goBackToHomePage() {
    BoardPainter.cleanUp();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
      (route) => false,
    );
  }

  /*
  *
  *            */

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - times2Padding - 50;
    final height = MediaQuery.of(context).size.height - times2Padding - 50;
    final smaller = width > height ? height : width;

    if (!BoardPainter.dead)
      Future.delayed(Duration(seconds: 1), () => setState(() {}));

    return WillPopScope(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == 0) return;
          BoardPainter.handleInput(
              details.primaryVelocity! < 0 ? Direction.Left : Direction.Right,
              whatByWhat);
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity == 0) return;
          BoardPainter.handleInput(
              details.primaryVelocity! < 0 ? Direction.Up : Direction.Down,
              whatByWhat);
        },
        child: Scaffold(
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
                  case "Escape":
                    BoardPainter.dead = true;
                    SchedulerBinding.instance!.scheduleFrameCallback(
                      (timeStamp) => goBackToHomePage(),
                    );
                    break;
                }
                if (direction != null)
                  BoardPainter.handleInput(direction, whatByWhat);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: padding + 25,
                        right: padding + 25,
                        top: padding,
                        bottom: padding / 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("score: ${BoardPainter.points}"),
                        Text("highScore: ${HighScore.highScore}"),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: padding, right: padding),
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(ImportantValues.halfPadding),
                      decoration: BoxDecoration(
                        color:
                            Settings.boardThemeValues.getBoardBackgroundColor(),
                        borderRadius: BorderRadius.all(ImportantValues.radius),
                      ),
                      width: smaller,
                      height: smaller,
                      child: CustomPaint(
                        painter: BoardPainter(
                          whatByWhat,
                          () {
                            BoardPainter.dead = true;
                            SchedulerBinding.instance!.scheduleFrameCallback(
                              (timeStamp) => goBackToHomePage(),
                            );
                          },
                          () => setState(() {}),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(right: smaller - 60, top: padding / 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("time: ${stopwatch.elapsed.inSeconds}"),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      onWillPop: () {
        BoardPainter.dead = true;
        SchedulerBinding.instance!.scheduleFrameCallback(
          (timeStamp) => goBackToHomePage(),
        );
        return Future.value(false);
      },
    );
  }
}
