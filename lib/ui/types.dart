import 'dart:math';
import 'dart:ui';

enum Direction { Left, Right, Up, Down }

class ImportantValues {
  static Radius radius = Radius.circular(5);

  static double padding = 5;
  static double halfPadding = padding / 2;

  static const double NewTileAnimationLength = 0.2;
  static const double AnimationLength = 0.25;

  static void updateRadius(int size) {
    if (size > 10) {
      radius = Radius.circular(0);
      return;
    }
    final power = pow(0.8, size);
    radius = Radius.circular(
      power.toDouble() * 10,
    );
  }

  static void updatePadding(int size) {
    final newPadding = pow(0.8, size).toDouble() * 10;
    padding = newPadding;
    halfPadding = newPadding / 2;
  }

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
