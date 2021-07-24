import "package:get/get.dart";
import 'gameController.dart';

final settings = Settings().obs;

class Settings {
  String player1;
  String player2;

  // A mapping that maps each player to its mark. Note that in reality the mark will be reversed for some reason.
  Map<String, String> playerMarkMap = {
    "player1": "round",
    "player2": "cross",
  };

  // List for selecting difficulty of the computer
  List<bool> difficultySelection = [false, false, true];

  void updateDifficultySelection(int difficulty) {
    for (int i = 0; i < 3; i++)
      if (i != difficulty)
        difficultySelection[i] = false;
      else
        difficultySelection[i] = true;
  }

  int getDifficulty() {
    for (int i = 0; i < 3; i++) if (difficultySelection[i]) return i;

    return null;
  }

  // property for updating error color of the textformfield of player name chooser
  // I don't like forms so I am going to do this through this.
  bool firstPlayerInputInvalid = false;
  bool secondPlayerInputInvalid = false;

  bool isInputInvalid(String player) {
    return player == "player1"
        ? firstPlayerInputInvalid
        : secondPlayerInputInvalid;
  }

  // button state for whether the button is toggled or not. The button is the dark mode toggle button in the settings.
  bool isToggled;

  // Whether the user is playing against computer or not
  bool isPlayingAgainstComputer = false;


  // button state for whether the button is toggled or not. The button is the computer plays first chooser in settings.
  bool doesComputerPlayFirst;

  //Whethe the first player uses the round mark or not
  bool player1IsRound;

  //The id of the connected device
  String opponentId;

  // Whether we have received a click over wifi
  bool clickReceived = true;
}
