enum Direction { Left, Right, Up, Down }
enum TileState { Same, Changed, Merged, New }

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

class Position {
  int i;
  int k;

  Position(this.i, this.k);
}

class BoardElement {
  bool? taken;
  int value;
  Position currentPosition;
  Position previousPosition;
  TileState tileState = TileState.Same;

  BoardElement(this.value, this.previousPosition, this.currentPosition);
}
