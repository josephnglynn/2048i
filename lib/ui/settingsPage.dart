import 'dart:io';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:improved_2048/api/settings.dart';
import 'package:improved_2048/ui/homePage.dart';
import 'package:improved_2048/ui/themeEditor.dart';
import 'package:improved_2048/ui/themes/baseClass.dart';
import 'package:path_provider/path_provider.dart';

class _GetThemesType {
  List<DropdownMenuItem<String>> themes;
  String currentTheme;

  _GetThemesType(this.themes, this.currentTheme);
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double fontSize = Settings.fontSizeScale;

  Future exportTheme() async {
    String filePath = await Settings.exportTheme();
    var dialog = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      title: Text("Exporting Theme"),
      content: Text("Location: $filePath"),
    );
    await showDialog(
      context: context,
      builder: (context) => dialog,
    );
  }

  Future<_GetThemesType> getThemes() async {
    List<DropdownMenuItem<String>> themes = [
      DropdownMenuItem(
        child: Text(
          "Default Theme",
        ),
        value: "DefaultTheme",
      ),
      DropdownMenuItem(
        child: Text(
          "Material Theme",
        ),
        value: "MaterialTheme",
      ),
    ];
    List<SquareColors> storageThemes = await Settings.getOtherSavedThemes();
    storageThemes.forEach((element) {
      themes.add(
        DropdownMenuItem(
          child: Text(
            element.themeName,
          ),
          value: element.themeName,
        ),
      );
    });

    return _GetThemesType(
      themes,
      Settings.boardThemeValues.getThemeName(),
    );
  }

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Font Size Scale"),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Movement Animation Length"),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: TextFormField(
                    initialValue: ImportantValues.animationLength.toString(),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onChanged: (value) async {
                      if (value.length < 1) return;
                      final asNumber = double.parse(value);
                      await ImportantValues.setAnimationLength(asNumber);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "New Tile Animation Length",
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: TextFormField(
                    initialValue:
                        ImportantValues.newTileAnimationLength.toString(),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onChanged: (value) async {
                      if (value.length < 1) return;
                      final asNumber = double.parse(value);
                      await ImportantValues.setNewTileAnimationLength(asNumber);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Color Scheme"),
                FutureBuilder<_GetThemesType>(
                  future: getThemes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return DropdownButton<String>(
                        value: snapshot.data!.currentTheme,
                        items: snapshot.data!.themes,
                        onChanged: (value) async {
                          if (value! == "MaterialTheme" ||
                              value == "DefaultTheme") {
                            await Settings.setThemeAsPreInstalledOne(
                                value == "MaterialTheme" ? 1 : 0);
                          } else {
                            await Settings.setThemeAsNonInstalledOneFromName(
                                value);
                          }
                          setState(() {});
                        },
                      );
                    }
                    return Text("LOADING THEMES");
                  },
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    var dialog = AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      title: Text("Which theme?"),
                      content: Scaffold(
                        body: SafeArea(
                          child: FutureBuilder<List<SquareColors>>(
                            future: Settings.getOtherSavedThemes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  itemBuilder: (context, index) => TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ThemeEditor(
                                            squareColors: snapshot.data![index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      snapshot.data![index].themeName,
                                    ),
                                  ),
                                  itemCount: snapshot.data!.length,
                                );
                              }
                              return Text("Loading ...");
                            },
                          ),
                        ),
                      ),
                    );
                    showDialog(
                      context: context,
                      builder: (context) => dialog,
                    );
                  },
                  child: Text(
                    "Edit Custom Theme",
                  ),
                ),
                TextButton(
                  onPressed: () {
                    var dialog = AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      title: Text("Where from?"),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          TextButton(
                            onPressed: () async {
                              String? path = await FilesystemPicker.open(
                                context: context,
                                rootDirectory: Directory(Settings.storageDirectoryPath),
                                title: "Get Color Scheme",
                                fsType: FilesystemType.file,
                                pickText: "Use this color scheme",
                              );
                              Navigator.of(context).pop();
                              File file = File(path!);
                              String contents = await file.readAsString();
                              SquareColors sC = SquareColors.fromJson(contents);
                              if (!await Settings.canUseName(sC.themeName)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Sorry that theme is already installed"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => HomePage(4),
                                ),
                              );
                            },
                            child: Text(
                              "STORAGE",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ThemeEditor(),
                              ),
                            ),
                            child: Text(
                              "EDITOR",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                    showDialog(
                      context: context,
                      builder: (context) => dialog,
                    );
                  },
                  child: Text("Add Custom Theme"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: Platform.isIOS || Platform.isAndroid
                  ? [
                      TextButton(
                        onPressed: () async =>
                            await Settings.shareCurrentThemeToOtherApps(),
                        child: Text("Share current theme"),
                      ),
                      TextButton(
                        onPressed: () async => await exportTheme(),
                        child: Text("Export theme"),
                      ),
                    ]
                  : [
                      TextButton(
                        onPressed: () async => await exportTheme(),
                        child: Text("Export theme"),
                      ),
                    ],
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
