import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'globalDataAndMethods.dart';
import 'package:provider/provider.dart';

class Guti extends StatelessWidget {
  // The cell is blank at first
  var isBlank = true;
  Icon oldIcon = Icon(Icons
      .add); // The icon the widget is currently using. It is needed when widgets rebuilds itself for some reason but doesn't want to change the icon
  String player1 = gameInfo.activePlayer;
  String player2 = gameInfo.nonActivePlayer;
  final cellId;

  Guti({Key key, @required this.cellId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This will preserve the state of the cell when there is restart where we don't want to save the state except whether the cell is blank or not.
    gameInfo.getGutiForCell(cellId) == "blank"
        ? isBlank = true
        : isBlank = false;

    return Container(
      color: getColor(cellId, context),
      // Notify if the last cell id (that is the cell clicked is different from the cell that was clicked previously) has changed
      child: ChangeNotifierProvider.value(
        value: lastCellIdNotifier,
        child: Consumer<LastCellIdNotifier>(
          builder: (_, lastCellId, __) => SizedBox.expand(
            child: TextButton(
              style: ButtonStyle(
                visualDensity: VisualDensity.comfortable,
                // If the last cell clicked should not change then it should a show a different highlight on pressed
                overlayColor: MaterialStateProperty.resolveWith(
                  (states) {
                    if (!gameInfo.gameOver) {
                      if (states.contains(MaterialState.pressed) &&
                          (!isBlank && lastCellId.getLastCellId() != cellId))
                        return Theme.of(context).errorColor.withOpacity(0.1);
                    } else
                      return Theme.of(context).disabledColor.withOpacity(0.05);
                    // Use whatever color it already uses
                    return null;
                  },
                ),
              ),
              child: getIconForGuti(
                color: Colors.pinkAccent,
                lastCellId: lastCellId,
              ),
              onPressed: () => changeGuti(cellId, lastCellId, context),
            ),
          ),
        ),
      ),
    );
  }

  void changeGuti(id, lastCellId, context) {
    if (gameInfo.gameOver) return;

    // If the the last cell clicked is not same as this one and the cell is not blank then no need to change the piece(and do other things) and rebuild itself.
    if (!isBlank && lastCellId.getLastCellId() != id) {
      return;
    }

    isBlank ? isBlank = false : isBlank = true;

    // Save the information whether this cell is blank or not in a list
    gameInfo.storeGutiForCell(cellId: id, blank: isBlank);
    gameInfo.switchActivePlayer();
    lastCellIdNotifier.setLastCellId(id);
    gameInfo.checkAndOverTheGame(context);
  }

  getIconForGuti({Color color = Colors.pinkAccent, @required lastCellId}) {
    var iconColor = color;

    dummyIcon() {
      iconColor = Colors.transparent;
      return Icons.add_rounded;
    }

    var icon = Icon(
      gameInfo.activePlayer == player2
          ? isBlank
              ? dummyIcon()
              : Icons.clear
          : isBlank
              ? dummyIcon()
              : Icons.radio_button_unchecked_rounded,
      color: iconColor,
    );

    if (gameInfo.gameOver) {
      if (gameInfo.getGutiForCell(cellId) == "round")
        return Icon(Icons.radio_button_unchecked_rounded, color: iconColor,);
      else if (gameInfo.getGutiForCell(cellId) == "cross")
        return Icon(Icons.clear, color: iconColor,);
      else
        return Icon(
          dummyIcon(),
          color: iconColor,
        );
    }

    // If the the last cell clicked is not same as this one and the cell is not blank then no need to change the piece and rebuild itself.
    // This check is already present in the callback of the button but sometimes the cell rebuilds without being clicked and then we have to check it here also.
    if (!isBlank && lastCellId.getLastCellId() != cellId) {
      return oldIcon;
    }

    // Save the icon the widget is prsently using. Directly assigning the icon to oldIcon and then returning doesn't work for some reason.
    oldIcon = icon;
    return icon;
  }

  // Color for the cell. If the game is over and there is  a winner and the cell contains a piece of that winner then change its color.
//   If there is no winner then change color of all the cells.
  getColor(id, context) {
    if (gameInfo.gameOver) {
      if (gameInfo.winnerPiecePositionList[0] != 10) {
        if (gameInfo.winnerPiecePositionList[0] == id ||
            gameInfo.winnerPiecePositionList[1] == id ||
            gameInfo.winnerPiecePositionList[2] == id)
          return Theme.of(context).errorColor.withOpacity(0.1);
      } else
        return Theme.of(context).errorColor.withOpacity(0.1);
    }
    return null;
  }
}
