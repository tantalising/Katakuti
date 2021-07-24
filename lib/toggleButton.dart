import 'package:flutter/material.dart';
import 'package:katakuti/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToggleButton extends StatefulWidget {
  final Function onToggleOn;
  final Function onToggleOff;
  final Function buttonSize;
  final String buttonId;

  ToggleButton({
    Key key,
    @required this.onToggleOn,
    @required this.onToggleOff,
    @required this.buttonId,
    this.buttonSize,
  }) : super(key: key);

  _ToggleButtonState state = _ToggleButtonState();
  @override
  _ToggleButtonState createState() => state;
}

class _ToggleButtonState extends State<ToggleButton> {
  @override
  Widget build(BuildContext context) {
    print("rebuilding");
    double size = widget.buttonSize == null
        ? MediaQuery.of(context).size.width / 6
        : widget.buttonSize;

    bool toggled;
    if (widget.buttonId == "darkMode")
      toggled = settings.value.isToggled;
    else if (widget.buttonId == "computer")
      toggled = settings.value.doesComputerPlayFirst;

    return Container(
      alignment: Alignment.topRight,
      child: InkWell(
        splashColor: Colors.transparent,
        child: !toggled
            ? Icon(
                Icons.toggle_off_outlined,
                size: size,
              )
            : Icon(
                Icons.toggle_on,
                size: size,
              ),
        onTap: onPressed,
      ),
    );
  }

  void onPressed() async {
    if (widget.buttonId == "darkMode") {
      print("changing theme");
      settings.update((settings) {
        settings.isToggled = !settings.isToggled;
      });

      if (settings.value.isToggled) {
        print("on");
        widget.onToggleOn();
      } else {
        print("off");
        widget.onToggleOff();
      }

      await SharedPreferences.getInstance().then(
          (prefs) => prefs.setBool("isDarkMode", settings.value.isToggled));

    } else if (widget.buttonId == "computer") {
      settings.update((settings) {
        settings.doesComputerPlayFirst = !settings.doesComputerPlayFirst;
      });

      await SharedPreferences.getInstance().then((prefs) =>
          prefs.setBool("computerPlay", settings.value.doesComputerPlayFirst));

      await SharedPreferences.getInstance()
          .then((prefs) => prefs.setBool("isDarkMode", settings.value.isToggled));


      if (settings.value.doesComputerPlayFirst) {
        widget.onToggleOn();
      } else {
        widget.onToggleOff();
      }
    }
    setState(() {});
  }
}

class ThemeToggleButton extends StatelessWidget {
  final Function onToggleOn;
  final Function onToggleOff;
  final Function buttonSize;
  final String buttonId;

  ThemeToggleButton({
    Key key,
    @required this.onToggleOn,
    @required this.onToggleOff,
    @required this.buttonId,
    this.buttonSize,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    print("rebuilding");
    double size = buttonSize == null
        ? MediaQuery.of(context).size.width / 6
        : buttonSize;

    return Container(
      alignment: Alignment.topRight,
      child: InkWell(
        splashColor: Colors.transparent,
        child: !settings.value.isToggled
            ? Icon(
                Icons.toggle_off_outlined,
                size: size,
              )
            : Icon(
                Icons.toggle_on,
                size: size,
              ),
        onTap: onPressed,
      ),
    );
  }

  void onPressed() async {
    print("changing theme");
    settings.update((settings) {
      settings.isToggled = !settings.isToggled;
    });

    if (settings.value.isToggled) {
      print("on");
      onToggleOn();
    } else {
      print("off");
      onToggleOff();
    }

    await SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool("isDarkMode", settings.value.isToggled));

  }
}
