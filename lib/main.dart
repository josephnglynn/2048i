import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:improved_2048/ui/homePage.dart';
import 'package:improved_2048/api/settings.dart';

import 'api/auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Settings.init();
  await ImportantValues.init();
  await Auth.init();

  runApp(
    MaterialApp(
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      themeMode: ThemeMode.system,
      home: HomePage(4),
    ),
  );
}
