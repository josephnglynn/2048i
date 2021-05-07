enum Direction { Left, Right, Up, Down }



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
  bool isMerged;
  bool isNewTile;
  bool animateElement;

  Position? previousPosition;

  BoardElement(this.value, this.animateElement, this.isNewTile, this.isMerged);
}
