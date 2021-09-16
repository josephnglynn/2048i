import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:improved_2048/api/settings.dart';
import 'package:improved_2048/themes/baseClass.dart';
import 'package:improved_2048/ui/home_page.dart';


class ThemeEditor extends StatefulWidget {
  final SquareColors? squareColors;

  ThemeEditor({this.squareColors});

  @override
  _ThemeEditorState createState() => _ThemeEditorState(sC: squareColors);
}

class _ThemeEditorState extends State<ThemeEditor> {
  late SquareColors squareColors;
  late bool newTheme;

  _ThemeEditorState({SquareColors? sC}) {
    if (sC != null) {
      squareColors = sC;
      newTheme = false;
    } else {
      squareColors = SquareColors({}, {}, "New Theme");
      newTheme = true;
    }
  }

  Future showColorPicker(bool isLightTheme, int index) async {
    Color? previous =
        isLightTheme ? squareColors.light[index] : squareColors.dark[index];
    if (!await ColorPicker(
      title: Text(isLightTheme
          ? "Choose light theme color"
          : "Choose dark theme color"),
      pickersEnabled: {
        ColorPickerType.accent: false,
        ColorPickerType.both: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.primary: false,
        ColorPickerType.wheel: true
      },
      enableShadesSelection: false,
      showColorCode: true,
      showColorName: true,
      onColorChanged: (Color value) {
        if (isLightTheme) {
          squareColors.light[index] = value;
        } else {
          squareColors.dark[index] = value;
        }
      },
    ).showPickerDialog(context)) {
      if (isLightTheme) {
        squareColors.light[index] = previous!;
      } else {
        squareColors.dark[index] = previous!;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyText1!.color,
        ),
        title: Text(
          "Custom Theme Colors",
          style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.all(20),
          itemBuilder: (context, index) {
            int trueIndex = index == 0 ? 0 : pow(2, index - 1).toInt();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(trueIndex == 0
                    ? "Board Color "
                    : trueIndex == 1
                        ? "Empty Color "
                        : "$trueIndex"),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async =>
                          await showColorPicker(true, trueIndex),
                      child: Text("Set Light : "),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: squareColors.light[trueIndex],
                      ),
                      child: SizedBox(
                        width: 10,
                        height: 10,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async =>
                          await showColorPicker(false, trueIndex),
                      child: Text(" Set Dark : "),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: squareColors.dark[trueIndex],
                      ),
                      child: SizedBox(
                        width: 10,
                        height: 10,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          itemCount: squareColors.light.length,
        ),
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                Color defaultColor =
                MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Colors.white
                    : Colors.black;
                if (squareColors.light.length == 0) {
                  squareColors.light[0] = defaultColor;
                  squareColors.dark[0] = defaultColor;
                  return setState(() {});
                }
                squareColors
                    .light[pow(2, squareColors.light.length - 1).toInt()] =
                    defaultColor;
                squareColors.dark[pow(2, squareColors.dark.length - 1).toInt()] =
                    defaultColor;
                setState(() {});
              },
              child: Text("Add new element"),
            ),
            TextButton(
              onPressed: () async {
                if (newTheme) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => _SetThemeName(squareColors),
                    ),
                  );
                  return;
                }
                List<SquareColors> otherPlaces =
                await Settings.get().getOtherSavedThemes();
                List<String> asStrings = [];
                otherPlaces.forEach((element) {
                  if (element.themeName == squareColors.themeName) {
                    asStrings.add(squareColors.toJson());
                  } else {
                    asStrings.add(element.toJson());
                  }
                });
                await  Settings.get().storage.write("themes", asStrings);
                await Settings.init();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => HomePage(4),
                    ),
                        (route) => false);
              },
              child: Text("Save theme"),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetThemeName extends StatefulWidget {
  final SquareColors squareColors;

  _SetThemeName(this.squareColors);

  @override
  __SetThemeNameState createState() => __SetThemeNameState(squareColors);
}

class __SetThemeNameState extends State<_SetThemeName> {
  final SquareColors squareColors;

  __SetThemeNameState(this.squareColors);

  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyText1!.color,
        ),
        elevation: 0,
        title: Text("Custom theme name"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Please enter a name for this theme"),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: textEditingController,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: () async {
              if (textEditingController.text.length < 3) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Theme Name Must Be Longer Than 3 Characters",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (!await Settings.get().canUseName(textEditingController.text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Theme name is taken",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              List<String> otherPlaces =
                  await Settings.get().getOtherSavedThemesAsString();
              squareColors.themeName = textEditingController.text;
              otherPlaces.add(
                squareColors.toJson(),
              );
              await  Settings.get().storage.write("themes", otherPlaces);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => HomePage(4),
                  ),
                  (route) => false);
            },
            child: Text("Save theme"),
          ),
        ],
      ),
    );
  }
}
