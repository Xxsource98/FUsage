import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatefulWidget {
  final String? initialValue;
  final bool doubleNumber;
  final String labelText;
  final Function(String value) onChanged;
  final bool isEmpty;
  final bool isRequired;
  final bool clearButton;
  final bool paddingInside;

  const InputField(
      {Key? key,
      required this.labelText,
      required this.onChanged,
      this.initialValue,
      this.doubleNumber = false,
      this.isEmpty = false,
      this.clearButton = false,
      this.paddingInside = false,
      this.isRequired = true})
      : super(key: key);

  @override
  InputFieldState createState() => InputFieldState();
}

class InputFieldState extends State<InputField> {
  TextEditingController textController = TextEditingController();
  bool tapped = false;
  bool isEmpty = false;

  void checkIfNull() => tapped = true;

  void checkForWriting() {
    setState(() {
      isEmpty = textController.text.isEmpty && tapped;
    });

    checkIfNull();
  }

  @override
  void initState() {
    if (widget.initialValue != null) {
      double? value = double.tryParse(widget.initialValue!);

      if (value != null && value == 0.0) {
        textController.text = '';
      } else {
        textController.text =
            widget.initialValue! == 'null' ? '' : widget.initialValue!;
      }
    } else {
      textController.clear();
    }

    textController.addListener(checkForWriting);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      expands: false,
      keyboardType: widget.doubleNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: widget.doubleNumber
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
          : [],
      style: const TextStyle(color: Colors.white),
      textCapitalization: widget.doubleNumber
          ? TextCapitalization.none
          : TextCapitalization.words,
      decoration: InputDecoration(
          contentPadding:
              widget.paddingInside ? const EdgeInsets.all(5) : EdgeInsets.zero,
          labelText: widget.labelText,
          labelStyle:
              const TextStyle(fontFamily: 'Inter', color: Colors.white38),
          errorStyle:
              TextStyle(fontFamily: 'Inter', color: Colors.red.shade400),
          errorText: (widget.isRequired && isEmpty) || widget.isEmpty
              ? 'Field is Empty!'
              : null),
      onTap: checkIfNull,
      onChanged: (value) {
        if (widget.doubleNumber) {
          if (value.isNotEmpty && double.tryParse(value) != null) {
            String fixedDouble = double.parse(value).toStringAsFixed(2);

            widget.onChanged(fixedDouble);
          } else {
            widget.onChanged('0.0');
          }
        } else {
          widget.onChanged(value);
        }
      },
    );
  }
}
