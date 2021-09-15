import 'dart:io';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:improved_2048/api/auth.dart';
import 'package:improved_2048/api/settings.dart';
import 'package:improved_2048/themes/baseClass.dart';
import 'package:improved_2048/ui/home_page.dart';
import 'package:improved_2048/ui/theme_editor.dart';

import 'package:file_picker/file_picker.dart';

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


  Future exportTheme(BuildContext context) async {
    String filePath = await Settings.get().exportTheme();
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

    List<SquareColors> storageThemes = await Settings.get().getOtherSavedThemes();
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
      Settings.get().boardThemeValues.getThemeName(),
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
                            await Settings.get().setThemeAsPreInstalledOne(
                                value == "MaterialTheme" ? 1 : 0);
                          } else {
                            await Settings.get().setThemeAsNonInstalledOneFromName(
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
                  value: Settings.get().showMovesInsteadOfTime,
                  onChanged: (value) async {
                    await Settings.get().setShowMovesInsteadOfTime(value);
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
                            future: Settings.get().getOtherSavedThemes(),
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
                              String? path;
                              if (Platform.isAndroid || Platform.isIOS) {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles();
                                if (result == null) return;
                                path = result.files.single.path;
                              } else {
                                path = await FilesystemPicker.open(
                                  context: context,
                                  rootDirectory: Directory(
                                    Settings.get().storageDirectoryPath,
                                  ),
                                  title: "Get Color Scheme",
                                  fsType: FilesystemType.file,
                                  pickText: "Use this color scheme",
                                );
                              }
                              if (path == null) return;
                              Navigator.of(context).pop();
                              File file = File(path);
                              String contents = await file.readAsString();
                              SquareColors sC = SquareColors.fromJson(contents);
                              if (!await Settings.get().canUseName(sC.themeName)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Sorry that theme is already installed"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              List<String> otherPlaces =
                                  await Settings.get().getOtherSavedThemesAsString();

                              otherPlaces.add(
                                sC.toJson(),
                              );
                              await Settings.get().storage.write(
                                    "themes",
                                    otherPlaces,
                                  );
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
                            await Settings.get().shareCurrentThemeToOtherApps(),
                        child: Text("Share current theme"),
                      ),
                      TextButton(
                        onPressed: () async => await exportTheme(context),
                        child: Text("Export theme"),
                      ),
                    ]
                  : [
                      TextButton(
                        onPressed: () async => await exportTheme(context),
                        child: Text("Export theme"),
                      ),
                    ],
            ),
            Auth.get().loggedIn
                ? TextButton(
                    onPressed: () async {
                      await Settings.get().storage.remove("loggedIn");
                      await Settings.get().storage.remove("userName");
                      Auth.get().userName = null;
                      Auth.get().loggedIn = false;
                      Settings.get().firebaseAuth.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => HomePage(4),
                          ),
                          (route) => false);
                    },
                    child: Text(
                      "Log out",
                      textAlign: TextAlign.center,
                    ),
                    style: TextButton.styleFrom(backgroundColor: Colors.red),
                  )
                : SizedBox(
                    width: 1,
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

              },
              child: Text(
                "RESET ALL SETTINGS",
                textAlign: TextAlign.center,
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
