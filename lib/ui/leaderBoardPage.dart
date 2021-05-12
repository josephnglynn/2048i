import 'package:firedart/firedart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:improved_2048/api/auth.dart';
import 'package:improved_2048/api/settings.dart';
import 'package:improved_2048/ui/authenticationPage.dart';

class LeaderBoardPage extends StatefulWidget {


  static void canSeeLeaderBoard(BuildContext context) {
    if (Auth.loggedIn) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LeaderBoardPage(),
        ),
      );
    } else {
      AuthenticationDialog.showAuthDialog(context);
    }
  }

  @override
  _LeaderBoardPageState createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {

  int whatByWhat = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Document>>(
          stream: Settings.firestore.collection("users").document("scores").collection(whatByWhat.toString()).stream,
          builder: (context, snapshot) {
            return Text("LOADING ...");
          },
        ),
      ),
    );
  }
}
