import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:katakuti/settings.dart';
import 'gameController.dart';

//The player tile that highlights the current active player
class Player extends StatelessWidget {
  final double width;
  final double height;
  final String player;
  final String
      playerMark; // The mark of the player i.e. whether the he plays with circle or cross mark.

  const Player({
    @required this.width,
    @required this.height,
    @required this.player,
    @required this.playerMark,
  });
  @override
  Widget build(BuildContext context) {
    final double padding = height / 6;
    return Obx(
      () => Container(
        width: width,
        height: height / 4,
        alignment: Alignment.center,
        child: SizedBox.expand(
          child: Card(
            elevation: gameController
                        .value.mark[gameController.value.currentMarkChooser] ==
                    playerMark
                ? !settings.value.doesComputerPlayFirst ? 2 : null
                : !settings.value.doesComputerPlayFirst ? null : 2, // Elevates the highlighted player(active player)
            color: gameController.value.gameOver
                ? Theme.of(context).errorColor
                : gameController.value.getPlayerCardColor(player),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(padding / 6),
            ),
            child: Center(
              child: Text(
                gameController.value.gameOver ? "Game Over" : player,
                style: TextStyle(
                  fontSize: padding / 2,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
