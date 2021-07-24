import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartPageBanner extends StatelessWidget {
  final width;
  final height;
  const StartPageBanner({Key key, @required this.width, @required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // A little bit spacing
        Container(
          alignment: Alignment.center,
          width: width,
          height: width / 12,
        ),

        Container(
          alignment: Alignment.center,
          width: width,
          height: height / 6,

          //The banner itself
          child: SizedBox.expand(
            child: Card(
              color: ThemeData(primarySwatch: Colors.green).primaryColorLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(width / 36),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.clear,
                      color:
                      Colors.teal,
                      size: width / 10,
                    ),
                    Text(
                      "KATAKUTI",
                      style: GoogleFonts.amiri(
                        color: Colors.teal,
                        fontSize: width / 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: width / 36,
                      ),
                    ),
                    Icon(
                      Icons.radio_button_unchecked_rounded,
                      color:
                      Colors.teal,
                      size: width / 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
