import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:improved_2048/api/settings.dart';
import 'package:improved_2048/types/types.dart';
import 'package:sprung/sprung.dart';

import 'high_score.dart';

class GameState {
  final animationDuration =
      Duration(milliseconds: Settings.get().animationDuration);

  List<List<BoardTile>> _board = [];
  List<List<BoardElement>> _elements = [];
  List<List<BoardElement>> _undoElements = [];
  List<BoardElement> _mergers = [];

  Random _rng = Random();

  int moves = 0;
  int points = 0;
  int _boardSize;
  int _undoPoints = 0;
  int _topNumberLength = 1;

  final Function(void Function()) _updateState;
  final Function() _animate;

  final Sprung _sprung = Sprung();

  bool dead = false;
  bool _handlingInput = false;

  double _fontSize = 0;
  double _tileWidth = 0;
  double _tileHeight = 0;
  double _sprungValue = 0;
  double animationValue = 0;

  Size _size = Size.zero;

  final _clearTilePaint = Paint()
    ..color =
        Settings.get().boardThemeValues.getSquareColors()[1] ?? Colors.grey;

  GameState(
    this._boardSize,
    this._updateState,
    this._animate,
  ) {
    _wrongSize(_size);
  }

  void update(Size newSize) {
    if (newSize != _size) _wrongSize(newSize);
    _sprungValue = _sprung.transform(animationValue);
  }

  void _drawBackground(Canvas canvas, int i, int k) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          _board[i][k].dimensions.left,
          _board[i][k].dimensions.top,
          _board[i][k].dimensions.width,
          _board[i][k].dimensions.height,
        ),
        Settings.get().radius,
      ),
      _clearTilePaint,
    );
  }

  Color? _getColorLerpElements(int i, int k, int v) =>
      Color.lerp(
          Settings.get().boardThemeValues.getSquareColors()[v] ??
              Color.fromRGBO(
                v,
                v,
                v,
                1,
              ),
          Settings.get()
                  .boardThemeValues
                  .getSquareColors()[_elements[i][k].value] ??
              Color.fromRGBO(
                _elements[i][k].value,
                _elements[i][k].value,
                _elements[i][k].value,
                1,
              ),
          _sprungValue) ??
      Color.fromRGBO(
        _elements[i][k].value,
        _elements[i][k].value,
        _elements[i][k].value,
        1,
      );

  void _drawElements(Canvas canvas, int i, int k, bool merging) {
    if (_elements[i][k].value == 0) return;
    double left = _tileWidth * i + Settings.get().halfPadding;
    double top = _tileHeight * k + Settings.get().halfPadding;
    final width = _tileWidth - Settings.get().padding;
    final height = _tileHeight - Settings.get().padding;
    Rect? rect = _handlingInput
        ? Rect.zero
        : Rect.fromLTWH(
            left,
            top,
            width,
            height,
          );

    int v = _elements[i][k].value ~/ 2;
    Color? color;

    if (_handlingInput) {
      if (_elements[i][k].tileState != TileState.Merged) {
        color = Settings.get()
            .boardThemeValues
            .getSquareColors()[merging ? v : _elements[i][k].value];
      }
      switch (_elements[i][k].tileState) {
        case TileState.New:
          rect = Rect.fromLTWH(
            left + width * (1 - _sprungValue) * 0.5,
            top + height * (1 - _sprungValue) * 0.5,
            width * _sprungValue,
            height * _sprungValue,
          );
          break;
        case TileState.Same:
          rect = Rect.fromLTWH(
            left,
            top,
            width,
            height,
          );
          break;
        case TileState.Merged:
          double oldLeft = _tileWidth * _elements[i][k].previousPosition.i +
              Settings.get().halfPadding;
          double oldTop = _tileHeight * _elements[i][k].previousPosition.k +
              Settings.get().halfPadding;
          rect = Rect.fromLTWH(
            (left - oldLeft) * _sprungValue + oldLeft,
            (top - oldTop) * _sprungValue + oldTop,
            width,
            height,
          );
          color = _getColorLerpElements(i, k, v);
          break;
        case TileState.Changed:
          double oldLeft = _tileWidth * _elements[i][k].previousPosition.i +
              Settings.get().halfPadding;
          double oldTop = _tileHeight * _elements[i][k].previousPosition.k +
              Settings.get().halfPadding;
          rect = Rect.fromLTWH(
            (left - oldLeft) * _sprungValue + oldLeft,
            (top - oldTop) * _sprungValue + oldTop,
            width,
            height,
          );
          break;
      }
    } else {
      color = Settings.get()
          .boardThemeValues
          .getSquareColors()[merging ? v : _elements[i][k].value];
    }

    int value;
    if (merging) {
      value = v % 255;
    } else {
      value = _elements[i][k].value % 255;
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        Settings.get().radius,
      ),
      Paint()
        ..color = color ??
            Color.fromRGBO(
              value,
              value,
              value,
              1,
            ),
    );

    String text;
    if (_handlingInput &&
        (_elements[i][k].tileState == TileState.New ||
            _elements[i][k].tileState == TileState.Merged)) {
      text = (v + v * _sprungValue).ceil().toString();
    } else {
      text = _elements[i][k].value.toString();
    }

    TextPainter scorePainter = TextPainter(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: _elements[i][k].tileState != TileState.New
              ? _elements[i][k].tileState == TileState.Merged
                  ? _fontSize * _sprungValue
                  : _fontSize
              : _fontSize * _sprungValue,
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

  void _drawMergers(Canvas canvas, int i) {
    double left =
        _tileWidth * _mergers[i].currentPosition.i + Settings.get().halfPadding;
    double top = _tileHeight * _mergers[i].currentPosition.k +
        Settings.get().halfPadding;
    final width = _tileWidth - Settings.get().padding;
    final height = _tileHeight - Settings.get().padding;

    double oldLeft = _tileWidth * _mergers[i].previousPosition.i +
        Settings.get().halfPadding;
    double oldTop = _tileHeight * _mergers[i].previousPosition.k +
        Settings.get().halfPadding;
    final rect = Rect.fromLTWH(
      (left - oldLeft) * _sprungValue + oldLeft,
      (top - oldTop) * _sprungValue + oldTop,
      width,
      height,
    );

    int v = _mergers[i].value ~/ 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        Settings.get().radius,
      ),
      Paint()
        ..color = Color.lerp(
                Settings.get().boardThemeValues.getSquareColors()[v] ??
                    Color.fromRGBO(
                      v,
                      v,
                      v,
                      1,
                    ),
                Settings.get()
                        .boardThemeValues
                        .getSquareColors()[_mergers[i].value] ??
                    Color.fromRGBO(
                      _mergers[i].value,
                      _mergers[i].value,
                      _mergers[i].value,
                      1,
                    ),
                _sprungValue) ??
            Color.fromRGBO(
              _mergers[i].value,
              _mergers[i].value,
              _mergers[i].value,
              1,
            ),
    );

    TextPainter scorePainter = TextPainter(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        text: (v + v * _sprungValue).ceil().toString(),
        style: TextStyle(
          fontSize: _fontSize * _sprungValue,
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

  void draw(Canvas canvas) {
    for (int i = 0; i < _boardSize; ++i) {
      for (int k = 0; k < _boardSize; ++k) {
        _drawBackground(canvas, i, k);
      }
    }

    for (int i = 0; i < _boardSize; ++i) {
      for (int k = 0; k < _boardSize; ++k) {
        _drawElements(canvas, i, k, false);
      }
    }

    for (int i = 0; i < _mergers.length; ++i) {
      _drawMergers(canvas, i);
    }
  }

  void died() {
    dead = true;
    HighScore.get().setHighScore(points, _boardSize);
  }

  void undoMove() {
    if (_undoElements.isEmpty) return;
    points = _undoPoints;
    _elements = [];
    for (int i = 0; i < _undoElements.length; ++i) {
      _elements.add([]);

      for (int k = 0; k < _undoElements.length; ++k) {
        _elements[i].add(
          BoardElement(
            _undoElements[i][k].value,
            Position(i, k),
            Position(i, k),
          ),
        );
      }
    }
  }

  // Calling this assumes you don't care about elements
  bool _loadBoardDataFromCache() {
    List<dynamic>? storage = Settings.get().storage.read("board$_boardSize");
    if (storage == null) return false;
    final List<List<int>> data = storage.map((e) => List<int>.from(e)).toList();

    _elements = [];

    for (int i = 0; i < data.length; ++i) {
      _elements.add([]);
      for (int k = 0; k < data[i].length; ++k) {
        var length = data[i][k].toString().length;

        if (length > _topNumberLength) {
          _topNumberLength = length;
        }

        _elements[i].add(
          BoardElement(
            data[i][k],
            Position(i, k),
            Position(i, k),
          ),
        );
      }
    }

    points = Settings.get().storage.read("points$_boardSize");

    return true;
  }

  void _saveToCache() {
    Settings.get().storage.write(
          "board$_boardSize",
          _elements
              .map(
                (e) => e.map((e2) => e2.value).toList(),
              )
              .toList(),
        );

    Settings.get().storage.write("points$_boardSize", points);
  }

  Future clearCache() async {
    await Settings.get().storage.remove("board$_boardSize");
    await Settings.get().storage.remove("points$_boardSize");
  }

  List<BoardElement> _doStuff(List<BoardElement> row) {
    int originalLength = row.length;
    row = row.where((val) => val.value != 0).toList();
    for (int i = 0; i < row.length - 1; i++) {
      if (row[i].value == row[i + 1].value) {
        row[i].value = row[i].value * 2;
        row[i].tileState = TileState.Merged;

        var length = row[i].value.toString().length;
        if (length > _topNumberLength) {
          _topNumberLength = length;
          _fontSize = _tileHeight / _topNumberLength;
        }

        row[i + 1].value = 0;
        _mergers.add(BoardElement(
            row[i].value, row[i + 1].previousPosition, row[i].currentPosition));
        points += row[i].value;
      }
    }

    row = row.where((val) => val.value != 0).toList();
    int zeroesToInsert = originalLength - row.length;

    row.addAll(
      List.generate(
        zeroesToInsert,
        (index) => BoardElement(
          0,
          Position(-1, -1),
          Position(-1, -1),
        ),
      ),
    );

    return row;
  }

  List<List<BoardElement>> _inverseList(
      List<List<BoardElement>> listToBeInverted) {
    List<List<BoardElement>> invertedList = [];
    for (int i = 0; i < listToBeInverted.length; ++i) {
      invertedList.add(listToBeInverted.map((e) => e[i]).toList());
    }
    return invertedList;
  }

  void handleInput(Direction direction, int whatByWhat) {
    if (_handlingInput) return;
    _handlingInput = true;

    _mergers = [];
    _undoPoints = points;
    moves++;

    int totalValueBefore = 0;
    _undoElements = [];

    for (int i = 0; i < _elements.length; ++i) {
      _undoElements.add([]);
      for (int k = 0; k < _elements.length; ++k) {
        totalValueBefore += (k + i) * _elements[i][k].value;
        _elements[i][k].previousPosition = Position(i, k);
        _elements[i][k].tileState = TileState.Changed;
        _undoElements[i].add(
          BoardElement(
            _elements[i][k].value,
            Position(i, k),
            Position(i, k),
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
          _inverseList(_elements).map((e) => _doStuff(e)).toList(),
        );
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
        _elements[i][k].currentPosition = Position(i, k);
      }
    }

    _saveToCache();

    _animate();

    Future.delayed(
      animationDuration,
      () {
        _mergers = [];
        _undoElements = [];
        for (int i = 0; i < _elements.length; ++i) {
          _undoElements.add([]);
          for (int k = 0; k < _elements.length; ++k) {
            _elements[i][k].previousPosition = Position(i, k);
            _elements[i][k].tileState = TileState.Same;
            if (_elements[i][k].value < 0) _elements[i][k].value = 0;
            _undoElements[i].add(
              BoardElement(
                _elements[i][k].value,
                Position(i, k),
                Position(i, k),
              ),
            );
          }
        }

        if (totalValueBefore != totalValueAfterwards) {
          _addNewElement();
        }

        if (_haveTheyMadeAMistake()) {
          _updateState(() {
            died();
          });
        }

        _animate();
        Future.delayed(
          animationDuration,
          () => _updateState(() {
            _handlingInput = false;
          }),
        );
      },
    );
  }

  bool _haveTheyMadeAMistake() {
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

  void _addNewElement({bool generateOnly = false}) {
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
        BoardElement(
      2,
      Position(possiblePlaces[index][0], possiblePlaces[index][1]),
      Position(possiblePlaces[index][0], possiblePlaces[index][1]),
    );
    _elements[possiblePlaces[index][0]][possiblePlaces[index][1]].tileState =
        generateOnly ? TileState.Same : TileState.New;
  }

  void _generateBoard() {
    final tileWidth = _size.width / _boardSize;
    final tileHeight = _size.height / _boardSize;

    if (_loadBoardDataFromCache()) {
      for (int i = 0; i < _boardSize; ++i) {
        _board.add([]);
        for (int k = 0; k < _boardSize; ++k) {
          _board[i].add(
            BoardTile(
              MutableRectangle(
                tileWidth * i + Settings.get().halfPadding,
                tileHeight * k + Settings.get().halfPadding,
                tileWidth - Settings.get().padding,
                tileHeight - Settings.get().padding,
              ),
            ),
          );
        }
      }

      return;
    }

    for (int i = 0; i < _boardSize; ++i) {
      _board.add([]);
      _elements.add([]);
      for (int k = 0; k < _boardSize; ++k) {
        _board[i].add(
          BoardTile(
            MutableRectangle(
              tileWidth * i + Settings.get().halfPadding,
              tileHeight * k + Settings.get().halfPadding,
              tileWidth - Settings.get().padding,
              tileHeight - Settings.get().padding,
            ),
          ),
        );
        _elements[i].add(
          BoardElement(
            0,
            Position(i, k),
            Position(i, k),
          ),
        );
      }
    }

    _addNewElement(generateOnly: true);
    _addNewElement(generateOnly: true);
  }

  void _resizeBoard() {
    final tileWidth = _size.width / _boardSize;
    final tileHeight = _size.height / _boardSize;

    for (int i = 0; i < _boardSize; ++i) {
      for (int k = 0; k < _boardSize; ++k) {
        _board[i][k] = BoardTile(
          MutableRectangle(
            tileWidth * i + Settings.get().halfPadding,
            tileHeight * k + Settings.get().halfPadding,
            tileWidth - Settings.get().padding,
            tileHeight - Settings.get().padding,
          ),
        );
      }
    }
  }

  void _wrongSize(Size newSize) {
    _size = newSize;

    if (_board.isEmpty) {
      _generateBoard();
    } else {
      _resizeBoard();
    }

    _tileWidth = _size.width / _boardSize;
    _tileHeight = _size.height / _boardSize;
    _fontSize = _tileHeight / _topNumberLength / 2;
  }
}
