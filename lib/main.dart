import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:improved_2048/ui/homePage.dart';
import 'package:improved_2048/api/settings.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Settings.init();
  await ImportantValues.init();

  if (Platform.isAndroid) {
    final platform = MethodChannel("app.channel.shared.data");
    String? sharedData = await platform.invokeMethod("getSharedText");
    if (sharedData != null) {
      print(sharedData);
      File file = File((await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory()).path + "/test.json");
      if (!await file.exists()) await file.create(recursive: true);
      await file.writeAsString(sharedData);
    }
  }

  runApp(
    MaterialApp(
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      themeMode: ThemeMode.system,
      home: HomePage(4),
    ),
  );
}
