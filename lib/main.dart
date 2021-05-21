import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:improved_2048/ui/homePage.dart';
import 'package:improved_2048/api/settings.dart';
import 'package:improved_2048/api/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await GetStorage.init();
  } catch (e) {
    print(e);
  }
  await Settings.init();
  await ImportantValues.init();
  await Auth.init();

  runApp(
    MaterialApp(
      theme: ThemeData.light().copyWith(
        textTheme: GoogleFonts.openSansTextTheme(),
      ),
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme(
            backgroundColor: ThemeData.dark().scaffoldBackgroundColor,
            textTheme: TextTheme(
                headline6:
                    GoogleFonts.openSans().copyWith(color: Colors.white)),
            iconTheme: IconThemeData(color: Colors.white)),
        dialogTheme: DialogTheme(
            titleTextStyle: TextStyle(
          color: Colors.white,
        )),
        textTheme: GoogleFonts.openSansTextTheme().copyWith(
          bodyText2: TextStyle(
            color: Colors.white,
          ),
          bodyText1: TextStyle(
            color: Colors.white,
          ),
          caption: TextStyle(
            color: Colors.white,
          ),
          subtitle1: TextStyle(
            color: Colors.white,
          ),
          subtitle2: TextStyle(
            color: Colors.white,
          ),
          headline6: TextStyle(
            color: Colors.white,
          ),
          headline1: TextStyle(
            color: Colors.white,
          ),
          headline2: TextStyle(
            color: Colors.white,
          ),
          headline3: TextStyle(
            color: Colors.white,
          ),
          headline4: TextStyle(
            color: Colors.white,
          ),
          headline5: TextStyle(
            color: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              textStyle: TextStyle(foreground: Paint()..color = Colors.white)),
        ),
      ),
      themeMode: ThemeMode.system,
      home: HomePage(4),
    ),
  );
}
