import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:improved_2048/api/settings.dart';
import 'package:improved_2048/ui/types.dart';
import 'highScore.dart';

class BoardPainter extends CustomPainter {
  static List<List<BoardTile>> _board = [];
  static List<List<BoardElement>> _elements = [];
  static List<List<BoardElement>> _undoElements = [];
  static Random _rng = Random();
  static Size _previous = Size(0, 0);
  static int moves = 0;
  static int points = 0;
  static int _largestNumberLength = 1;
  static double _handlingCounter = 0;
  static double _handlingNewTileCounter = 0;
  static bool dead = false;
  static bool _undo = false;
  static bool showDeath = false;
  static bool _hasSetScore = false;
  static bool _handlingNewTile = false;
  static bool _dealingWithDeath = false;
  static bool _handlingMoveOfTiles = false;
  static Stopwatch _stopWatch = Stopwatch()..start();

  static final _rePaint = new ChangeNotifier();

  final Function navigateOnDeath;
  final Function setStuffOnParent;

  int whatByWhat;

  BoardPainter(this.whatByWhat, this.navigateOnDeath, this.setStuffOnParent)
      : super(repaint: _rePaint) {
    ImportantValues.updateRadius(whatByWhat);
    ImportantValues.updatePadding(whatByWhat);
  }

  static Future<List<List<BoardElement>>?> _checkCache(int whatByWhat) async {
    var integers = Settings.storage.read("board$whatByWhat") ?? [];
    if (integers.isEmpty) return null;
    List<List<BoardElement>> boardElements = [];
    for (int i = 0; i < integers.length; ++i) {
      boardElements.add([]);
      for (int k = 0; k < integers[i].length; ++k) {
        int length = integers[i][k].toString().length;
        if (length > _largestNumberLength) {
          _largestNumberLength = length;
        }
        boardElements[i].add(
          BoardElement(
            integers[i][k],
            false,
            false,
            false,
          ),
        );
      }
    }
    points = Settings.storage.read("points$whatByWhat");
    return boardElements;
  }

  static Future saveToCache(int whatByWhat) async {
    List<List<int>> integers = [];
    for (int i = 0; i < _elements.length; ++i) {
      integers.add([]);
      for (int k = 0; k < _elements[i].length; ++k) {
        integers[i].add(_elements[i][k].value);
      }
    }
    Settings.storage.write("board$whatByWhat", integers);
    Settings.storage.write("points$whatByWhat", points);
  }

  static Future clearCache(int whatByWhat) async {
    await Settings.storage.remove("board$whatByWhat");
    await Settings.storage.remove("points$whatByWhat");
  }

  static void undoMove() => _undo = true;

  void _undoMove() {
    _elements = [];
    for (int i = 0; i < _undoElements.length; ++i) {
      _elements.add([]);
      for (int k = 0; k < _undoElements.length; ++k) {
        _elements[i].add(
          BoardElement(
            _undoElements[i][k].value,
            _undoElements[i][k].animateElement,
            _undoElements[i][k].isNewTile,
            _undoElements[i][k].isMerged,
          ),
        );
      }
    }
    showDeath = false;
    SchedulerBinding.instance!.scheduleFrameCallback(
      (timeStamp) => setStuffOnParent(),
    );
  }

  static List<BoardElement> _doStuff(List<BoardElement> row) {
    int originalLength = row.length;
    row = row.where((val) => val.value != 0).toList();
    for (int i = 0; i < row.length - 1; i++) {
      int firstNum = row[i].value;
      int secondNum = row[i + 1].value;
      if (firstNum == secondNum) {
        row[i].value = firstNum + secondNum;
        row[i].animateElement = true;
        row[i].isMerged = true;
        if (row[i].value.toString().length > _largestNumberLength) {
          _largestNumberLength = row[i].value.toString().length;
        }
        row[i + 1].value = 0;
        points += row[i].value;
        _hasSetScore = false;
      }
    }
    row = row.where((val) => val.value != 0).toList();
    int zeroesToInsert = originalLength - row.length;
    row.addAll(
      List.generate(
        zeroesToInsert,
        (index) => BoardElement(
          0,
          false,
          false,
          false,
        ),
      ),
    );
    return row;
  }

  static List<List<BoardElement>> _inverseList(
      List<List<BoardElement>> listToBeInverted) {
    List<List<BoardElement>> invertedList = [];
    for (int i = 0; i < listToBeInverted.length; ++i) {
      invertedList.add(listToBeInverted.map((e) => e[i]).toList());
    }
    return invertedList;
  }

  static Future handleInput(Direction direction, int whatByWhat) async {
    if (_handlingMoveOfTiles || showDeath || _handlingNewTile) return;
    _handlingMoveOfTiles = true;

    moves++;

    int totalValueBefore = 0;
    _undoElements = [];

    for (int i = 0; i < _elements.length; ++i) {
      _undoElements.add([]);
      for (int k = 0; k < _elements.length; ++k) {
        totalValueBefore += (k + i) * _elements[i][k].value;
        _undoElements[i].add(
          BoardElement(
            _elements[i][k].value,
            _elements[i][k].animateElement,
            _elements[i][k].isNewTile,
            _elements[i][k].isMerged,
          ),
        );
      }
    }

    switch (direction) {
      case Direction.Up:
        _elements = _elements.map((e) => _doStuff(e)).toList();
        break;
      case Direction.Left:
        _elements = _inverseList(
            _inverseList(_elements).map((e) => _doStuff(e)).toList());
        break;
      case Direction.Right:
        _elements = _inverseList(_inverseList(_elements)
            .map((e) => _doStuff(e.reversed.toList()).reversed.toList())
            .toList());
        break;
      case Direction.Down:
        _elements = _elements
            .map((e) => _doStuff(e.reversed.toList()).reversed.toList())
            .toList();
        break;
    }

    int totalValueAfterwards = 0;
    for (int i = 0; i < _elements.length; ++i) {
      for (int k = 0; k < _elements.length; ++k) {
        totalValueAfterwards += (k + i) * _elements[i][k].value;
        if (_elements[i][k].previousPosition == null) continue;
        if (_elements[i][k].previousPosition!.i != i ||
            _elements[i][k].previousPosition!.k != k) {
          _elements[i][k].animateElement = true;
        }
      }
    }

    if (totalValueBefore != totalValueAfterwards) {
      _addNewElement();
      _handlingMoveOfTiles = true;
    }

    if (_haveTheyMadeAMistake()) {
      showDeath = true;
    }

    await saveToCache(whatByWhat);
  }

  static bool _haveTheyMadeAMistake() {
    for (int i = 0; i < _elements.length; ++i) {
      for (int k = 0; k < _elements[i].length; ++k) {
        if (_elements[i][k].value == 0) {
          return false;
        }
        if (k + 1 < _elements.length &&
            _elements[i][k].value == _elements[i][k + 1].value) return false;
        if (i + 1 < _elements.length &&
            _elements[i + 1][k].value == _elements[i][k].value) return false;
      }
    }
    return true;
  }

  static void _addNewElement() {
    List<List<int>> possiblePlaces = [];
    for (int i = 0; i < _elements.length; ++i) {
      for (int k = 0; k < _elements[i].length; ++k) {
        if (_elements[i][k].value == 0) {
          possiblePlaces.add([i, k]);
        }
      }
    }

    if (possiblePlaces.length == 0) return;

    int index = possiblePlaces.length == 1
        ? 0
        : _rng.nextInt(possiblePlaces.length - 1);
    _elements[possiblePlaces[index][0]][possiblePlaces[index][1]] =
        BoardElement(2, true, true, false);
    _elements[possiblePlaces[index][0]][possiblePlaces[index][1]]
        .previousPosition = Position(
      possiblePlaces[index][0],
      possiblePlaces[index][1],
    );
  }

  static void cleanUp() {
    _board = [];
    _elements = [];
    _previous = Size(0, 0);
    _rng = Random();
    _stopWatch.reset();
    _handlingCounter = 0;
    _hasSetScore = false;
    _handlingNewTile = false;
    _dealingWithDeath = false;
    _handlingMoveOfTiles = false;
    _largestNumberLength = 1;
    _handlingNewTileCounter = 0;

    moves = 0;
    points = 0;
    dead = false;
    showDeath = false;
  }

  void _generateBoard(Size size) {
    final tileWidth = size.width / whatByWhat;
    final tileHeight = size.height / whatByWhat;

    _checkCache(whatByWhat).then((value) {
      if (value != null) {
        SchedulerBinding.instance!.scheduleFrameCallback((timeStamp) {
          _elements = value;
        });
      }
    });

    for (int i = 0; i < whatByWhat; ++i) {
      _board.add([]);
      _elements.add([]);
      for (int k = 0; k < whatByWhat; ++k) {
        _board[i].add(
          BoardTile(
            MutableRectangle(
              tileWidth * i + ImportantValues.halfPadding,
              tileHeight * k + ImportantValues.halfPadding,
              tileWidth - ImportantValues.padding,
              tileHeight - ImportantValues.padding,
            ),
          ),
        );
        _elements[i].add(
          BoardElement(
            0,
            false,
            false,
            false,
          ),
        );
        _elements[i][k].previousPosition = Position(i, k);
      }
    }

    _addNewElement();
    _addNewElement();
    _handlingNewTile = true;
  }

  void _resizeBoard(Size newSize) {
    final tileWidth = newSize.width / whatByWhat;
    final tileHeight = newSize.height / whatByWhat;

    for (int i = 0; i < whatByWhat; ++i) {
      for (int k = 0; k < whatByWhat; ++k) {
        _board[i][k] = BoardTile(
          MutableRectangle(
            tileWidth * i + ImportantValues.halfPadding,
            tileHeight * k + ImportantValues.halfPadding,
            tileWidth - ImportantValues.padding,
            tileHeight - ImportantValues.padding,
          ),
        );
      }
    }
  }

  void _wrongSize(Size newSize) {
    if (_board.isEmpty) {
      _generateBoard(newSize);
    } else {
      _resizeBoard(newSize);
    }

    _previous = newSize;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final deltaT = _stopWatch.elapsedMilliseconds / 1000;
    _stopWatch.reset();

    if (_previous != size) _wrongSize(size);

    if (dead) {
      if (!_dealingWithDeath) {
        _dealingWithDeath = true;
        SchedulerBinding.instance!.scheduleFrameCallback((timeStamp) async {
          navigateOnDeath();
        });
      }
      return;
    }

    if (_undo) {
      _undo = false;
      _undoMove();
    }

    final tileWidth = size.width / whatByWhat;
    final tileHeight = size.height / whatByWhat;
    final fontSize = tileHeight * Settings.fontSizeScale / _largestNumberLength;

    if (_handlingMoveOfTiles) {
      _handlingCounter += deltaT;
      if (_handlingCounter > ImportantValues.animationLength) {
        _handlingMoveOfTiles = false;
        _handlingCounter = 0;
        for (int i = 0; i < _elements.length; ++i) {
          for (int k = 0; k < _elements.length; ++k) {
            _elements[i][k].previousPosition = Position(i, k);
            _elements[i][k].isMerged = false;
          }
        }
        _handlingNewTile = true;
      }
    }

    if (_handlingNewTile) {
      _handlingNewTileCounter += deltaT;
      if (_handlingNewTileCounter > ImportantValues.newTileAnimationLength) {
        _handlingNewTile = false;
        _handlingNewTileCounter = 0;

        for (int i = 0; i < _elements.length; ++i) {
          for (int k = 0; k < _elements.length; ++k) {
            _elements[i][k].animateElement = false;
            _elements[i][k].isNewTile = false;
          }
        }
      }
    }

    if (!_hasSetScore) {
      HighScore.setHighScore(points, whatByWhat);
      SchedulerBinding.instance!.scheduleFrameCallback(
        (timeStamp) => setStuffOnParent(),
      );
      _hasSetScore = true;
    }

    final clearTilePaint = Paint()
      ..color = Settings.boardThemeValues.getSquareColors()[1] ?? Colors.grey;

    for (int i = 0; i < whatByWhat; ++i) {
      for (int k = 0; k < whatByWhat; ++k) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              _board[i][k].dimensions.left,
              _board[i][k].dimensions.top,
              _board[i][k].dimensions.width,
              _board[i][k].dimensions.height,
            ),
            ImportantValues.radius,
          ),
          clearTilePaint,
        );
      }
    }

    for (int i = 0; i < whatByWhat; ++i) {
      for (int k = 0; k < whatByWhat; ++k) {
        if (_elements[i][k].value != 0) {
          if (_elements[i][k].animateElement) {
            final newTileRatio = _handlingNewTileCounter /
                ImportantValues.newTileAnimationLength;
            final normalRatio =
                _handlingCounter / ImportantValues.animationLength;
            if (_elements[i][k].isNewTile) {
              //THIS MEANS IT SHOULD EXPAND FROM TINY TO BIG
              Rect rect = Rect.fromLTWH(
                tileWidth * i +
                    ImportantValues.halfPadding +
                    tileWidth * 0.5 -
                    (newTileRatio * tileWidth * 0.5),
                tileHeight * k +
                    ImportantValues.halfPadding +
                    tileHeight * 0.5 -
                    (newTileRatio * tileHeight * 0.5),
                (tileWidth - ImportantValues.padding) * newTileRatio,
                (tileHeight - ImportantValues.padding) * newTileRatio,
              );
              canvas.drawRRect(
                RRect.fromRectAndRadius(
                  rect,
                  ImportantValues.radius,
                ),
                Paint()
                  ..color = Settings.boardThemeValues
                          .getSquareColors()[_elements[i][k].value] ??
                      Color.fromRGBO(
                        _elements[i][k].value % 255,
                        _elements[i][k].value % 255,
                        _elements[i][k].value % 255,
                        1,
                      ),
              );
              TextPainter scorePainter = TextPainter(
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  text: _elements[i][k].value.toString(),
                  style: TextStyle(
                    fontSize: fontSize * newTileRatio,
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
            if (_elements[i][k].isMerged) {
              //THIS MEANS IT SHOULD EXPAND FROM TINY TO BIG
              Rect rect = Rect.fromLTWH(
                tileWidth * i +
                    ImportantValues.halfPadding +
                    tileWidth * 0.5 -
                    (normalRatio * tileWidth * 0.5),
                tileHeight * k +
                    ImportantValues.halfPadding +
                    tileHeight * 0.5 -
                    (normalRatio * tileHeight * 0.5),
                (tileWidth - ImportantValues.padding) * normalRatio,
                (tileHeight - ImportantValues.padding) * normalRatio,
              );
              canvas.drawRRect(
                RRect.fromRectAndRadius(
                  rect,
                  ImportantValues.radius,
                ),
                Paint()
                  ..color = Settings.boardThemeValues
                          .getSquareColors()[_elements[i][k].value] ??
                      Color.fromRGBO(
                        _elements[i][k].value % 255,
                        _elements[i][k].value % 255,
                        _elements[i][k].value % 255,
                        1,
                      ),
              );
              TextPainter scorePainter = TextPainter(
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  text: _elements[i][k].value.toString(),
                  style: TextStyle(
                    fontSize: fontSize * normalRatio,
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

            Rect rect = _elements[i][k].previousPosition != null
                ? Rect.fromLTWH(
                    tileWidth *
                            (_elements[i][k].previousPosition!.i +
                                (i - _elements[i][k].previousPosition!.i) *
                                    normalRatio) +
                        ImportantValues.halfPadding,
                    tileHeight *
                            (_elements[i][k].previousPosition!.k +
                                (k - _elements[i][k].previousPosition!.k) *
                                    normalRatio) +
                        ImportantValues.halfPadding,
                    tileWidth - ImportantValues.padding,
                    tileHeight - ImportantValues.padding,
                  )
                : Rect.fromLTWH(
                    tileWidth * i + ImportantValues.halfPadding,
                    tileHeight * k + ImportantValues.halfPadding,
                    tileWidth - ImportantValues.padding,
                    tileHeight - ImportantValues.padding,
                  );
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                rect,
                ImportantValues.radius,
              ),
              Paint()
                ..color = Settings.boardThemeValues
                        .getSquareColors()[_elements[i][k].value] ??
                    Color.fromRGBO(
                      _elements[i][k].value % 255,
                      _elements[i][k].value % 255,
                      _elements[i][k].value % 255,
                      1,
                    ),
            );
            TextPainter scorePainter = TextPainter(
              textDirection: TextDirection.rtl,
              text: TextSpan(
                text: _elements[i][k].value.toString(),
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
            tileWidth * i + ImportantValues.halfPadding,
            tileHeight * k + ImportantValues.halfPadding,
            tileWidth - ImportantValues.padding,
            tileHeight - ImportantValues.padding,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              rect,
              ImportantValues.radius,
            ),
            Paint()
              ..color = Settings.boardThemeValues
                      .getSquareColors()[_elements[i][k].value] ??
                  Color.fromRGBO(
                    _elements[i][k].value % 255,
                    _elements[i][k].value % 255,
                    _elements[i][k].value % 255,
                    1,
                  ),
          );
          TextPainter scorePainter = TextPainter(
            textDirection: TextDirection.rtl,
            text: TextSpan(
              text: _elements[i][k].value.toString(),
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
        _rePaint.notifyListeners();
      });
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
