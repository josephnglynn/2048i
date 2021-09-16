enum Direction { Left, Right, Up, Down }
enum TileState { New, Same, Changed, Merged, Merging}

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

  int value;
  int increaseValue = 0;
  Position previousPosition;
  BoardElement? merging;
  TileState tileState = TileState.Same;

  BoardElement(this.value, this.previousPosition);
}
