import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:improved_2048/api/settings.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double fontSize = Settings.fontSizeScale;
  int themeIndex = Settings.themeIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyText1!.color,
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Font Size Scale  :  $fontSize"),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: TextFormField(
                    initialValue: fontSize.toString(),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onChanged: (value) async {
                      if (value.length < 3) return;
                      final asNumber = double.parse(value);
                      if (asNumber > 0 && asNumber <= 1) {
                        await Settings.setFontSize(asNumber);
                        return setState(() {
                          fontSize = asNumber;
                        });
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("MUST BE : 0 < x < 1"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Color Scheme"),
                  DropdownButton<int>(
                    value: themeIndex,
                    items: [
                      DropdownMenuItem(
                        child: Text("DefaultTheme"),
                        value: 0,
                      ),
                      DropdownMenuItem(
                        child: Text("Sean's Theme"),
                        value: 1,
                      ),
                      DropdownMenuItem(
                        child: Text("Custom Theme"),
                        value: 2,
                      ),
                    ],
                    onChanged: (value) async {
                      await Settings.setTheme(value!);
                      setState(() => themeIndex = value);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Show Number Of Moves Instead Of Time"),
                  Switch(
                    value: Settings.showMovesInsteadOfTime,
                    onChanged: (value) async {
                      await Settings.setShowMovesInsteadOfTime(value);
                      setState(() {});
                    },
                  ),
                ],
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
                await Settings.setFontSize(0.75);
                await Settings.setTheme(0);
                setState(() {
                  fontSize = Settings.fontSizeScale;
                });
              },
              child: Text(
                "RESET ALL SETTINGS",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            )
          ],
        ),
      ),
    );
  }
}
