import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:improved_2048/ui/types.dart';


Map<int, Color> SquareColors = {
  0: Colors.orange.shade100,
  2: Colors.orange.shade200,
  4: Colors.orange.shade300,
  8: Colors.orange.shade400,
  16: Colors.orange.shade500,
  32: Colors.orange.shade600,
  64: Colors.orange.shade600,
  128: Colors.orange.shade700,
  256: Colors.orange.shade700,
  512: Colors.orange.shade800,
  1024: Colors.orange.shade800,
  2048: Colors.orange.shade900,
};


class BoardPainter extends CustomPainter {
  static final rePaint = new ChangeNotifier();

  static List<List<BoardTile>> board = [];
  static List<List<int>> elements = [];
  static Size previous = Size(0, 0);
  static Random rng = Random();
  static bool handlingMove = false;
  static Stopwatch stopWatch = Stopwatch()..start();
  static double handlingCounter = 0;

  int whatByWhat;

  BoardPainter(this.whatByWhat) : super(repaint: rePaint);

  static List<int> doStuff(List<int> row) {
    int originalLength = row.length;
    row = row.where((val) => val != 0).toList();
    for (int i = 0; i < row.length - 1; i++) {
      int firstNum = row[i];
      int secondNum = row[i + 1];
      if (firstNum == secondNum) {
        row[i] = firstNum + secondNum;
        row[i + 1] = 0;
      }
    }
    row = row.where((val) => val != 0).toList();
    int zeroesToInsert = originalLength - row.length;
    row.addAll(List.generate(zeroesToInsert, (index) => 0));
    return row;
  }

  static List<List<int>> inverseList(List<List<int>> listToBeInverted) {
    List<List<int>> invertedList = [];
    for (int i = 0; i < listToBeInverted.length; ++i) {
      invertedList.add(listToBeInverted.map((e) => e[i]).toList());
    }
    return invertedList;
  }

  static void handleInput(Direction direction, int whatByWhat) {
    if (handlingMove) return;
    handlingMove = true;

    switch (direction) {
      case Direction.Up:
        elements = elements.map((e) => doStuff(e)).toList();
        addNewElement();
        break;
      case Direction.Left:
        elements = inverseList(inverseList(elements).map((e) => doStuff(e)).toList());
        addNewElement();
        break;
      case Direction.Right:
        elements = inverseList(inverseList(elements).map((e) => doStuff(e.reversed.toList()).reversed.toList()).toList());
        addNewElement();
        break;
      case Direction.Down:
        elements = elements.map((e) => doStuff(e.reversed.toList()).reversed.toList()).toList();
        addNewElement();
        break;
    }
    handlingMove = false;
  }

  static void addNewElement() {
    List<List<int>> possiblePlaces = [];
    for (int i = 0; i < elements.length; ++i) {
      for (int k = 0; k < elements[i].length; ++k) {
        if (elements[i][k] == 0) {
          possiblePlaces.add([i, k]);
        }
      }
    }

    if (possiblePlaces.length == 0) return;

    int index = possiblePlaces.length == 1 ? 0 : rng.nextInt(possiblePlaces.length - 1);
    elements[possiblePlaces[index][0]][possiblePlaces[index][1]] = 2;
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
        elements[i].add(0);
      }
    }
    addNewElement();
    addNewElement();

  }

  void resizeBoard(Size newSize) {
    final tileWidth = newSize.width / whatByWhat;
    final tileHeight = newSize.height / whatByWhat;

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
        if (elements[i][k] != 0) {
          Rect rect = Rect.fromLTWH(
            tileWidth * i + ImportantStylesAndValues.HalfPadding,
            tileHeight * k + ImportantStylesAndValues.HalfPadding,
            tileWidth - ImportantStylesAndValues.Padding,
            tileHeight - ImportantStylesAndValues.Padding,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              rect,
              ImportantStylesAndValues.radius,
            ),
            Paint()..color = SquareColors[elements[i][k]] ?? Colors.red,
          );
          TextPainter scorePainter = TextPainter(
            textDirection: TextDirection.rtl,
            text: TextSpan(
              text: elements[i][k].toString(),
              style: TextStyle(
                fontSize: 40,
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

    SchedulerBinding.instance!.scheduleFrameCallback((timeStamp) {
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      rePaint.notifyListeners();
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
