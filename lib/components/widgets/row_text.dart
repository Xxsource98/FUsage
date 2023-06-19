import 'package:flutter/material.dart';

class RowText extends StatelessWidget {
  final String leftSide;
  final String rightSide;
  final bool spaceOnTop;
  final bool biggerText;

  const RowText(
      {Key? key,
      required this.leftSide,
      required this.rightSide,
      this.spaceOnTop = false,
      this.biggerText = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: spaceOnTop ? 20 : 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(leftSide,
                style: const TextStyle(
                    fontSize: 16, fontFamily: 'Inter', color: Colors.white)),
            Text(rightSide,
                style: TextStyle(
                    fontSize: biggerText ? 16 : 14,
                    fontFamily: 'Inter',
                    color: Colors.white60)),
          ],
        ));
  }
}
