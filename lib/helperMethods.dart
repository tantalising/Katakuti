import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings.dart';
import 'gameController.dart';


// A random value(int, double or bool) generator object
Random randomObject = Random();

void checkAndOverTheGame() {
  // For each cell if that is not blank check triples in its corresponding triplet for containing same piece
  for (int i = 0; i < 9; i++)
    for (List sequence in tripleList[i])
      if (gameController().markList[sequence[0]] ==
              gameController().markList[sequence[1]] &&
          gameController().markList[sequence[1]] ==
              gameController()
                  .markList[sequence[2]]) if (gameController()
              .markList[sequence[0]] !=
          "blank") {
        // Marks the cell for highlighting containing same mark
        for (int j = 0; j < 3; j++)
          gameController().color[sequence[j]] =
              ThemeData.light().errorColor.withOpacity(0.1);

        gameController().gameOver = true;

        // We don't want to see that thinking has won the game.
        if (settings.value.isPlayingAgainstComputer)
          settings.update((controller) {
            controller.player2 = "computer";
          });
        gameController.value.resetButtonColor = Get.theme.primaryColor;
        String winnerPlayer = gameController.value.currentMarkChooser == 1
            ? settings().player1
            : settings().player2;

        if (settings.value.isPlayingAgainstComputer &&
            settings.value.doesComputerPlayFirst)
          winnerPlayer = winnerPlayer == settings().player1
              ? settings().player2
              : settings().player1;

        showGameOverDialog(middleText: "$winnerPlayer has won the game!");
        return;
      }

  bool isTableFull = checkIfBoardIsFull();
  // If all the cells are occupied then the game is over
  if (isTableFull) {
    //Update the color for game over
    for (int i = 0; i < 9; i++)
      gameController().color[i] = ThemeData.light().errorColor.withOpacity(0.1);

    gameController().gameOver = true;
    gameController.value.resetButtonColor = Get.theme.primaryColor;
    showGameOverDialog(middleText: "Nobody has won the game!");
  }
}

// Check for availability of blank cells
bool checkIfBoardIsFull() {
  // If there is no blank cell then the game is over
  for (var i = 0; i < 9; i++)
    if (gameController().markList[i] == "blank") return false;
  return true;
}

// This is all the combinations(triplets) needed to be checked in order to decide whether game is over and optionally if there is a winner
const List<List> tripleList = [
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

void showGameOverDialog({@required middleText}) {
  Get.defaultDialog(
    radius: (Get.height * 0.4) / 36,
    title: "Game Over",
    titleStyle: TextStyle(color: Get.theme.primaryColor),
    middleText: middleText,
    middleTextStyle: TextStyle(color: Colors.pinkAccent),
    confirm: TextButton(
      onPressed: () {Navigator.of(Get.context).pop(); if(isPlayingOnWifi()) {gameController.value.resetGame();}},
      child: Text("Ok"),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          Colors.teal,
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Get.theme.cardColor),
      ),
    ),
  );
}

// Just a customized snackbar.
void showSnack({
  SnackPosition side: SnackPosition.TOP,
  @required String title,
  @required message,
  Duration duration: const Duration(seconds: 2),
}) {
  Get.rawSnackbar(
    titleText: Text(
      title,
      style: TextStyle(
          color: Colors.teal,
          fontWeight: FontWeight.bold,
          fontSize: Get.width / 18),
    ),
    messageText: Text(
      message,
      style: TextStyle(
        color: Get.theme.primaryColor,
      ),
    ),
    barBlur: 100,
    duration: duration,
    backgroundColor: Get.theme.cardColor,
    snackStyle: SnackStyle.FLOATING,
    snackPosition: side,
    borderRadius: Get.width / 18,
  );
}

int getRandomCorner() {
  List<int> cornerList = [0, 2, 6, 8];
  cornerList.shuffle();
  return cornerList.first;
}

int getRandomNonCorner() {
  List<int> nonCornerList = [1, 3, 5, 7];
  nonCornerList.shuffle();
  return nonCornerList.first;
}

// To get the cell that resides at a right angle to a corner cell.
int getAcross(int corner) {
  switch (corner) {
    case 0:
    case 8:
      if (gameController().markList[2] == "blank")
        return 2;
      else if (gameController().markList[6] == "blank")
        return 6;
      else
        return getToAnotherDiagonal(corner);
      break;

    case 2:
    case 6:
      if (gameController().markList[0] == "blank") return 0;
      if (gameController().markList[8] == "blank")
        return 8;
      else
        return getToAnotherDiagonal(corner);
      break;

    default:
      throw ("invalid corner");
      break;
  }
}

int getToAnotherDiagonal(int corner) {
  switch (corner) {
    case 0:
      if (gameController().markList[8] == "blank")
        return 8;
      else
        return getAcross(0);
      break;

    case 8:
      if (gameController().markList[0] == "blank")
        return 0;
      else
        return getAcross(8);
      break;

    case 2:
      if (gameController().markList[6] == "blank")
        return 6;
      else
        return getAcross(2);
      break;

    case 6:
      if (gameController().markList[2] == "blank")
        return 2;
      else
        return getAcross(6);
      break;
    default:
      return null;
      throw ("non corner corner encountered");
  }
}

int findWinningCombination(String mark) {
  print("mark is $mark");
  print("evaluating combinations...");
  List<String> markList = gameController.value.markList;
  List<List<int>> iterationList = [
    [0, 1, 2],
    [1, 2, 0],
    [2, 0, 1]
  ];
  for (int i = 0; i < 9; i++)
    for (List sequence in tripleList[i])
      for (List triple in iterationList)
        if (markList[sequence[triple[0]]] ==
            markList[sequence[triple[1]]]) if (markList[sequence[triple[0]]] !=
                "blank" &&
            markList[sequence[triple[0]]] ==
                mark) if (markList[sequence[triple[2]]] == "blank") {
          int cell = sequence[triple[2]];
          print("The cell is $cell");
          return cell;
        }
  print("did not find anything");
  return null;
}

String getComputerMark() {
  print(
      "player 1 is cross : ${settings.value.player1IsRound} computerfirst : ${settings.value.doesComputerPlayFirst}");
  List<String> markList = ["round", "cross"];
  int markChooser = settings.value.player1IsRound ? 0 : 1;
  if (!settings.value.doesComputerPlayFirst)
    markChooser = markChooser == 0 ? 1 : 0;

  return markList[markChooser];
}

String getOpponentMark() {
  String mark = getComputerMark();
  return mark == "cross" ? "round" : "cross";
}

int computerMoveCalledTimes = 0;
int lastCorner;
bool middleIsOccupied = false;

int getComputerMove() {
  computerMoveCalledTimes += 1;
  if (settings().doesComputerPlayFirst) {
    List<int> cornerList = const [0, 2, 6, 8];
    List<int> nonCornerList = const [1, 3, 5, 7];

    switch (computerMoveCalledTimes) {
      case 1:
        print("case 1 executing..");
        for (int cell in cornerList)
          if (gameController().markList[cell] == "blank") lastCorner = cell;
        return lastCorner;
        break;

      case 2:
        print("case 2 executing..");
        if (gameController().markList[4] == "blank") {
          int corner = getAcross(lastCorner);
          lastCorner = corner;
          return corner;
        } else {
          int corner = getToAnotherDiagonal(lastCorner);
          lastCorner = corner;
          return corner;
        }
        break;

      case 3:
        print("case 3 executing..");
        if (gameController().markList[4] == "blank") {
          var winningCell = findWinningCombination(getComputerMark());
          if (winningCell != null)
            return winningCell;
          else {
            var stopWinningCell = findWinningCombination(getOpponentMark());
            if (stopWinningCell != null)
              return stopWinningCell;
            else
              return getToAnotherDiagonal(lastCorner);
          }
        } else {
          var winningCell = findWinningCombination(getComputerMark());
          if (winningCell != null)
            return winningCell;
          else {
            var stopWinningCell = findWinningCombination(getOpponentMark());
            return stopWinningCell;
          }
        }
        break;

      case 4:
        print("case 4 executing..");
        if (gameController().markList[4] == "blank") {
          var winningCell = findWinningCombination(getComputerMark());
          return winningCell;
        } else {
          var winningCell = findWinningCombination(getComputerMark());
          if (winningCell != null) {
            return winningCell;
          } else {
            var stopWinningCell = findWinningCombination(getOpponentMark());
            if (stopWinningCell != null) {
              return stopWinningCell;
            } else {
              for (int corner in nonCornerList)
                if (gameController().markList[corner] == "blank") return corner;

              for (int corner in cornerList)
                if (gameController().markList[corner] == "blank") return corner;

              return 2;
            }
          }
        }
        break;

      default:
        print("case default executing..");
        var winningCell = findWinningCombination(getComputerMark());
        if (winningCell != null) {
          print("returning winning cell");
          return winningCell;
        } else {
          var stopWinningCell = findWinningCombination(getOpponentMark());
          if (stopWinningCell != null) {
            print("returning stopping cell");
            return stopWinningCell;
          } else {
            var randomCell = playLinearly();
            if (randomCell != null) {
              print("returning random cell");
              return randomCell;
            } else
              throw ("FATAL ERROR! Linear search returned null");
          }
        }
        break;
    }
  } else {
    switch (computerMoveCalledTimes) {
      case 1:
        if (gameController().markList[4] != "blank") {
          middleIsOccupied = true;
          int corner = getRandomCorner();
          if (corner != null && gameController().markList[corner] == "blank")
            return corner;
          else {
            corner = getRandomCorner();
            if (corner != null)
              return corner;
            else
              throw ("All corners simultaneosuly occupied in second move!");
          }
        } else {
          middleIsOccupied = false;
          return 4;
        }
        break;

      case 2:
        int winningCell = findWinningCombination(getComputerMark());
        if (winningCell != null)
          return winningCell;
        else {
          int stopWinningCell = findWinningCombination(getOpponentMark());
          if (stopWinningCell != null) return stopWinningCell;
        }

        List<int> cornerList = const [0, 2, 6, 8];
        List<int> nonCornerList = const [1, 3, 5, 7];

        if (middleIsOccupied) {
          for (int corner in cornerList)
            if (gameController().markList[corner] == "blank")
              return corner;
        }

        // Maybe these codes are not necessary but I am not sure. It is here for safety.
        // Better unnecessary code than to have a chance of bug.
        for (int corner in nonCornerList)
          if (gameController().markList[corner] == "blank") return corner;

        for (int corner in cornerList)
          if (gameController().markList[corner] == "blank") return corner;

        return 2;
        break;

      default:
        int winningCell = findWinningCombination(getComputerMark());
        if (winningCell != null)
          return winningCell;
        else {
          int stopWinningCell = findWinningCombination(getOpponentMark());
          if (stopWinningCell != null) return stopWinningCell;
        }

        List<int> cornerList = const [0, 2, 6, 8];
        List<int> nonCornerList = const [1, 3, 5, 7];

        for (int corner in nonCornerList)
          if (gameController().markList[corner] == "blank") return corner;

        for (int corner in cornerList)
          if (gameController().markList[corner] == "blank") return corner;

        return 2;
        break;
    }
  }
}

int playLinearly() {
  for (int cell = 0; cell < 9; cell++)
    if (gameController().markList[cell] == "blank") return cell;
  return 2;
}

int playRandomly() {
  List<int> cellList = [];
  for (int cell = 0; cell < 9; cell++) {
    if (gameController().markList[cell] == "blank") cellList.add(cell);
  }
  if (cellList.isNotEmpty) {
    cellList.shuffle();
    return cellList.first;
  }

  return 2;
}

String getRandomFirstName(){
  String name = gameController().firstNameList[randomObject.nextInt(gameController().firstNameList.length)];
  return name.substring(2, name.length-2);
}


//Whether playing on wifi
bool isPlayingOnWifi(){
  //Whether playing on wifi
   return gameController.value.userName == settings.value.player1; /* If username set by wifi is same as player1. This
        may fail obviously when the user have also set the player name that coincidentally matches the username. But this has very
        low probability of happening. */
}
