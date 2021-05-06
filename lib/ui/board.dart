import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:improved_2048/api/settings.dart';
import 'package:improved_2048/ui/types.dart';

import 'highScore.dart';

class BoardPainter extends CustomPainter {
  static final rePaint = new ChangeNotifier();

  static List<List<BoardTile>> board = [];
  static List<List<BoardElement>> elements = [];
  static Size previous = Size(0, 0);
  static Random rng = Random();
  static bool handlingMove = false;
  static double handlingCounter = 0;
  static bool handlingNewTile = false;
  static double handlingNewTileCounter = 0;
  static Stopwatch stopWatch = Stopwatch()..start();
  static int points = 0;
  static bool hasSetScore = false;
  static bool dead = false;
  static int largestNumberLength = 1;

  int whatByWhat;
  final Function navigateOnDeath;
  final Function setScore;

  BoardPainter(this.whatByWhat, this.navigateOnDeath, this.setScore)
      : super(repaint: rePaint) {
    ImportantValues.updateRadius(whatByWhat);
  }

  static List<BoardElement> doStuff(List<BoardElement> row) {
    int originalLength = row.length;
    row = row.where((val) => val.value != 0).toList();
    for (int i = 0; i < row.length - 1; i++) {
      int firstNum = row[i].value;
      int secondNum = row[i + 1].value;
      if (firstNum == secondNum) {
        row[i].value = firstNum + secondNum;
        row[i].animateElement = true;
        if (row[i].value.toString().length > largestNumberLength) {
          largestNumberLength = row[i].value.toString().length;
        }
        row[i + 1].value = 0;
        points += row[i].value;
        hasSetScore = false;
      }
    }
    row = row.where((val) => val.value != 0).toList();
    int zeroesToInsert = originalLength - row.length;
    row.addAll(List.generate(
        zeroesToInsert, (index) => BoardElement(0, false, false)));
    return row;
  }

  static List<List<BoardElement>> inverseList(
      List<List<BoardElement>> listToBeInverted) {
    List<List<BoardElement>> invertedList = [];
    for (int i = 0; i < listToBeInverted.length; ++i) {
      invertedList.add(listToBeInverted.map((e) => e[i]).toList());
    }
    return invertedList;
  }

  static void handleInput(Direction direction, int whatByWhat) {
    if (handlingMove) return;
    handlingMove = true;

    int totalValueBefore = 0;
    for (int i = 0; i < elements.length; ++i) {
      for (int k = 0; k < elements.length; ++k) {
        totalValueBefore += (k + i) * elements[i][k].value;
      }
    }

    switch (direction) {
      case Direction.Up:
        elements = elements.map((e) => doStuff(e)).toList();
        break;
      case Direction.Left:
        elements =
            inverseList(inverseList(elements).map((e) => doStuff(e)).toList());
        break;
      case Direction.Right:
        elements = inverseList(inverseList(elements)
            .map((e) => doStuff(e.reversed.toList()).reversed.toList())
            .toList());
        break;
      case Direction.Down:
        elements = elements
            .map((e) => doStuff(e.reversed.toList()).reversed.toList())
            .toList();
        break;
    }

    int totalValueAfterwards = 0;
    for (int i = 0; i < elements.length; ++i) {
      for (int k = 0; k < elements.length; ++k) {
        totalValueAfterwards += (k + i) * elements[i][k].value;
      }
    }

    if (totalValueBefore != totalValueAfterwards) {
      addNewElement();
      handlingNewTile = true;
      handlingMove = true;
    }

    if (haveTheyMadeAMistake()) {
      dead = true;
    }
  }

  static bool haveTheyMadeAMistake() {
    for (int i = 0; i < elements.length; ++i) {
      for (int k = 0; k < elements[i].length; ++k) {
        if (elements[i][k].value == 0) {
          return false;
        }
        if (
            k + 1 < elements.length  && elements[i][k].value == elements[i][k + 1].value) return false;
        if (i + 1 < elements.length &&
            elements[i + 1][k].value == elements[i][k].value) return false;
      }
    }
    return true;
  }

  static void addNewElement() {
    List<List<int>> possiblePlaces = [];
    for (int i = 0; i < elements.length; ++i) {
      for (int k = 0; k < elements[i].length; ++k) {
        if (elements[i][k].value == 0) {
          possiblePlaces.add([i, k]);
        }
      }
    }

    if (possiblePlaces.length == 0) return;

    int index =
        possiblePlaces.length == 1 ? 0 : rng.nextInt(possiblePlaces.length - 1);
    elements[possiblePlaces[index][0]][possiblePlaces[index][1]] =
        BoardElement(2, true, true);
    elements[possiblePlaces[index][0]][possiblePlaces[index][1]]
        .previousPosition = PreviousPosition(
      possiblePlaces[index][0],
      possiblePlaces[index][1],
    );
  }

  static void cleanUp() {
    board = [];
    elements = [];
    previous = Size(0, 0);
    rng = Random();
    handlingMove = false;
    handlingCounter = 0;
    handlingNewTile = false;
    handlingNewTileCounter = 0;
    stopWatch = Stopwatch()..start();
    points = 0;
    hasSetScore = false;
    dead = false;
    largestNumberLength = 1;
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
              tileWidth * i + ImportantValues.HalfPadding,
              tileHeight * k + ImportantValues.HalfPadding,
              tileWidth - ImportantValues.Padding,
              tileHeight - ImportantValues.Padding,
            ),
          ),
        );
        elements[i].add(BoardElement(0, false, false));
        elements[i][k].previousPosition = PreviousPosition(i, k);
      }
    }

    addNewElement();
    addNewElement();
    handlingNewTile = true;
  }

  void resizeBoard(Size newSize) {
    final tileWidth = newSize.width / whatByWhat;
    final tileHeight = newSize.height / whatByWhat;

    for (int i = 0; i < whatByWhat; ++i) {
      for (int k = 0; k < whatByWhat; ++k) {
        board[i][k] = BoardTile(
          MutableRectangle(
            tileWidth * i + ImportantValues.HalfPadding,
            tileHeight * k + ImportantValues.HalfPadding,
            tileWidth - ImportantValues.Padding,
            tileHeight - ImportantValues.Padding,
          ),
        );
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

    final tileWidth = size.width / whatByWhat;
    final tileHeight = size.height / whatByWhat;
    final fontSize = tileHeight * Settings.fontSizeScale / largestNumberLength;

    if (handlingMove) {
      handlingCounter += deltaT;
      if (dead)
        SchedulerBinding.instance!.scheduleFrameCallback((timeStamp) {
          cleanUp();
          navigateOnDeath();
        });
      if (handlingCounter > ImportantValues.AnimationLength) {
        handlingMove = false;
        handlingCounter = 0;
        for (int i = 0; i < elements.length; ++i) {
          for (int k = 0; k < elements.length; ++k) {
            elements[i][k].animateElement = false;
            elements[i][k].previousPosition = PreviousPosition(i, k);
          }
        }
      }
    }

    if (handlingNewTile) {
      handlingNewTileCounter += deltaT;
      if (handlingNewTileCounter > ImportantValues.NewTileAnimationLength) {
        handlingNewTile = false;
        handlingNewTileCounter = 0;
        for (int i = 0; i < elements.length; ++i) {
          for (int k = 0; k < elements.length; ++k) {
            elements[i][k].animateElement = false;
          }
        }
      }
    }

    if (!hasSetScore) {
      HighScore.setHighScore(points, whatByWhat);
      SchedulerBinding.instance!.scheduleFrameCallback(
        (timeStamp) => setScore(),
      );
      hasSetScore = true;
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
            ImportantValues.radius,
          ),
          Settings.boardThemeValues.getClearTilePaint(),
        );
        if (elements[i][k].value != 0) {
          if (elements[i][k].animateElement) {
            final ratio =
                handlingNewTileCounter / ImportantValues.NewTileAnimationLength;
            if (elements[i][k].isNewTile &&
                elements[i][k].previousPosition!.i == i &&
                elements[i][k].previousPosition!.k == k) {
              //THIS MEANS IT SHOULD EXPAND FROM TINY TO BIG
              Rect rect = Rect.fromLTWH(
                tileWidth * i +
                    ImportantValues.HalfPadding +
                    tileWidth * 0.5 -
                    (ratio * tileWidth * 0.5),
                tileHeight * k +
                    ImportantValues.HalfPadding +
                    tileHeight * 0.5 -
                    (ratio * tileHeight * 0.5),
                (tileWidth - ImportantValues.Padding) * ratio,
                (tileHeight - ImportantValues.Padding) * ratio,
              );
              canvas.drawRRect(
                RRect.fromRectAndRadius(
                  rect,
                  ImportantValues.radius,
                ),
                Paint()
                  ..color = Settings.boardThemeValues
                          .getSquareColors()[elements[i][k].value] ??
                      Colors.red,
              );
              TextPainter scorePainter = TextPainter(
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  text: elements[i][k].value.toString(),
                  style: TextStyle(
                    fontSize: fontSize * ratio,
                  ),
                ),
              );
              scorePainter.layout();
              scorePainter.paint(
                canvas,
                Offset(
                  rect.left + rect.width / 2 - scorePainter.width / 2,
                  rect.top + rect.height / 2 - scorePainter.height / 2,
                ),
              );
              continue;
            }
            Rect rect = Rect.fromLTWH(
              tileWidth * i + ImportantValues.HalfPadding,
              tileHeight * k + ImportantValues.HalfPadding,
              tileWidth - ImportantValues.Padding,
              tileHeight - ImportantValues.Padding,
            );
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                rect,
                ImportantValues.radius,
              ),
              Paint()
                ..color = Settings.boardThemeValues
                        .getSquareColors()[elements[i][k].value] ??
                    Colors.red,
            );
            TextPainter scorePainter = TextPainter(
              textDirection: TextDirection.rtl,
              text: TextSpan(
                text: elements[i][k].value.toString(),
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
            );
            scorePainter.layout();
            scorePainter.paint(
              canvas,
              Offset(
                rect.left + rect.width / 2 - scorePainter.width / 2,
                rect.top + rect.height / 2 - scorePainter.height / 2,
              ),
            );

            continue;
          }
          Rect rect = Rect.fromLTWH(
            tileWidth * i + ImportantValues.HalfPadding,
            tileHeight * k + ImportantValues.HalfPadding,
            tileWidth - ImportantValues.Padding,
            tileHeight - ImportantValues.Padding,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              rect,
              ImportantValues.radius,
            ),
            Paint()
              ..color = Settings.boardThemeValues
                      .getSquareColors()[elements[i][k].value] ??
                  Colors.red,
          );
          TextPainter scorePainter = TextPainter(
            textDirection: TextDirection.rtl,
            text: TextSpan(
              text: elements[i][k].value.toString(),
              style: TextStyle(
                fontSize: fontSize,
              ),
            ),
          );
          scorePainter.layout();
          scorePainter.paint(
            canvas,
            Offset(
              rect.left + rect.width / 2 - scorePainter.width / 2,
              rect.top + rect.height / 2 - scorePainter.height / 2,
            ),
          );
        }
      }
    }

    if (!dead) {
      SchedulerBinding.instance!.scheduleFrameCallback((timeStamp) {
        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        rePaint.notifyListeners();
      });
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
