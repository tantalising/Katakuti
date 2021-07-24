import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:katakuti/settings.dart';
import 'startPage.dart';
import 'gameController.dart';

class Board extends StatelessWidget {
  final double width;
  final double height;

  Board({@required this.width, @required this.height});

  @override
  Widget build(BuildContext context) {
    return FrontPage(
      width: width,
      height: height,
      tableLength: 3,
      cellContentSupplier: (context, id) => Mark(id: id),
    );
  }
}

class Mark extends StatelessWidget {
  final int id;
  Icon lastUsedIcon = iconMap["blank"];
  static Map<String, Icon> iconMap = {
    "blank": Icon(
      Icons.add,
      color: Colors.transparent,
    ),
    "cross": Icon(
      Icons.clear,
      color: () {
        var color = Colors.pinkAccent;
        return color;
      }(),
    ),
    "round": Icon(
      Icons.radio_button_unchecked_rounded,
      color: () {
        var color = Colors.pinkAccent;
        return color;
      }(),
    ),
  };

  Mark({@required this.id});
  @override
  Widget build(BuildContext context) {
    List playerList = const ["player1", "player2"];
    return Obx(
      () => Container(
        alignment: Alignment.center,
        child: SizedBox.expand(
          child: TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
            child: () {
              if (gameController().lastClickedCell == 10)
                lastUsedIcon = iconMap["blank"];

              if (gameController().lastClickedCell == id)
                {lastUsedIcon = iconMap[settings.value.playerMarkMap[playerList[gameController.value.currentMarkChooser]]];}
              return lastUsedIcon;
            }(),
            onPressed: Feedback.wrapForTap(
                () {gameController().handleClick(id);},
                context),
          ),
        ),
        color: gameController.value.color[id],
      ),
    );
  }
}
