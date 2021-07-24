import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:katakuti/gameController.dart';
import 'package:katakuti/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarkSelectionPage extends StatelessWidget {
  const MarkSelectionPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Choose mark"),
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
                        "Select first player's mark",
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
                    Padding(
                      padding: EdgeInsets.only(left: Get.width / 4),
                      child: Transform.scale(
                        scale: 1.3,
                        child: ListTile(
                          title: Text(
                            "Cross",
                            style: TextStyle(
                              color: Get.theme.cardColor,
                            ),
                          ),
                          leading: Obx(
                            () => Radio<String>(
                              fillColor:
                                  settings.value.playerMarkMap["player1"] ==
                                          "round"
                                      ? MaterialStateProperty.all(Colors.pink)
                                      : MaterialStateProperty.all(Colors.black),
                              value: "round",
                              groupValue:
                                  settings.value.playerMarkMap["player1"],
                              onChanged:
                                  _changeMark, // update the settings value here
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(left: Get.width / 4),
                      child: Transform.scale(
                        scale: 1.3,
                        child: ListTile(
                          title: Text(
                            "Circle",
                            style: TextStyle(
                              color: Get.theme.cardColor,
                            ),
                          ),
                          leading: Obx(
                            () => Radio<String>(
                              fillColor:
                                  settings.value.playerMarkMap["player1"] ==
                                          "cross"
                                      ? MaterialStateProperty.all(Colors.pink)
                                      : MaterialStateProperty.all(Colors.black),
                              value: "cross",
                              groupValue:
                                  settings.value.playerMarkMap["player1"],
                              onChanged:
                                  _changeMark, // update the settings value here
                            ),
                          ),
                        ),
                      ),
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

  void _changeMark(String value) async {
    if (value == "round") {
      settings.update((settings) {
        settings.playerMarkMap = const {
          "player1": "round",
          "player2": "cross",
        };
      });
      gameController.update((controller) {
        controller.mark = [
          settings.value.playerMarkMap["player1"],
          settings.value.playerMarkMap["player2"],
        ];
      });
    } else {
      settings.update(
        (settings) {
          settings.playerMarkMap = const {
            "player1": "cross",
            "player2": "round",
          };
        },
      );
      gameController.update((controller) {
        controller.mark = [
          settings.value.playerMarkMap["player1"],
          settings.value.playerMarkMap["player2"],
        ];
      });
    }

    settings.update((settings) {
      settings.player1IsRound = value == "round" ? true : false;
    });
    await SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool("player1IsRound", value == "round"));
  }
}
