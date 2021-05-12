import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:improved_2048/api/auth.dart';
import 'package:improved_2048/ui/homePage.dart';
import 'package:improved_2048/ui/leaderBoardPage.dart';

class AuthenticationDialog extends StatefulWidget {
  static Future showAuthDialog(BuildContext context) async {
    final dialog = AlertDialog(
      content: AuthenticationDialog(),
    );
    await showDialog(
      context: context,
      builder: (context) => dialog,
    );
  }

  @override
  _AuthenticationDialogState createState() => _AuthenticationDialogState();
}

class _AuthenticationDialogState extends State<AuthenticationDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Oop, you have to be logged in to access online services!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ),
                  );
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1!.color,
                      fontSize: 25),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SignUp(),
                    ),
                  );
                },
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1!.color,
                      fontSize: 25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).textTheme.bodyText1!.color),
        title: Text(
          "Login",
          style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 5,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: email,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Email",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Password",
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                if (email.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Email must be non-null"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (password.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Password must be non-null"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (await Auth.login(email.text, password.text)) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomePage(4)),
                      (route) => false);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LeaderBoardPage(),
                    ),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Something went wrong",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text(
                "Continue",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1!.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController email = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).textTheme.bodyText1!.color),
        title: Text(
          "Sign Up",
          style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 5,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: email,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Email",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: name,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Name",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Password",
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                if (email.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Email must be non-null"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (name.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Name must be non-null"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (password.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Password must be non-null"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (await Auth.signUp(email.text, name.text, password.text)) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomePage(4)),
                      (route) => false);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LeaderBoardPage(),
                    ),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Something went wrong",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text(
                "Continue",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1!.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
