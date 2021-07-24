import 'package:flutter/material.dart';
import 'globalDataAndMethods.dart';
import 'player.dart';
import 'board.dart';

class BoardAndOtherWidgets extends StatelessWidget {
  const BoardAndOtherWidgets({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.8;
    final height = MediaQuery.of(context).size.height * 0.4;

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Player(
            //The label of the player, active player is highlighted
            width: width * 0.66,
            height: height,
            player: gameInfo.nonActivePlayer,
          ),
          Board(
            width: width,
            height: height,
          ),
          Stack(clipBehavior: Clip.none, children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: width / 4), // This will make the non-positioned widget's click area reachable
              child: Player(
                width: width * 0.66,
                height: height,
                player: gameInfo.activePlayer,
              ),
            ),
            Positioned(
                bottom: -(width / 120),
                left: width,
                child: IconButton(
                  icon: Icon(Icons.restore),
                  color: gameInfo.gameOver
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).errorColor,
                  onPressed: () => gameInfo.resetGame(),
                )),
          ]),
        ],
      ),
    );
  }
}
