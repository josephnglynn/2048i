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
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyText1!.color,
        ),
        title: Text(
          "Leaderboard ${whatByWhat}x$whatByWhat",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: StreamBuilder<List<Document>>(
            stream: Settings.firestore.collection("users").document("scores").collection(whatByWhat.toString()).stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(itemBuilder: (context, index) => Text("${snapshot.data![index].map["name"]} : ${snapshot.data![index].map["highScore"]}"), itemCount: snapshot.data!.length,);
              }
              return Text("LOADING ...");
            },
          ),
        ),
      ),
    );
  }
}
