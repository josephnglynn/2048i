import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:improved_2048/ui/homePage.dart';
import 'package:improved_2048/api/settings.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init("box");
  await Settings.init();
  await ImportantValues.init();

  runApp(
    MaterialApp(
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      themeMode: ThemeMode.system,
      home: HomePage(4),
    ),
  );
}
