import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:katakuti/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DifficultySelectionPage extends StatelessWidget {
  const DifficultySelectionPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Difficulty"),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        body: Center(
          child: AspectRatio(
            aspectRatio: 5 / 3,
            child: Container(
              padding: EdgeInsets.all(Get.width / 24),
              child: Card(
                color: Colors.teal,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // A little bit of spacing
                    SizedBox(
                      height: Get.height / 30,
                    ),
                    Transform.scale(
                      child: Text(
                        "Select computer's skill",
                        style: TextStyle(
                          color: Get.theme.cardColor,
                        ),
                      ),
                      scale: 1.6,
                    ),
                    // A little bit of spacing
                    SizedBox(
                      height: Get.height / 24,
                    ),
                    Obx(
                      () => ToggleButtons(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Get.width / 36),
                            child: Text(
                              "Camper",
                              style: TextStyle(
                                  color: Get.theme.cardColor,
                                  fontSize: Get.width / 18),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Get.width / 18),
                            child: Text(
                              "Noob",
                              style: TextStyle(
                                  color: Get.theme.cardColor,
                                  fontSize: Get.width / 18),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                right: Get.width / 12, left: Get.width / 18),
                            margin: EdgeInsets.only(left: Get.width / 30),
                            child: Text(
                              "Pro",
                              style: TextStyle(
                                  color: Get.theme.cardColor,
                                  fontSize: Get.width / 18),
                            ),
                          ),
                        ],
                        isSelected: settings.value.difficultySelection,
                        borderColor: Colors.white,
                        selectedBorderColor: Colors.white,
                        splashColor: Colors.pinkAccent.withOpacity(0.2),
                        fillColor: Colors.pink,

                        borderRadius: BorderRadius.circular(Get.width / 36),
                        onPressed: (int index) => _updateDifficulty(index),
                      ),
                    ),
                    // A little bit of spacing
                    SizedBox(
                      height: Get.height / 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateDifficulty(int index) async {
    settings.update((settings) {settings.updateDifficultySelection(index);});
    await SharedPreferences.getInstance().then((prefs) => prefs.setInt("difficulty", index));
  }
}
