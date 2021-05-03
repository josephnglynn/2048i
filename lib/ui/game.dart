import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:improved_2048/ui/DeathPage.dart';
import 'package:improved_2048/ui/types.dart';

import 'board.dart';

class Game extends StatefulWidget {
  final int whatByWhat;

  Game(this.whatByWhat);

  @override
  _GameState createState() => _GameState(whatByWhat);
}

class _GameState extends State<Game> {
  final int whatByWhat;

  _GameState(this.whatByWhat);

  List<List<int>> board = [];

  @override
  void initState() {
    for (int i = 0; i < whatByWhat; ++i) {
      board.add([]);
      for (int k = 0; k < whatByWhat; ++k) {
        board[i].add(0);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "2048",
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(80),
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
              onPanUpdate: (DragUpdateDetails dragUpdateDetails) {
                final changeInX;
                final changeInY;

                if (dragUpdateDetails.delta.dx < 0) {
                  changeInX = dragUpdateDetails.delta.dx * -1;
                } else {
                  changeInX = dragUpdateDetails.delta.dx;
                }

                if (dragUpdateDetails.delta.dy < 0) {
                  changeInY = dragUpdateDetails.delta.dy * -1;
                } else {
                  changeInY = dragUpdateDetails.delta.dy;
                }

                if (changeInY > changeInX) {
                  if (dragUpdateDetails.delta.dy < 0) {
                    BoardPainter.handleInput(Direction.Up, whatByWhat);
                  } else {
                    BoardPainter.handleInput(Direction.Down, whatByWhat);
                  }
                } else {
                  if (dragUpdateDetails.delta.dx < 0) {
                    BoardPainter.handleInput(Direction.Left, whatByWhat);
                  } else {
                    BoardPainter.handleInput(Direction.Right, whatByWhat);
                  }
                }
              },
              child: Container(
                padding: EdgeInsets.all(ImportantStylesAndValues.HalfPadding),
                decoration: BoxDecoration(
                  color: ImportantStylesAndValues.BackGroundColor,
                  borderRadius:
                      BorderRadius.all(ImportantStylesAndValues.radius),
                ),
                child: CustomPaint(
                  painter: BoardPainter(whatByWhat, ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context) => DeathPage(),))),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

