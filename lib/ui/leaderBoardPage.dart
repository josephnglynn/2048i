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

  void increase() => setState(() => whatByWhat++);

  void decrease() {
    if (whatByWhat == 3) return;
    setState(() => whatByWhat--);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        details.velocity.pixelsPerSecond.dx < 0 ? increase() : decrease();
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
          title: Text(
            "Leaderboard",
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
            child: FutureBuilder<List<Document>>(
              future: Settings.firestore
                  .collection("users")
                  .document("scores")
                  .collection(whatByWhat.toString())
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return Text(
                      'Oh no, no-one has made a highscore for ${whatByWhat}x$whatByWhat board\n😭',
                      textAlign: TextAlign.center,
                    );
                  }

                  return ListView.builder(
                    itemBuilder: (context, index) {
                      bool itIsMe =
                          snapshot.data![index].map["name"] == Auth.userName;
                      return Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(
                          itIsMe ? 20 : 10,
                        ),
                        color: itIsMe
                            ? Color.fromRGBO(207, 94, 248, 1.0)
                            : Theme.of(context).scaffoldBackgroundColor,
                        child: Text(
                          "${snapshot.data![index].map["name"]} : ${snapshot.data![index].map["highScore"]}",
                        ),
                      );
                    },
                    itemCount: snapshot.data!.length,
                  );
                }
                return Text("LOADING ...");
              },
            ),
          ),
        ),
        bottomSheet: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () => decrease(),
                  icon: Icon(Icons.arrow_back_ios)),
              Text("${whatByWhat}x$whatByWhat"),
              IconButton(
                  onPressed: () => increase(),
                  icon: Icon(Icons.arrow_forward_ios)),
            ],
          ),
        ),
      ),
    );
  }
}
