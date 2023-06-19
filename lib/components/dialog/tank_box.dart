import 'package:flutter/material.dart';
import 'package:fusage/components/widgets/switch.dart';

import 'package:provider/provider.dart';

import 'package:fusage/components/widgets/dropdown_button.dart';
import 'package:fusage/components/dialog/dialog_box.dart';
import 'package:fusage/components/widgets/input_field.dart';
import 'package:fusage/context/settings.dart';

import 'package:fusage/extra/enums.dart';

enum TankBoxType { update, add }

class TankBox extends StatefulWidget {
  final TankBoxType type;

  final DateTime currentDate;
  final double liters;
  final double distance;
  final double fuelPrice;
  final RouteTypeEnum routeType;

  final Function() onSelectDate;
  final Function(String newValue) onLitersChange;
  final Function(String newValue) onDistanceChange;
  final Function(String? newValue) onRouteTypeChange;
  final Function(String newValue) onPriceChange;
  final Function(bool newValue) onConsumptionSwitch;
  final Function(bool newValue) onManualConsumptionToggle;
  final Function(String newValue) onConsumptionChange;
  final Function(double calculatedConsumption) onSubmit;

  final double fuelConsumption;
  final bool isLitersEmpty;
  final bool isDistanceEmpty;
  final bool isPriceEmpty;
  final bool calculateConsumption;
  final bool isManualConsumption;
  final bool isManualConsumptionEmpty;

  const TankBox(
      {super.key,
      required this.type,
      required this.currentDate,
      required this.onSelectDate,
      required this.onDistanceChange,
      required this.onRouteTypeChange,
      required this.onPriceChange,
      required this.onLitersChange,
      required this.onConsumptionSwitch,
      required this.onManualConsumptionToggle,
      required this.onConsumptionChange,
      required this.onSubmit,
      required this.distance,
      required this.liters,
      required this.fuelConsumption,
      required this.fuelPrice,
      this.routeType = RouteTypeEnum.none,
      this.isDistanceEmpty = false,
      this.isLitersEmpty = false,
      this.isPriceEmpty = false,
      this.calculateConsumption = true,
      this.isManualConsumptionEmpty = false,
      this.isManualConsumption = false});

  @override
  TankBoxState createState() => TankBoxState();
}

class TankBoxState extends State<TankBox> {
  static const List<String> routeTypesList = [
    'None',
    'City',
    'Highway',
    'Combined'
  ];
  static const List<String> consumptionSettingTypes = ['Auto', 'Manual'];

  double distance = 0.0;
  double liters = 0.0;
  double price = 0.0;

  bool calculateConsumption = true;
  bool isManualConsumption = false;

  double currentConsumption = 0.0;
  bool autoConsumptionCalculate = true;

  void calculateUsage() {
    if (!isManualConsumption) {
      MetricTypeEnum metrictsType =
          Provider.of<SettingsProvider>(context, listen: false).metricType;

      doCalculate() {
        if (metrictsType == MetricTypeEnum.imperial) {
          String fixedUsage = (distance / liters).toStringAsFixed(2);

          return double.parse(fixedUsage);
        }

        String fixedUsage = ((liters / distance) * 100).toStringAsFixed(2);

        return double.parse(fixedUsage);
      }

      setState(() {
        if (liters > 0.0 && distance > 0.0) {
          currentConsumption = doCalculate();
        } else {
          currentConsumption = 0.0;
        }
      });
    }
  }

  double parseValue(String value) {
    if (value.isNotEmpty) {
      return double.parse(value);
    }

    return 0.0;
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      liters = widget.liters;
      distance = widget.distance;

      calculateConsumption = widget.calculateConsumption;

      if (widget.isManualConsumption) {
        currentConsumption = widget.fuelConsumption;
        autoConsumptionCalculate = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    return DialogBox(
        type: DialogBoxType.custom,
        title: widget.type == TankBoxType.add ? 'Add Tank' : 'Update Tank',
        content: [
          InkWell(
              onTap: widget.onSelectDate,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Icon(Icons.calendar_month_outlined,
                              size: 18, color: Colors.white38)),
                      Text(
                          'Date: ${widget.currentDate.day}/${widget.currentDate.month}/${widget.currentDate.year}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white38,
                              fontSize: 16))
                    ]),
              )),
          InputField(
            labelText: settingsProvider.metricType == MetricTypeEnum.metric
                ? 'Liters (dm3)'
                : 'Gallons (gal)',
            doubleNumber: true,
            isEmpty: widget.isLitersEmpty,
            paddingInside: true,
            initialValue: widget.type == TankBoxType.update
                ? widget.liters.toString()
                : '',
            onChanged: (value) {
              setState(() {
                liters = parseValue(value);
                calculateUsage();
              });

              widget.onLitersChange(value);
            },
          ),
          InputField(
            labelText: settingsProvider.metricType == MetricTypeEnum.metric
                ? 'Distance (km)'
                : 'Distance (miles)',
            doubleNumber: true,
            isEmpty: widget.isDistanceEmpty,
            paddingInside: true,
            initialValue: widget.type == TankBoxType.update
                ? widget.distance.toString()
                : '',
            onChanged: (value) {
              setState(() {
                distance = parseValue(value);
                calculateUsage();
              });

              widget.onDistanceChange(value);
            },
          ),
          InputField(
            labelText: 'Fuel Price (${settingsProvider.currencyType})',
            doubleNumber: true,
            isEmpty: widget.isPriceEmpty,
            paddingInside: true,
            initialValue: widget.type == TankBoxType.update
                ? widget.fuelPrice.toString()
                : '',
            onChanged: widget.onPriceChange,
          ),
          ExtraDropdownButton(
            hintText: 'Route Type (Optional)',
            textSize: 16,
            initialValue: widget.routeType != RouteTypeEnum.none
                ? EnumConverter.routeTypeEnumToString(widget.routeType)
                : null,
            items: routeTypesList.map((e) {
              return DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white)));
            }).toList(),
            onChanged: widget.onRouteTypeChange,
          ),
          SwitchButton(
            defaultValue: widget.calculateConsumption,
            label: 'Consumption',
            onChanged: (value) {
              setState(() {
                calculateConsumption = value;
              });

              widget.onConsumptionSwitch(value);
            },
          ),
          calculateConsumption
              ? ExtraDropdownButton(
                  hintText: 'Auto Calculate',
                  textSize: 16,
                  initialValue: consumptionSettingTypes[0],
                  items: consumptionSettingTypes.map((e) {
                    return DropdownMenuItem(
                        value: e,
                        child: Text(e,
                            style: const TextStyle(color: Colors.white)));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      autoConsumptionCalculate = value == 'Auto';
                    });

                    widget.onManualConsumptionToggle(!autoConsumptionCalculate);
                  },
                )
              : Container(),
          !autoConsumptionCalculate
              ? InputField(
                  labelText: 'Enter Consumption',
                  doubleNumber: true,
                  isEmpty: widget.isManualConsumptionEmpty,
                  paddingInside: true,
                  onChanged: (value) {
                    widget.onConsumptionChange(value);
                  },
                )
              : Container(),
          (calculateConsumption && autoConsumptionCalculate)
              ? Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(
                      '$currentConsumption ${settingsProvider.metricType == MetricTypeEnum.metric ? 'L' : 'gal'}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white60,
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      )))
              : Container(),
          Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(
                  onPressed: () => widget.onSubmit(currentConsumption),
                  child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        widget.type == TankBoxType.add
                            ? 'Add Tank'
                            : 'Update Tank',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                        ),
                      ))))
        ]);
  }
}
