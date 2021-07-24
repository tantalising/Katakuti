import 'package:flutter/material.dart';
import 'globalDataAndMethods.dart';
import 'package:provider/provider.dart';

//The player label that highlights the current active player
class Player extends StatelessWidget {
  final width;
  final height;
  final player; // The name of the player
  final noPaddingAtBottom;

  Player(
      {Key key,
      @required this.width,
      @required this.height,
      @required this.player,
      this.noPaddingAtBottom = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = height / 6;

    return Container(
      // Notifies whether a new cell other than the previously clicked one has been clicked. If so then the player has also changed and we need to highlight the current active player.
      child: ChangeNotifierProvider.value(
        value: lastCellIdNotifier, // cell id changed => player changed
        child: Container(
          padding: EdgeInsets.only(
              top: padding, bottom: noPaddingAtBottom ? 0.00 : padding),
          child: Consumer<LastCellIdNotifier>(
            builder: (_, lastCellId, __) => Container(
              width: width,
              height: height / 4,
              alignment: Alignment.center,
              child: SizedBox.expand(
                child: Card(
                  elevation: gameInfo.activePlayer == player ? 2 : null ,
                  color: gameInfo.gameOver
                      ? Theme.of(context).errorColor.withRed(200)
                      : gameInfo.activePlayer == player
                      ? Colors.teal
                      : Theme.of(context)
                      .disabledColor.withOpacity(0.05), // Color when the player is not active(though it is obvious but I commented it anyway)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(padding / 6),
                  ),
                  child: Center(
                    child: Text(
                      player,
                      style: TextStyle(
                        fontSize: padding / 2,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
