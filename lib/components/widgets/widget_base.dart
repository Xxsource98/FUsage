import 'package:flutter/material.dart';

import 'package:fusage/components/modal_bottom_sheet.dart';

abstract class WidgetBase extends StatefulWidget {
  final int? vehicleID;

  const WidgetBase({Key? key, this.vehicleID}) : super(key: key);
}

abstract class WidgetTemplate<T extends WidgetBase> extends State<T> {
  void displayBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return ModalBottomSheet(
            sheetElements: widgetSheetElements(ctx),
          );
        });
  }

  @protected
  @override
  void initState();

  @protected
  List<ModalBottomSheetElement> widgetSheetElements(BuildContext context);

  @protected
  void onPress(BuildContext context, int vehicleId);

  @protected
  Widget widgetBody();

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onPress(context, widget.vehicleID ?? 0),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onLongPress: () => displayBottomSheet(context),
        child: Container(
            height: 90,
            decoration: const BoxDecoration(
              color: Color.fromARGB(50, 6, 11, 24),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Padding(
                padding: const EdgeInsets.all(15), child: widgetBody())));
  }
}
