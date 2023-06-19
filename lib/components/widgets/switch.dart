import 'package:flutter/material.dart';

class SwitchButton extends StatefulWidget {
  final bool? defaultValue;
  final String label;
  final Function(bool value) onChanged;

  const SwitchButton(
      {super.key,
      this.defaultValue,
      required this.label,
      required this.onChanged});

  @override
  SwitchButtonState createState() => SwitchButtonState();
}

class SwitchButtonState extends State<SwitchButton> {
  bool toggleValue = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      toggleValue = widget.defaultValue ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
      value: toggleValue,
      onChanged: (value) {
        setState(() {
          toggleValue = value;
        });

        widget.onChanged(value);
      },
      title: const Text('Consumption',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white60,
            fontSize: 16,
          )),
    );
  }
}
