import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'helperMethods.dart';
import 'settings.dart';
import 'package:get/get.dart';

final gameController = GameController().obs;

// It holds most of the data structures(states) of the game and the ui changes
// according to these data. This is a observable class.
class GameController {
  // The mark that the players use. It is stored in settings and can be changed
  // by the user e.g. the user may choose to give the player 1 the mark circle.
  List<String> mark = [
    settings.value.playerMarkMap["player1"],
    settings.value.playerMarkMap["player2"],
  ];

  // It chooses the current mark by an integer index which oscillate between zero
  // and one and thus represent the turns of the player.
  int currentMarkChooser = 0;
  bool isComputerCanceled = false;
  bool isTurnOfComputer = false;

  // This list stores which mark is at which cell. If there is no mark, then it
  // is empty(blank).
  List<String> markList = List.filled(9, "blank");

  int lastClickedCell = 10;
  static bool _gameOver = false;
  bool permissionGranted = false;
  String userName = "Fuck you! You should never see it";
  int receivedCell;
  Color resetButtonColor = Get.theme.disabledColor;

  List<int> _cellStatus = List.filled(9, 0); // 0 => empty && 1 => occupied
  List<Color> color = List.filled(9, Colors.transparent); // color of each cell

  final List<String> _splashColor = ["primary", "error"];
  List<String>
      firstNameList; // The user name list. It must be initialized before being used.

  static final List<Color> _playerLabelColor = [
    _gameOver
        ? Colors.grey
        : Colors.teal,
    Colors.grey,
  ];

  Color getPlayerCardColor(player) {
    Map<String, Color> playerCardColor = {
      settings().player1: _playerLabelColor[currentMarkChooser],
      settings().player2: _playerLabelColor[(currentMarkChooser + 1) % 2],
    };

    if (settings.value.isPlayingAgainstComputer &&
        settings.value.doesComputerPlayFirst)
      playerCardColor = {
        settings().player1: _playerLabelColor[(currentMarkChooser + 1) % 2],
        settings().player2: _playerLabelColor[currentMarkChooser],
      };

    return playerCardColor[player];
  }

  bool get gameOver {
    return _gameOver;
  }

  set gameOver(bool truth) {
    _gameOver = truth;
  }

  Color splashColor(BuildContext context, int id) {
    Map<String, Color> colorMap = {
      "primary": Theme.of(context).primaryColorLight.withOpacity(0.5),
      "error": Theme.of(context).errorColor.withOpacity(0.1),
      "disabled": Theme.of(context).disabledColor.withOpacity(0.05),
    };

    return colorMap[_splashColor[_cellStatus[id]]];
  }

  void handleClick(int id, {bool skipCheck: false}) async {
    if ((settings.value.isPlayingAgainstComputer && isTurnOfComputer) ||
        _cellStatus[id] == 1 ||
        _gameOver) return;


    if (isPlayingOnWifi()) {
      if (settings.value.clickReceived) {
        gameController.update((controller) {
          controller.handleOfflineClick(id);
        });

        Nearby().sendBytesPayload(settings.value.opponentId,
            Uint8List.fromList(id.toString().codeUnits));

        settings.value.clickReceived = false;
      }
      return;
    }

    gameController.update((controller) {
      controller.handleOfflineClick(id);
    });

    if (settings.value.isPlayingAgainstComputer) {
      isTurnOfComputer = true;
      await handleComputerPlay();
      isTurnOfComputer = false;
    }
  }

  void handleOfflineClick(int id) {
    if (_gameOver || _cellStatus[id] == 1)
      return; //If the game is over meanwhile(Otherwise computer will continue playing after game over)

    // update the mark of the cell
    markList[id] = mark[currentMarkChooser];

    //Switching player
    currentMarkChooser == 0 ? currentMarkChooser = 1 : currentMarkChooser = 0;
    _cellStatus[id] = 1; // The cell with id "id" is occupied now
    lastClickedCell = id;

    resetButtonColor = Get.theme.errorColor;
    // check if the game is over and declare the winner
    checkAndOverTheGame();
  }

  // The callback when the computer plays -- work going on!
  Future<void> handleComputerPlay({
    Duration delay: const Duration(seconds: 1),
  }) async {
    settings.update((controller) {
      controller.player2 = "Thinking...";
    });
    await Future.delayed(
      delay,
      () {
        if (isComputerCanceled) {
          isComputerCanceled = false;
          settings.update((controller) {
            controller.player2 = "Computer";
          });
          return;
        }

        int cell = 0;
        switch (settings.value.getDifficulty()) {
          case 0:
            cell = playLinearly();
            break;

          case 1:
            cell = playRandomly();
            break;

          case 2:
            cell = getComputerMove();
            break;

          default:
            cell = playRandomly();
            break;
        }

        if (cell != null)
          gameController.update((controller) {
            controller.handleOfflineClick(cell);
          });
        else
          throw ("Cell can't be null");
      },
    );
    settings.update((controller) {
      controller.player2 = "Computer";
    });
  }

  void resetGame({bool automatedComputerPlay: true}) async {
    if (settings.value.isPlayingAgainstComputer && isTurnOfComputer)
      settings.update((controller) {
        isComputerCanceled = true;
        controller.player2 = "stopping...";
      });

    currentMarkChooser = 0;
    markList = List.filled(9, "blank");
    lastClickedCell = 10;
    _gameOver = false;
    _cellStatus = List.filled(9, 0);
    color = List.filled(9, Colors.transparent);
    resetButtonColor = Get.theme.disabledColor;
    isTurnOfComputer = false;
    computerMoveCalledTimes = 0;

    if (automatedComputerPlay) if (settings.value.isPlayingAgainstComputer &&
        settings.value.doesComputerPlayFirst) {
      gameController().isTurnOfComputer = true;
      await gameController().handleComputerPlay();
      gameController().isTurnOfComputer = false;
    }
  }
}
