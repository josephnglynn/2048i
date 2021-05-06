import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:improved_2048/api/settings.dart';
import 'package:improved_2048/ui/board.dart';
import 'package:improved_2048/ui/game.dart';
import 'package:improved_2048/ui/settingsPage.dart';
import 'package:improved_2048/ui/types.dart';

class HomePage extends StatefulWidget {
  final int sizeOfGrid;
  HomePage(this.sizeOfGrid);

  @override
  _HomePageState createState() => _HomePageState(sizeOfGrid);
}

class _HomePageState extends State<HomePage> {
  int sizeOfGrid;
  _HomePageState(this.sizeOfGrid);


  @override
  Widget build(BuildContext context) {
    Settings.boardThemeValues.updateDarkTheme();

    double width = MediaQuery.of(context).size.width - 150;
    double height = MediaQuery.of(context).size.height - 150;

    double times2Padding = 0;
    if (width > height) {
      times2Padding = 80;
      width -= times2Padding;
      height -= times2Padding;
    }
    final smaller = width > height ? height : width;

    void increaseGrid() {
      BoardPainter.dead = true;
      SchedulerBinding.instance!.scheduleFrameCallback((timeStamp) {
        BoardPainter.cleanUp();
        setState(() => sizeOfGrid++);
      });
    }

    void decreaseGrid() {
      if (sizeOfGrid == 3) return;
      BoardPainter.dead = true;
      SchedulerBinding.instance!.scheduleFrameCallback((timeStamp) {
        BoardPainter.cleanUp();
        setState(() => sizeOfGrid--);
      });
    }

    return GestureDetector(
      onVerticalDragEnd: (details) => details.velocity.pixelsPerSecond.dx < 0
          ? increaseGrid()
          : decreaseGrid(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (value) {
                if (!value.isKeyPressed(value.data.logicalKey)) return;
                switch (value.data.logicalKey.keyLabel) {
                  case "A":
                    decreaseGrid();
                    break;

                  case "D":
                    increaseGrid();
                    break;

                  case "Arrow Left":
                    decreaseGrid();
                    break;

                  case "Arrow Right":
                    increaseGrid();
                    break;
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "Welcome to 2048 improved",
                    style: TextStyle(fontSize: 50),
                    textAlign: TextAlign.center,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              padding: EdgeInsets.only(right: 20),
                              onPressed: () => decreaseGrid(),
                              icon: Icon(Icons.arrow_back_ios),
                              splashRadius: 20,
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Container(
                                padding:
                                    EdgeInsets.all(ImportantValues.halfPadding),
                                decoration: BoxDecoration(
                                  color: Settings.boardThemeValues
                                      .getBoardBackgroundColor(),
                                  borderRadius:
                                      BorderRadius.all(ImportantValues.radius),
                                ),
                                width: smaller,
                                height: smaller,
                                child: CustomPaint(
                                  painter:
                                      BoardPainter(sizeOfGrid, () {}, () {}),
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.only(left: 20),
                              splashRadius: 20,
                              onPressed: () => increaseGrid(),
                              icon: Icon(Icons.arrow_forward_ios),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            "${sizeOfGrid}x$sizeOfGrid",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomSheet: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => Game(sizeOfGrid),
                    ),
                    (route) => false,
                  );
                },
                child: Text(
                  "PLAY GAME",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1!.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: IconButton(
          splashRadius: 1,
          padding: EdgeInsets.only(top: 60),
          icon: Icon(
            Icons.settings,
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SettingsPage(),
            ),
          ),
        ),
      ),
    );
  }
}
