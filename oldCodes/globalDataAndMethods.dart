import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:katakuti/settings.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

// All the dynamic data of this app is stored and controlled from here
GameInfo gameInfo = GameInfo();

// The last cell id notifier
LastCellIdNotifier lastCellIdNotifier = LastCellIdNotifier();

//The game reset notifier
GameResetNotifier gameResetNotifier = GameResetNotifier();

class GameInfo {

  String _activePlayer = settings().player1;
  String _nonActivePlayer = settings().player2;


  bool gameOver = false;
  var isFirstBuild =
      true; // We should not notify when the Player is being rendered

  // State of piece in each cell
  var _gutiList = List.filled(9, "blank");

  // The position of the pieces of the winner. Initially it is an impossible cell id(not in range 0..8)
  var winnerPiecePositionList = List.filled(3, 10);

  // This is all the combinations(triplets) neededed to be checked in order to decide whether game is over and optionally if there is a winner
  var tripleList = [
    [
      [0, 1, 2],
      [0, 4, 8],
      [0, 3, 6]
    ],
    [
      [0, 1, 2],
      [1, 4, 7]
    ],
    [
      [0, 1, 2],
      [2, 5, 8],
      [2, 4, 6]
    ],
    [
      [0, 3, 6],
      [3, 4, 5]
    ],
    [
      [1, 4, 7],
      [3, 4, 5],
      [6, 4, 2],
      [0, 4, 8]
    ],
    [
      [3, 4, 5],
      [2, 5, 8]
    ],
    [
      [0, 3, 6],
      [6, 7, 8],
      [6, 4, 2]
    ],
    [
      [1, 4, 7],
      [6, 7, 8]
    ],
    [
      [6, 7, 8],
      [2, 5, 8],
      [0, 4, 8]
    ]
  ];

  get activePlayer {
    return _activePlayer;
  }

  set activePlayer(player) {
    _activePlayer = player;
  }

  get nonActivePlayer {
    return _nonActivePlayer;
  }

  set nonActivePlayer(player) {
   _nonActivePlayer = player;
  }

  switchActivePlayer() {
    var oldActivePlayer = _activePlayer;
    _activePlayer = _nonActivePlayer;
    _nonActivePlayer = oldActivePlayer;
  }

  // It stores the current piece of the cell
  storeGutiForCell({@required cellId, @required blank}) {
    if (blank)
      _gutiList[cellId] = "blank";
    else {
      if (_activePlayer == settings().player1)
        _gutiList[cellId] = "cross";
      else
        _gutiList[cellId] = "round";
    }
  }

  // Return the current piece of the cell
  getGutiForCell(cellId) {
    return _gutiList[cellId];
  }

  void checkAndOverTheGame(context) {
    // For each cell if that is not blank check triples in its corresponding triplet for containing same piece
    for (var i = 0; i < 9; i++)
      for (var sequence in tripleList[i])
        if (_gutiList[sequence[0]] == _gutiList[sequence[1]] &&
            _gutiList[sequence[1]] ==
                _gutiList[sequence[2]]) if (_gutiList[sequence[0]] != "blank") {

          gameOver = true;

          // Marks the cell for highlighting containing same mark
          winnerPiecePositionList[0] = sequence[0];
          winnerPiecePositionList[1] = sequence[1];
          winnerPiecePositionList[2] = sequence[2];

          // Reset the game states(data accessed from this class) saved so that we can know the cells to be highlighted
          // It also shows the game over dialog
          resetGame(
              saveState: true,
              exceptPlayer: true, // This will make the player label change to "Game Over"
              context: context,
              mark: _gutiList[sequence[0]]); // The piece of the winner. Needed so that we can show who has won.
          return;
        }

    var isTableFull = tableIsFull();
    if (isTableFull) {
      gameOver = true;
      resetGame(saveState: true, exceptPlayer: true, context: context);
    }
  }

  // Check for containing same mark and if it does then return the mark
  check(triple) {
    for (var sequence in triple)
      if (_gutiList[sequence[0]] == _gutiList[sequence[1]] &&
          _gutiList[sequence[1]] == _gutiList[sequence[2]])
        return _gutiList[sequence[0]];
  }

  // Check for availability of blank cells
  bool tableIsFull() {
    // If there is no blank cell then the game is over
    for (var i = 0; i < 9; i++) if (_gutiList[i] == "blank") return false;
    return true;
  }

  // It reset the states of the game saved in this class to default
  resetGame(
      {saveState = false, exceptPlayer = false, mark = "blank", context}) {
    // Reset all the data to its initial state

    if (!saveState) {
      lastCellIdNotifier.setLastCellId(10);
      gameOver = false;
      _gutiList = List.filled(9, "blank");
      winnerPiecePositionList = List.filled(3, 10);
      _activePlayer = settings().player1;
      _nonActivePlayer = settings().player2;
      isFirstBuild = true;
    }

    if (exceptPlayer) {
      switchActivePlayer();
      _nonActivePlayer = "Game Over";
      _activePlayer = "Game Over";

      // mark not blank => there's a winner
      if (mark != "blank") {
        if (mark == "round")
          MyAlert(context: context, text: "${settings().player2} has won the game!").show();
        else
          MyAlert(context: context, text: "${settings().player1} has won the game!").show();
      } else
        MyAlert(context: context, text: "Nobody has won the game!").show();
    }
    // This will notify the necessary widgets to rebuild itself.
    gameResetNotifier._resetGame();
  }
}

// Notifies about the change cell Id clicked last
class LastCellIdNotifier with ChangeNotifier {
  var _cellId =
      10; // The id of the cell clicked last. It should not match to any cell for the first time, so it is 10.

  void setLastCellId(id) {
    _cellId = id;

    notifyListeners();
  }

  int getLastCellId() {
    return _cellId;
  }
}

class GameResetNotifier with ChangeNotifier {
  _resetGame() {
    notifyListeners();
  }
}

class MyAlert extends Alert {
  final text;
  final context;

  MyAlert({@required this.text, @required this.context})
      : super(
          context: context,
          title: "Game Over",
          desc: text,
          style: AlertStyle(
            isOverlayTapDismiss: false,
            animationType: AnimationType.grow,
            animationDuration: Duration(milliseconds: 500),
            isCloseButton: false,
            alertBorder: null,
            titleStyle: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          buttons: [
            DialogButton(
                color: Colors.red.withGreen(197).withRed(175).withBlue(255),
                child: Text(
                  "Ok",
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.button.fontSize * 1.4,
                      color: Theme.of(context).colorScheme.onSecondary),
                ),
                onPressed: () => Navigator.of(context).pop())
          ],
        );
}

