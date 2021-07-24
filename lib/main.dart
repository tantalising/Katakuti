import 'dart:convert';

import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:katakuti/helperMethods.dart';
import 'package:katakuti/settings.dart';
import 'package:katakuti/test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'gameController.dart';
import 'startPage.dart';
import 'package:get/get.dart';

void main() async {
  // Add licenses
  LicenseRegistry.addLicense(() async* {
    List<String> licensePathList = [
      'google_fonts/OFL.txt',
      'assets/nameLICENSE.txt',
      /*middle*/ 'google_fonts',
      'github.com/dominictarr/random-name'
    ];
    int length = licensePathList.length ~/ 2;
    for (int i = 0; i < length; i++) {
      final license = await rootBundle.loadString(licensePathList[i]);
      yield LicenseEntryWithLineBreaks([licensePathList[i + length]], license);
    }
  });

  // Disable the landscape mode
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(ThisApp()); // The app is unusable in landscape
  });
}

class ThisApp extends StatefulWidget {
  @override
  _ThisAppState createState() => _ThisAppState();
}

class _ThisAppState extends State<ThisApp> {
  @override
  void initState() {
    _initStates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),

      darkTheme: ThemeData.dark().copyWith(primaryColor: Colors.green),
      themeMode: ThemeMode.light,
      home: StartPage(),
    );
  }

  Future<void> _initStates() async {

    // Set the value of the button of the computer plays first in settings
    settings.value.doesComputerPlayFirst = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getBool("computerPlay") == null
            ? false
            : prefs.getBool("computerPlay"));

    // Set the value of the players' mark in settings.
    bool isPlayer1Round = await SharedPreferences.getInstance().then((prefs) =>
        prefs.getBool("player1IsRound") == null
            ? false
            : prefs.getBool("player1IsRound"));
    settings.update((settings) {
      settings.player1IsRound = isPlayer1Round;
    });
    if (!isPlayer1Round) {
      settings.update((settings) {
        settings.playerMarkMap = const {
          "player1": "cross",
          "player2": "round",
        };
      });
      gameController.update((controller) {
        controller.mark = [
          settings.value.playerMarkMap["player1"],
          settings.value.playerMarkMap["player2"],
        ];
      });
    }

    // Set the difficulty level of the computer;
    int difficulty = await SharedPreferences.getInstance().then((prefs) =>
        prefs.getInt("difficulty") == null ? 2 : prefs.getInt("difficulty"));
    settings.update((settings) {
      settings.updateDifficultySelection(difficulty);
    });

    //Load the usernames from the file
    await rootBundle
        .loadString('assets/englishFirstNames.csv')
        .then((usernames) => gameController.update((controller) {
              controller.firstNameList = usernames.split(",");
            }));


    // Set the value of the button state of the darkmode toggle button in settings
    settings.value.isToggled = await SharedPreferences.getInstance().then(
            (prefs) => prefs.getBool("isDarkMode") == null
            ? false
            : prefs.getBool("isDarkMode"));
    if (settings.value.isToggled) { // if dark mode is on
      // Get.changeTheme(
      //   ThemeData.dark().copyWith(
      //     primaryColor: Get.theme.primaryColor,
      //   ),
      // );

      Get.changeThemeMode(ThemeMode.dark);
    }
  }
}
