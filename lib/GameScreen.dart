import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:katakuti/helperMethods.dart';
import 'package:katakuti/startPage.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'gameController.dart';
import 'player.dart';
import 'settings.dart';
import 'board.dart';
import 'package:get/get.dart';

class GameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.8;
    final height = MediaQuery.of(context).size.height * 0.4;

    return WillPopScope(
      onWillPop: () async {
        Nearby().stopAdvertising();
        Nearby().stopDiscovery();
        Nearby().stopAllEndpoints();

        if(isPlayingOnWifi())
        Get.offAll(
              ()=>StartPage(),
              transition: Transition.cupertino,
        );
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: Center(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: width / 8, top: width / 9),
                    //The label of the player, active player is highlighted
                    child: Obx(() => Player(
                      width: width * 0.66,
                      height: height,
                      player: settings.value.player2,
                      playerMark: settings.value.playerMarkMap["player2"],
                    ),),
                  ),
                  Board(
                    width: width,
                    height: height,
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            top: width / 8,
                            left: width / 4,
                            right: width / 4,
                            bottom: width /
                                8), // This will make the non-positioned widget's click area reachable
                        child: Player(
                          width: width * 0.66,
                          height: height,
                          player: settings.value.player1,
                          playerMark: settings.value.playerMarkMap["player1"],
                        ),
                      ),
                      Visibility(
                        visible: !isPlayingOnWifi(),
                        child: Positioned(                     // The reset button.
                          bottom: -(width / 48),
                          left: width,
                          child: Obx(() => IconButton(
                            icon: Icon(Icons.restore),
                            color: gameController.value.resetButtonColor,
                            onPressed: () => gameController.update((_) {
                              _.resetGame();
                            }),
                          ),),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

