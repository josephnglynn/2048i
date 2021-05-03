import 'dart:ui';

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
  MutableRectangle? futurePosition;

  int value;

  MovementSpeed movementSpeed = MovementSpeed(0, 0);

  BoardElements(this.dimensions, this.value);
}