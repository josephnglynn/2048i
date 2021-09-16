import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:improved_2048/api/game_state.dart';
import 'package:improved_2048/api/settings.dart';
import 'package:improved_2048/api/high_score.dart';
import 'package:improved_2048/ui/home_page.dart';
import 'package:improved_2048/types/types.dart';
import 'board.dart';

class Game extends StatefulWidget {
  final int whatByWhat;

  Game(this.whatByWhat);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> with SingleTickerProviderStateMixin {
  static const double padding = 20;
  static const double times2Padding = padding * 2;
  late GameState gameState;
  late AnimationController controller;
  late Animation<double> animation;
  Stopwatch? stopwatch = Stopwatch()..start();

  @override
  void initState() {
    gameState = GameState(
      widget.whatByWhat,
      setState,
          () {
        controller.value = 0;
        controller.animateTo(1, duration: gameState.animationDuration);
        controller.forward();
      },
    );

    controller = AnimationController(
      vsync: this,
      duration: gameState.animationDuration,
    );

    animation = Tween<double>(begin: 0, end: 1).animate(controller);

    controller.addListener(() {
      gameState.animationValue = controller.value;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    stopwatch!.stop();
    stopwatch = null;
    super.dispose();
  }

  Future restart() async {
    await gameState.clearCache();
    setState(() {
      gameState = GameState(
        widget.whatByWhat,
        setState,
        () {
          controller.value = 0;
          controller.animateTo(1, duration: gameState.animationDuration);
          controller.forward();
        },
      );
    });
  }

  void onInput(Direction direction, int boardSize) {
    gameState.handleInput(
      direction,
      boardSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - times2Padding;
    final height = MediaQuery.of(context).size.height - times2Padding - 50 - 50;
    final smaller = width > height ? height : width;

    return WillPopScope(
      child: GestureDetector(
        onHorizontalDragEnd: (details) async {
          if (details.primaryVelocity == 0) return;
          onInput(
            details.primaryVelocity! < 0 ? Direction.Left : Direction.Right,
            widget.whatByWhat,
          );
        },
        onVerticalDragEnd: (details) async {
          if (details.primaryVelocity == 0) return;
          onInput(
            details.primaryVelocity! < 0 ? Direction.Up : Direction.Down,
            widget.whatByWhat,
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
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(widget.whatByWhat),
                        ),
                        (route) => false);
                    break;
                }
                if (direction != null)
                  onInput(
                    direction,
                    widget.whatByWhat,
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
                        Text("score: ${gameState.points}"),
                        Text("highScore: ${HighScore.get().highScore}"),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: padding, right: padding),
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(Settings.get().halfPadding),
                      decoration: BoxDecoration(
                        color: Settings.get()
                            .boardThemeValues
                            .getSquareColors()[0],
                        borderRadius: BorderRadius.all(Settings.get().radius),
                      ),
                      width: smaller,
                      height: smaller,
                      child: CustomPaint(
                        painter: BoardPainter(
                          gameState,
                        ),
                        child: gameState.dead
                            ? Container(
                                alignment: Alignment.center,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: Duration(seconds: 3),
                                  builder: (context, value, child) =>
                                      BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 5 * value,
                                      sigmaY: 5 * value,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Game Over",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1!
                                                    .color!
                                                    .withOpacity(value),
                                                fontSize: 40),
                                          ),
                                          TextButton(
                                            onPressed: () async => restart(),
                                            child: Text("Restart?"),
                                            style: TextButton.styleFrom(
                                              textStyle: TextStyle(
                                                color: Colors.blueAccent
                                                    .withOpacity(value),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
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
                          Settings.get().showMovesInsteadOfTime
                              ? "moves: ${gameState.moves}"
                              : "time: ${stopwatch!.elapsed.inSeconds}",
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => gameState.undoMove(),
                              padding: EdgeInsets.zero,
                              alignment: Alignment.topCenter,
                              icon: Icon(
                                Icons.refresh,
                              ),
                            ),
                            IconButton(
                              onPressed: () async => await restart(),
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
        return Future.value(false);
      },
    );
  }
}
