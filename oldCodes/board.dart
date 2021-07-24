import 'package:flutter/material.dart';
import 'package:katakuti/startPage.dart';
import 'guti.dart';


class Board extends StatelessWidget {

  final width;
  final height;

  const Board({Key key, @required this.width, @required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FrontPage(width: width, height: height, tableLength: 3, cellContentSupplier: cellContentSupplier,);
  }

  cellContentSupplier(context, cellId){
    return Guti(cellId: cellId);
  }
}


