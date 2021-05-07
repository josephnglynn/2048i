import 'package:flutter/material.dart';
import 'package:improved_2048/ui/homePage.dart';
import 'package:flutter/services.dart';
import 'api/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.init();
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(
    MaterialApp(
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      themeMode: ThemeMode.system,
      home: HomePage(4),
    ),
  );
}
