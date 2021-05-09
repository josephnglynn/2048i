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
  static const double padding = 20;
  static const double times2Padding = padding * 2;

  final int whatByWhat;
  Stopwatch? stopwatch = Stopwatch()..start();

  _GameState(this.whatByWhat);

  void goBackToHomePage() {
    SchedulerBinding.instance!.scheduleFrameCallback((timeStamp) {
      BoardPainter.cleanUp();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HomePage(whatByWhat),
        ),
        (route) => false,
      );
    });
  }

  void reset() => SchedulerBinding.instance!.scheduleFrameCallback((timeStamp) async {
        BoardPainter.cleanUp();
        await BoardPainter.clearCache(whatByWhat);
      });

  @override
  void dispose() {
    stopwatch!.stop();
    stopwatch = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - times2Padding;
    final height = MediaQuery.of(context).size.height - times2Padding - 50 - 50;
    final smaller = width > height ? height : width;

    if (!BoardPainter.dead)
      Future.delayed(Duration(seconds: 1), () => setState(() {}));

    return WillPopScope(
      child: GestureDetector(
        onHorizontalDragEnd: (details) async {
          if (details.primaryVelocity == 0) return;
          await BoardPainter.handleInput(
            details.primaryVelocity! < 0 ? Direction.Left : Direction.Right,
            whatByWhat,
          );
        },
        onVerticalDragEnd: (details) async {
          if (details.primaryVelocity == 0) return;
          await BoardPainter.handleInput(
            details.primaryVelocity! < 0 ? Direction.Up : Direction.Down,
            whatByWhat,
          );
        },
        child: Scaffold(
          body: SafeArea(
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (value) async {
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
                  await BoardPainter.handleInput(
                    direction,
                    whatByWhat,
                  );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: padding,
                      right: padding,
                      top: padding,
                      bottom: padding / 2,
                    ),
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
                        color: Settings.boardThemeValues.getSquareColors()[0],
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
                        child: BoardPainter.showDeath
                            ? Container(
                                alignment: Alignment.center,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: Duration(seconds: 3),
                                  builder: (context, value, child) => Text(
                                    "Game Over",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .color!
                                            .withOpacity(value),
                                        fontSize: 40),
                                  ),
                                ),
                              )
                            : Container(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: padding,
                      right: padding,
                      top: padding / 2,
                      bottom: padding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Settings.showMovesInsteadOfTime
                              ? "moves: ${BoardPainter.moves}"
                              : "time: ${stopwatch!.elapsed.inSeconds}",
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => SchedulerBinding.instance!
                                  .scheduleFrameCallback(
                                (timeStamp) => BoardPainter.undoMove(),
                              ),
                              padding: EdgeInsets.zero,
                              alignment: Alignment.topCenter,
                              icon: Icon(
                                Icons.refresh,
                              ),
                            ),
                            IconButton(
                              onPressed: () => SchedulerBinding.instance!
                                  .scheduleFrameCallback(
                                (timeStamp) => reset(),
                              ),
                              padding: EdgeInsets.zero,
                              alignment: Alignment.topCenter,
                              icon: Icon(
                                Icons.autorenew,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
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
