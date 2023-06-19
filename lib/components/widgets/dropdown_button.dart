import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ExtraDropdownButton extends StatefulWidget {
  final String hintText;
  final String? initialValue;
  final Function(String? value) onChanged;
  final List<DropdownMenuItem> items;
  final bool isEmpty;
  final bool isRequired;
  final double textSize;

  const ExtraDropdownButton(
      {Key? key,
      required this.hintText,
      required this.onChanged,
      required this.items,
      this.initialValue,
      this.textSize = 15.0,
      this.isEmpty = false,
      this.isRequired = true})
      : super(key: key);

  @override
  ExtraDropdownButtonState createState() => ExtraDropdownButtonState();
}

class ExtraDropdownButtonState extends State<ExtraDropdownButton> {
  TextEditingController inputController = TextEditingController();
  bool tapped = false;
  bool isEmpty = false;

  void checkIfNull() => tapped = true;

  void checkForWriting() {
    setState(() {
      isEmpty = inputController.text.isEmpty && tapped;
    });

    checkIfNull();
  }

  @override
  void initState() {
    inputController.addListener(checkForWriting);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField2(
          searchController: inputController,
          buttonHeight: 40,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(top: 10),
              labelStyle:
                  const TextStyle(fontFamily: 'Inter', color: Colors.white70),
              errorStyle:
                  TextStyle(fontFamily: 'Inter', color: Colors.red.shade400),
              errorText: (widget.isRequired && isEmpty) || widget.isEmpty
                  ? 'Field is Empty!'
                  : null),
          value: widget.initialValue,
          style: TextStyle(fontFamily: 'Inter', fontSize: widget.textSize),
          hint: Text(widget.hintText,
              style: const TextStyle(color: Colors.white38)),
          itemPadding: const EdgeInsets.symmetric(horizontal: 5),
          dropdownDecoration:
              const BoxDecoration(color: Color.fromRGBO(20, 30, 48, 1.0)),
          items: widget.items,
          onChanged: (value) => widget.onChanged(value)),
    );
  }
}
