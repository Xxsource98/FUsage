import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

enum SettingComponentType { select, checkbox }

class SettingComponent extends StatelessWidget {
  final SettingComponentType type;
  final String label;
  final Function(BuildContext context)? onPress;
  final String? selectValue;

  const SettingComponent(
      {Key? key,
      this.type = SettingComponentType.select,
      required this.label,
      this.onPress,
      this.selectValue})
      : super(key: key);

  Widget drawChild() {
    if (type == SettingComponentType.select) {
      return AutoSizeText(selectValue ?? '',
          maxLines: 1,
          style: const TextStyle(
            color: Colors.white70,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w200,
            fontSize: 14,
          ));
    }

    return Checkbox(value: false, onChanged: (value) {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onPress != null ? () => onPress!(context) : null,
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(
                      label,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w200,
                        fontSize: 16,
                      ),
                    ),
                    Center(child: drawChild())
                  ],
                ))));
  }
}

class SettingBottomSheetElement extends StatelessWidget {
  final String label;
  final Widget? icon;
  final Function() onTap;

  const SettingBottomSheetElement(
      {Key? key, required this.label, this.icon, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: AutoSizeText(label,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w200,
            fontSize: 16,
          )),
      leading: icon,
    );
  }
}
