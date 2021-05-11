import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:improved_2048/api/auth.dart';
import 'package:improved_2048/ui/authenticationPage.dart';

class LeaderBoard extends StatefulWidget {
  static void canSeeLeaderBoard(BuildContext context) {
    if (Auth.loggedIn) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LeaderBoard(),
        ),
      );
    } else {
      AuthenticationDialog.showAuthDialog(context);
    }
  }

  @override
  _LeaderBoardState createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
