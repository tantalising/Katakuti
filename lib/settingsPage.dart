import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:katakuti/playerMarkSelectionScreen.dart';
import 'package:katakuti/playerNameForm.dart';
import 'package:katakuti/settings.dart';
import 'package:katakuti/toggleButton.dart';

import 'diffcultySelectionPage.dart';

class SettingsPage extends StatelessWidget {
  static const List<String> getButtonText = const [
    "Change Player Names",
    "Dark Mode",
    "Computer Plays First",
    "Change Players' Mark",
    "Select Difficulty"
  ];


  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    // final double height = MediaQuery.of(context).size.height;
    final int crossCount = 2;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: GridView.count(
            shrinkWrap: true,
            padding: EdgeInsets.all(width / 24),
            mainAxisSpacing: width / 14,
            crossAxisSpacing: width / 14,
            crossAxisCount: crossCount,
            children: [
              for (int id = 0; id < getButtonText.length; id++)
                cellContentSupplier(context, id)
            ],
          ),
        ),
      ),
    );
  }

  // The tiles of the settings. It returns a specific tile depending on the id
  Widget cellContentSupplier(context, int cellId) {
    final width = MediaQuery.of(context).size.width;
    double fontSize = width / 18;

    // Dark mode toggle button
    final ThemeToggleButton button = ThemeToggleButton(
      buttonId: "darkMode",
      onToggleOff: () => Get.changeThemeMode(ThemeMode.light),
      onToggleOn: () => Get.changeThemeMode(ThemeMode.dark),
    );

    // Computer plays first toggle button
    final ToggleButton computerButton = ToggleButton(
      onToggleOn: () {},
      onToggleOff: () {},
      buttonId: "computer",
    );

    return AspectRatio(
      aspectRatio: 1,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Colors.teal,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              getButtonText[cellId],
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.5,
                color: Theme.of(context).secondaryHeaderColor,
                fontWeight: FontWeight.bold,
                fontSize: fontSize * 0.97,
              ),
            ),

            // The toggle button. It should only be visible to certain tiles with specific ids.
            Visibility(
              visible: cellId == 1 || cellId == 2,
              maintainAnimation: cellId == 1 || cellId == 2,
              maintainSize: cellId == 1 || cellId == 2,
              maintainState: cellId == 1 || cellId == 2,
              child: Padding(
                padding: EdgeInsets.only(
                    right: Get.width / 12, bottom: Get.width / 12),
                child: cellId == 1 ? button : computerButton,
              ),
            ),
          ],
        ),
        onPressed: () => _handlePress(cellId, button, computerButton),
      ),
    );
  }

  void _handlePress(
      cellId, Object button, ToggleButton computerButton) async {
    switch (cellId) {
      // Change Player Name
      case 0:
        settings().firstPlayerInputInvalid = false;
        settings().secondPlayerInputInvalid = false;
        Get.to(
          () => NameForm(),
          transition: Transition.cupertino,
        );
        break;

      // Change the players' mark
      case 3:
        Get.to(
          () => MarkSelectionPage(),
          transition: Transition.cupertino,
        );
        break;

      // Select diffculty
      case 4:
        Get.to(
          () => DifficultySelectionPage(),
          transition: Transition.cupertino,
        );
        break;
    }
  }
}
