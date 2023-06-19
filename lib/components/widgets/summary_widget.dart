import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum SummaryWidgetType {
  widgetKilometers,
  widgetLiters,
  widgetTime,
  widgetCosts,
  widgetTanks,
  widgetCars
}

class SummaryWidget extends StatelessWidget {
  final SummaryWidgetType widgetType;
  final String widgetLabel;
  final String widgetValue;

  const SummaryWidget(
      {Key? key,
      required String label,
      required String value,
      required SummaryWidgetType type})
      : widgetLabel = label,
        widgetValue = value,
        widgetType = type,
        super(key: key);

  Widget drawIcon() {
    switch (widgetType) {
      case SummaryWidgetType.widgetKilometers:
        return const Icon(
          Icons.near_me_outlined,
          color: Colors.white,
          size: 42,
        );

      case SummaryWidgetType.widgetLiters:
        return SvgPicture.asset(
          'assets/icons/fuel.svg',
          width: 42,
          color: Colors.white,
          height: 42,
        );

      case SummaryWidgetType.widgetTime:
        return const Icon(
          Icons.access_time,
          color: Colors.white,
          size: 42,
        );

      case SummaryWidgetType.widgetCosts:
        return const Icon(
          Icons.wallet_outlined,
          color: Colors.white,
          size: 42,
        );

      case SummaryWidgetType.widgetTanks:
        return SvgPicture.asset(
          'assets/icons/tank.svg',
          width: 42,
          color: Colors.white,
          height: 42,
        );

      case SummaryWidgetType.widgetCars:
        return const Icon(
          Icons.directions_car_sharp,
          color: Colors.white,
          size: 42,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 165,
        height: 165,
        child: Container(
          decoration: const BoxDecoration(
              color: Color.fromARGB(50, 6, 11, 24),
              borderRadius: BorderRadius.all(Radius.circular(25))),
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Column(children: [
                drawIcon(),
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(widgetLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        )))
              ]),
              Expanded(
                  child: Container(
                      alignment: Alignment.bottomCenter,
                      child: Text(widgetValue,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 18))))
            ],
          ),
        ));
  }
}
