import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
              if (direction != null) BoardPainter.handleInput(direction);
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
                    BoardPainter.handleInput(Direction.Up);
                  } else {
                    BoardPainter.handleInput(Direction.Down);
                  }
                } else {
                  if (dragUpdateDetails.delta.dx < 0) {
                    BoardPainter.handleInput(Direction.Left);
                  } else {
                    BoardPainter.handleInput(Direction.Right);
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
                  painter: BoardPainter(whatByWhat),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum Direction { Left, Right, Up, Down }

class ImportantStylesAndValues {
  static const Radius radius = Radius.circular(5);

  static const double Padding = 5;
  static const double HalfPadding = Padding / 2;

  static const double AnimationSpeed = 1;

  static const Color BackGroundColor = Color.fromRGBO(187, 173, 160, 1);
  static const Color clearTilesColor = Color.fromRGBO(205, 193, 180, 1);

  static final Paint clearTilesPaint = Paint()..color = clearTilesColor;
  static final Paint elementPaint = Paint()
    ..color = Color.fromRGBO(100, 100, 100, 1);
}

class MutableRectangle {
  double left;
  double top;
  double width;
  double height;

  MutableRectangle(this.left, this.top, this.width, this.height);

  static MovementSpeed difference(
          MutableRectangle first, MutableRectangle second) =>
      MovementSpeed(first.left - second.left, first.top - second.top);
}

class TargetMovement {
  int i;
  int k;

  TargetMovement(this.i, this.k);
}

class MovementSpeed {
  double x;
  double y;

  MovementSpeed operator /(double scaleDecrease) {
    this.x /= scaleDecrease;
    this.y /= scaleDecrease;
    return this;
  }

  MovementSpeed(this.x, this.y);
}

class BoardTile {
  MutableRectangle dimensions;

  BoardTile(this.dimensions);
}

class BoardElements {
  MutableRectangle dimensions;

  int value;
  bool moving = false;

  MutableRectangle movingDimensions = MutableRectangle(0, 0, 0, 0);
  TargetMovement targetMovement = TargetMovement(0, 0);
  MovementSpeed movementSpeed = MovementSpeed(0, 0);

  BoardElements(this.dimensions, this.value);
}

class BoardPainter extends CustomPainter {
  static final rePaint = new ChangeNotifier();

  static List<List<BoardTile>> board = [];
  static List<List<BoardElements>> elements = [];
  static Size previous = Size(0, 0);
  static Random rng = Random();
  static bool handlingMove = false;
  static Stopwatch stopWatch = Stopwatch()..start();
  static double handlingCounter = 0;

  int whatByWhat;

  BoardPainter(this.whatByWhat) : super(repaint: rePaint);

  static void handleInput(Direction direction) {
    if (handlingMove) return;
    handlingMove = true;
    switch (direction) {
      case Direction.Up:

        break;
      case Direction.Left:
        // TODO: Handle this case.
        break;
      case Direction.Right:
        // TODO: Handle this case.
        break;
      case Direction.Down:
      // TODO: Handle this case.
        break;
    }
  }

  void cleanUp() {
    board = [];
    elements = [];
    handlingMove = false;
    handlingCounter = 0;
  }

  void generateBoard(Size size) {
    final tileWidth = size.width / whatByWhat;
    final tileHeight = size.height / whatByWhat;

    for (int i = 0; i < whatByWhat; ++i) {
      board.add([]);
      elements.add([]);
      for (int k = 0; k < whatByWhat; ++k) {
        board[i].add(
          BoardTile(
            MutableRectangle(
              tileWidth * i + ImportantStylesAndValues.HalfPadding,
              tileHeight * k + ImportantStylesAndValues.HalfPadding,
              tileWidth - ImportantStylesAndValues.Padding,
              tileHeight - ImportantStylesAndValues.Padding,
            ),
          ),
        );
        elements[i].add(
          BoardElements(
            MutableRectangle(
              tileWidth * i + ImportantStylesAndValues.HalfPadding,
              tileHeight * k + ImportantStylesAndValues.HalfPadding,
              tileWidth - ImportantStylesAndValues.Padding,
              tileHeight - ImportantStylesAndValues.Padding,
            ),
            0,
          ),
        );
      }
    }
    int x = rng.nextInt(whatByWhat - 1), y = rng.nextInt(whatByWhat - 1);
    elements[x][y] = BoardElements(
      MutableRectangle(
        tileWidth * x + ImportantStylesAndValues.HalfPadding,
        tileHeight * y + ImportantStylesAndValues.HalfPadding,
        tileWidth - ImportantStylesAndValues.Padding,
        tileHeight - ImportantStylesAndValues.Padding,
      ),
      2,
    );
    x = rng.nextInt(whatByWhat - 1);
    y = rng.nextInt(whatByWhat - 1);
    while (elements[x][y].value != 0) {
      x = rng.nextInt(whatByWhat - 1);
      y = rng.nextInt(whatByWhat - 1);
    }
    elements[x][y] = BoardElements(
      MutableRectangle(
        tileWidth * x + ImportantStylesAndValues.HalfPadding,
        tileHeight * y + ImportantStylesAndValues.HalfPadding,
        tileWidth - ImportantStylesAndValues.Padding,
        tileHeight - ImportantStylesAndValues.Padding,
      ),
      2,
    );
  }

  void resizeBoard(Size newSize) {
    final tileWidth = newSize.width / whatByWhat;
    final tileHeight = newSize.height / whatByWhat;

    final scaleX = newSize.width / previous.width;
    final scaleY = newSize.height / previous.height;

    for (int i = 0; i < whatByWhat; ++i) {
      for (int k = 0; k < whatByWhat; ++k) {
        board[i][k] = BoardTile(
          MutableRectangle(
            tileWidth * i + ImportantStylesAndValues.HalfPadding,
            tileHeight * k + ImportantStylesAndValues.HalfPadding,
            tileWidth - ImportantStylesAndValues.Padding,
            tileHeight - ImportantStylesAndValues.Padding,
          ),
        );
        if (elements[i][k].value != 0) {
          elements[i][k].dimensions.top *= scaleY;
          elements[i][k].dimensions.left *= scaleX;
          elements[i][k].dimensions.width =
              tileWidth - ImportantStylesAndValues.Padding;
          elements[i][k].dimensions.height =
              tileHeight - ImportantStylesAndValues.Padding;
          elements[i][k].movingDimensions.top *= scaleY;
          elements[i][k].movingDimensions.left *= scaleX;
          elements[i][k].movingDimensions.width =
              tileWidth - ImportantStylesAndValues.Padding;
          elements[i][k].movingDimensions.height =
              tileHeight - ImportantStylesAndValues.Padding;
        }
      }
    }
  }

  void wrongSize(Size newSize) {
    if (board.isEmpty) {
      generateBoard(newSize);
    } else {
      resizeBoard(newSize);
    }

    previous = newSize;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final deltaT = stopWatch.elapsedMilliseconds / 1000;
    stopWatch.reset();

    if (previous != size) wrongSize(size);
    if (handlingMove) {
      handlingCounter += deltaT;
      if (handlingCounter > ImportantStylesAndValues.AnimationSpeed + deltaT) {
        handlingMove = false;
        handlingCounter = 0;
        for (int i = 0; i < whatByWhat; ++i) {
          for (int k = 0; k < whatByWhat; ++k) {
            elements[i][k].moving = false;
          }
        }
      }
    }

    for (int i = 0; i < whatByWhat; ++i) {
      for (int k = 0; k < whatByWhat; ++k) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              board[i][k].dimensions.left,
              board[i][k].dimensions.top,
              board[i][k].dimensions.width,
              board[i][k].dimensions.height,
            ),
            ImportantStylesAndValues.radius,
          ),
          ImportantStylesAndValues.clearTilesPaint,
        );
      }
    }

    for (int i = 0; i < whatByWhat; ++i) {
      for (int k = 0; k < whatByWhat; ++k) {
        if (elements[i][k].value == 0) continue;
        if (elements[i][k].moving) {
          elements[i][k].dimensions.left +=
              elements[i][k].movementSpeed.x * deltaT;
          elements[i][k].dimensions.top +=
              elements[i][k].movementSpeed.y * deltaT;
        }
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              elements[i][k].dimensions.left,
              elements[i][k].dimensions.top,
              elements[i][k].dimensions.width,
              elements[i][k].dimensions.height,
            ),
            ImportantStylesAndValues.radius,
          ),
          ImportantStylesAndValues.elementPaint,
        );
        TextPainter scorePainter = TextPainter(
          textDirection: TextDirection.rtl,
          text: TextSpan(
            text: elements[i][k].value.toString(),
            style: TextStyle(
              fontSize: 40,
            ),
          ),
        );
        scorePainter.layout();
        scorePainter.paint(
          canvas,
          Offset(
            elements[i][k].dimensions.left +
                elements[i][k].dimensions.width / 2 -
                scorePainter.width / 2,
            elements[i][k].dimensions.top +
                elements[i][k].dimensions.height / 2 -
                scorePainter.height / 2,
          ),
        );
      }
    }

    SchedulerBinding.instance!.scheduleFrameCallback((timeStamp) {
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      rePaint.notifyListeners();
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
