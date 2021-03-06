import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:improved_2048/api/game_state.dart';

import 'game.dart';

class DeathPage extends StatelessWidget {
  final GameState gameState;
  DeathPage(this.gameState);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "2048",
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Game(4),
                ),
              );
            },
            child: Text("PLAY GAME"),
          ),
        ),
      ),
    );
  }
}
