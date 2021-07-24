import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:katakuti/NearbyMethods.dart';
import 'package:katakuti/loadingScreen.dart';
import 'gameController.dart';
import 'helperMethods.dart';
import 'settings.dart';
import 'settingsPage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'GameScreen.dart';

class ActionButtons extends StatelessWidget {
  final int cellId;
  final double fontSize;
  final cellContentSupplier;

  const ActionButtons(
      {Key key,
      @required this.cellId,
      @required this.fontSize,
      @required this.cellContentSupplier})
      : super(key: key);

  static const Map<int, String> getButtonText = {
    0: "Play On Wifi",
    2: "Play Against Computer",
    4: "Play Offline",
    6: "Settings",
    8: "About",
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: cellContentSupplier == null
          ? TextButton(
              child: chooseChild(context),
              onPressed: null,
            )
          : cellContentSupplier(context, cellId),
    );
  }

  chooseChild(context) {
    if (cellId == 1 || cellId == 3 || cellId == 5 || cellId == 7)
      return Icon(Icons.clear);
    else
      return AspectRatio(
        aspectRatio: 1,
        child: SizedBox.expand(
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Colors.teal,
              ),
            ),
            child: Text(
              getButtonText[cellId],
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.5,
                color: Theme.of(context).secondaryHeaderColor,
                fontWeight: FontWeight.bold,
                fontSize: fontSize *
                    (100 - (getButtonText[cellId].length * 1.2)) /
                    100,
              ),
            ),
            onPressed: () => _handlePress(context),
          ),
        ),
      );
  }

  _handlePress(context) async {
    switch (cellId) {
      // Play on wifi
      case 0:
        await checkPermissions();
        if (!gameController.value.permissionGranted)
          break;
        else
          gameController.value.permissionGranted = false;
        HapticFeedback.heavyImpact();
        settings.value.isPlayingAgainstComputer = false;
        gameController().resetGame();
        gameController.value.userName = getRandomFirstName();
        Get.to(
          () => LoadingScreen(),
          transition: Transition.cupertino,
        );
        startConnection();
        // showSnack(title: "Katakuti", message: "Coming soon!");
        break;

      // Play against computer
      case 2:
        HapticFeedback.heavyImpact();
        settings.value.isPlayingAgainstComputer = true;
        await initializePlayerNames();
        gameController().resetGame(automatedComputerPlay: false);
        settings.update((settings) {
          settings.player2 = "Computer";
        });
        Get.to(
          () => GameView(),
          transition: Transition.cupertino,
        );
        if (settings.value.doesComputerPlayFirst) {
          gameController().isTurnOfComputer = true;
          await gameController().handleComputerPlay();
          gameController().isTurnOfComputer = false;
        }
        break;

      // Player Offline
      case 4:
        print(
            "the random number is ${getRandomCorner()} and another one is ${getRandomCorner()} ");
        HapticFeedback.heavyImpact();
        await initializePlayerNames();
        settings.value.isPlayingAgainstComputer = false;
        gameController().resetGame();
        Get.to(
          () => GameView(),
          transition: Transition.cupertino,
        );
        break;

      // Settings
      case 6:
        HapticFeedback.heavyImpact();
        await SharedPreferences.getInstance()
            .then((prefs) => prefs.setBool("isDarkMode", false));
        Get.to(
          () => SettingsPage(),
          transition: Transition.cupertino,
        );
        break;

      // About
      case 8:
        HapticFeedback.heavyImpact();
        // showSnack("bottom", context);
        PackageInfo.fromPlatform().then(
          (PackageInfo packageInfo) {
            showAboutDialog(
              context: context,
              applicationName: packageInfo.appName,
              applicationVersion: packageInfo.version,
              applicationLegalese:
                  "© ${DateTime.now().year} Tanbir Jishan. All Rights Reserved.",
            );
          },
        );
        break;
    }
  }

  // Get the player names from the storage if any.
  Future<void> initializePlayerNames() async {
    settings().player1 = await SharedPreferences.getInstance().then((prefs) =>
        prefs.getString("player1") == null || prefs.getString("player1") == ""
            ? "player1"
            : prefs.getString("player1"));

    settings().player2 = await SharedPreferences.getInstance().then((prefs) =>
        prefs.getString("player2") == null || prefs.getString("player2") == ""
            ? "player2"
            : prefs.getString("player2"));
  }
}
