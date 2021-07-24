import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:katakuti/gameController.dart';
import 'package:katakuti/helperMethods.dart';
import 'package:nearby_connections/nearby_connections.dart';

// ignore: must_be_immutable
class LoadingScreen extends StatelessWidget {
  RxString text = "  Starting Search  ".obs;
  Timer periodicTimer;

  List<String> textList = [
    "    ..Searching",
    "Searching..   ",
  ];
  int textChooser = 0;
  LoadingScreen({Key key}) : super(key: key) {
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      periodicTimer == null
          ? periodicTimer = timer
          : textChooser = (textChooser + 1) % 2;
      text.value = textList[textChooser];
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        periodicTimer.cancel();
        Nearby().stopAdvertising();
        Nearby().stopDiscovery();
        Nearby().stopAllEndpoints();
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: Get.width / 6,
            ),
            Text(
              "     You have been assigned the following user name",
              style:
                  TextStyle(color: Colors.pinkAccent, fontSize: Get.width / 24),
            ),
            SizedBox(
              height: Get.width / 6,
            ),

            //user name
            Text(
              "\"" + gameController.value.userName + "\"",
              style: TextStyle(
                  color: Colors.lightBlueAccent, fontSize: Get.width / 18),
            ),

            SizedBox(
              height: Get.width / 2,
            ),
            Obx(() => Text(
                  text.value,
                  style: TextStyle(
                      color: Get.theme.primaryColor, fontSize: Get.width / 18),
                )),
          ],
        ),
      ),
    );
  }
}

