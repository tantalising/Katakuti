import 'package:flutter/material.dart';
import 'package:katakuti/helperMethods.dart';
import 'package:get/get.dart';
import 'package:katakuti/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';



// The form for changing player names
class NameForm extends StatelessWidget {
  const NameForm({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _firstPlayerNameController =
    TextEditingController();
    final TextEditingController _secondPlayerNameController =
    TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Player Names"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(Get.width / 24),
            child: Center(
              child: AspectRatio(
                aspectRatio: 2,
                child: SizedBox.expand(
                  child: Card(
                    color: Colors.teal,
                    elevation: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        PlayerForm(
                          playerController: _firstPlayerNameController,
                          hintText: "First player",
                          player: "player1",
                        ),
                        PlayerForm(
                          playerController: _secondPlayerNameController,
                          hintText: "Second player",
                          player: "player2",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),


          // The submit button
          Padding(
            padding: EdgeInsets.all(Get.width / 24),
            child: AspectRatio(
              aspectRatio: 6,
              child: Card(
                color: Colors.teal,
                elevation: 3,
                child: ElevatedButton(
                  onPressed: () => _savePlayerName(
                      firstPlayerNameController: _firstPlayerNameController,
                      secondPlayerNameController: _secondPlayerNameController),
                  child: Text(
                    "Submit",
                    style: TextStyle(fontSize: Get.width / 18),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.teal,
                    ),
                    foregroundColor:
                    MaterialStateProperty.all<Color>(Get.theme.cardColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePlayerName(
      {@required TextEditingController firstPlayerNameController,
        @required TextEditingController secondPlayerNameController}) async {
    // Since the previous input may have been invalid then restore the default color of the field this time
    if (settings().firstPlayerInputInvalid)
      settings.update((settings) {
        settings.firstPlayerInputInvalid = false;
      });

    // Since the previous input may have been invalid then restore the default color of the field this time
    if (settings().secondPlayerInputInvalid)
      settings.update((settings) {
        settings.secondPlayerInputInvalid = false;
      });

    // Validate the input
    if (firstPlayerNameController.value.text == null ||
        firstPlayerNameController.value.text == "") {
      settings.update((settings) {
        settings.firstPlayerInputInvalid = true;
      });
    }

    // Validate the input for second player form
    if (secondPlayerNameController.value.text == null ||
        secondPlayerNameController.value.text == "") {
      settings.update((settings) {
        settings.secondPlayerInputInvalid = true;
      });
    }

    // Don't update the names if one of the or both inputs is invalid
    if (settings().firstPlayerInputInvalid ||
        settings().secondPlayerInputInvalid) return;

    // Update the name values
    await SharedPreferences.getInstance().then(
            (prefs) => prefs.setString("player1", firstPlayerNameController.text));

    await SharedPreferences.getInstance().then(
            (prefs) => prefs.setString("player2", secondPlayerNameController.text));

    // clear the fields
    firstPlayerNameController.clear();
    secondPlayerNameController.clear();

    // Show the done message
    showSnack(
        title: "Change Names",
        message: "Names have been successfully changed",
        side: SnackPosition.BOTTOM);
  }
}

// Implementation of the player form
class PlayerForm extends StatelessWidget {
  final TextEditingController playerController;
  final String hintText;
  final player;
  PlayerForm({
    Key key,
    @required this.playerController,
    @required this.hintText,
    @required this.player,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: Get.width / 36, left: Get.width / 36),
      child: Obx(
            () => TextFormField(
          controller: playerController,
          maxLength: 20,
          decoration: InputDecoration(
            errorText: settings.value.isInputInvalid(player)
                ? "Ever seen a person without a name? "
                : null,
            counterText: "", // Don't show the counter
            filled: true,
            fillColor: Theme.of(context).cardColor,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: settings.value.isInputInvalid(player)
                    ? Theme.of(context).errorColor
                    : Theme.of(context).cardColor,
              ),
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}