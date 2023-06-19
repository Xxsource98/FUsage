import 'package:flutter/material.dart';

import 'package:fusage/components/widgets/input_field.dart';

enum ModalBottomSheetType { row, column }

class ModalBottomSheetElement extends StatelessWidget {
  final Function() onPressFunc;
  final String title;
  final IconData elementIcon;

  const ModalBottomSheetElement(
      {Key? key,
      required String label,
      required IconData icon,
      required Function() onPress})
      : title = label,
        elementIcon = icon,
        onPressFunc = onPress,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
        size: const Size(75, 75),
        child: ClipOval(
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                    onTap: onPressFunc,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          elementIcon,
                          size: 32,
                          color: Colors.white70,
                        ),
                        Text(title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ))
                      ],
                    )))));
  }
}

class ModalBottomSheet extends StatelessWidget {
  final List<Widget> sheetElements;
  final ModalBottomSheetType type;
  final bool searchInput;
  final Function(String input)? onSearchChange;

  const ModalBottomSheet(
      {Key? key,
      required this.sheetElements,
      this.type = ModalBottomSheetType.row,
      this.searchInput = false,
      this.onSearchChange})
      : super(key: key);

  Widget drawBody() {
    if (type == ModalBottomSheetType.row) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: sheetElements,
      );
    }

    if (searchInput && onSearchChange != null) {
      return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: InputField(
              labelText: 'Find Value',
              onChanged: (value) => onSearchChange!(value)),
        ),
        Expanded(
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: sheetElements,
                )))
      ]);
    }

    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: sheetElements,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: type == ModalBottomSheetType.column && sheetElements.length > 2
            ? 250
            : 100,
        color: const Color.fromRGBO(20, 30, 48, 1.0),
        child: drawBody());
  }
}
