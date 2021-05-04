import 'dart:ui';

enum Direction { Left, Right, Up, Down }

class ImportantStylesAndValues {
  static const Radius radius = Radius.circular(5);

  static const double Padding = 5;
  static const double HalfPadding = Padding / 2;

  static const double NewTileAnimationLength = 0.4;
  static const double AnimationLength = 0.1;

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

}

class AnimationIncrease {
  double x;
  double y;


  AnimationIncrease(this.x, this.y);
}

class BoardTile {
  MutableRectangle dimensions;

  BoardTile(this.dimensions);
}

class PreviousPosition {
  int i;
  int k;

  PreviousPosition(this.i, this.k);
}

class BoardElement {
  int value;
  PreviousPosition? previousPosition;
  bool animateElement;
  bool isNewTile;

  BoardElement(this.value, this.animateElement, this.isNewTile);
}