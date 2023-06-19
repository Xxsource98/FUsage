import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:provider/provider.dart';
import 'package:fusage/context/settings.dart';
import 'package:fusage/context/vehicles.dart';

import 'package:fusage/components/dialog/dialog_box.dart';
import 'package:fusage/components/dialog/tank_box.dart';
import 'package:fusage/components/modal_bottom_sheet.dart';
import 'package:fusage/components/widgets/row_text.dart';
import 'package:fusage/components/widgets/widget_base.dart';

import 'package:fusage/extra/enums.dart';

class TankWidget extends WidgetBase {
  final double liters;
  final double distance;
  final double currentConsumption;
  final double fuelPrice;
  final RouteTypeEnum routeType;
  final DateTime dateTime;
  final bool calculateConsumption;
  final Function(List<TankElement> newList) onUpdate;

  const TankWidget(
      {Key? key,
      required this.liters,
      required this.distance,
      required this.currentConsumption,
      required this.fuelPrice,
      required this.calculateConsumption,
      required this.dateTime,
      required this.onUpdate,
      this.routeType = RouteTypeEnum.none})
      : super(key: key);

  @override
  TankWidgetState createState() => TankWidgetState();
}

class TankWidgetState extends WidgetTemplate<TankWidget> {
  bool buttonTapped = false;
  double newLiters = 0.0;
  double newDistance = 0.0;
  RouteTypeEnum newRouteType = RouteTypeEnum.none;
  double newFuelPrice = 0.0;
  double totalPrice = 0.0;
  double pricePerUnit = 0.0;
  DateTime newDateTime = DateTime.now();

  bool calculateConsumption = false;
  bool isManualConsumption = false;
  double manualConsuptiom = 0.0;

  Future<void> selectDate(void Function(void Function()) newState) async {
    DateTime? newDate = await showDatePicker(
        context: context,
        initialDate: newDateTime,
        firstDate: DateTime(1900),
        lastDate: DateTime(2420));

    if (newDate == null) return;

    newState(() {
      newDateTime = newDate;
    });
  }

  void updateTank(BuildContext ctx) {
    if (newLiters > 0.0 && newDistance > 0.0) {
      VehicleProvider vehProvider =
          Provider.of<VehicleProvider>(context, listen: false);
      VehicleElement? currentVehicle = vehProvider.currentVehicle;

      if (currentVehicle != null) {
        TankElement? currentTank =
            vehProvider.findTank(currentVehicle, widget.dateTime);

        if (currentTank != null) {
          List<TankElement> newList = vehProvider.updateTank(
              currentVehicle,
              currentTank,
              TankElement(newDateTime, newDistance, newLiters, manualConsuptiom,
                  newFuelPrice, newRouteType, calculateConsumption));

          widget.onUpdate(newList.toList());

          Navigator.of(ctx).pop();
        }
      }
    }
  }

  void deleteTank(BuildContext ctx) {
    VehicleProvider vehProvider =
        Provider.of<VehicleProvider>(context, listen: false);
    VehicleElement? currentVehicle = vehProvider.currentVehicle;

    if (currentVehicle != null) {
      TankElement? currentTank =
          vehProvider.findTank(currentVehicle, widget.dateTime);

      if (currentTank != null) {
        showDialog(
            context: context,
            builder: (ctx) {
              return DialogBox(
                title: 'Are You Sure?',
                onConfirm: () {
                  List<TankElement> newList =
                      vehProvider.removeTank(currentVehicle, currentTank);

                  widget.onUpdate(newList.toList());

                  Navigator.of(context).pop();
                },
              );
            });
      }
    }
  }

  double parseValue(String value) {
    if (value.isNotEmpty) {
      return double.parse(value);
    }

    return 0.0;
  }

  void editTank(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (builderCtx) {
          return StatefulBuilder(builder: (stateContext, newState) {
            return TankBox(
                type: TankBoxType.update,
                currentDate: newDateTime,
                liters: widget.liters,
                distance: widget.distance,
                fuelPrice: widget.fuelPrice,
                routeType: widget.routeType,
                fuelConsumption: widget.currentConsumption,
                calculateConsumption: calculateConsumption,
                onSelectDate: () => selectDate(newState),
                onSubmit: (consumption) {
                  newState(() {
                    manualConsuptiom = consumption;
                    buttonTapped = true;
                  });

                  updateTank(stateContext);
                },
                onDistanceChange: (newValue) => newState(() {
                      newDistance = parseValue(newValue);
                    }),
                onLitersChange: (newValue) => newState(() {
                      newLiters = parseValue(newValue);
                      totalPrice = parseValue(
                          (newLiters * newFuelPrice).toStringAsFixed(2));
                    }),
                onRouteTypeChange: (newValue) => newState(() {
                      newRouteType =
                          EnumConverter.stringToRouteTypeEnum(newValue!);
                    }),
                onPriceChange: (newValue) => newState(() {
                      newFuelPrice = parseValue(newValue);
                      totalPrice = parseValue(
                          (newLiters * newFuelPrice).toStringAsFixed(2));
                    }),
                onConsumptionSwitch: (newValue) => newState(() {
                      calculateConsumption = newValue;
                    }),
                onManualConsumptionToggle: (newValue) => newState(() {
                      isManualConsumption = newValue;
                    }),
                onConsumptionChange: (newValue) => newState(() {
                      manualConsuptiom = parseValue(newValue);
                    }),
                isManualConsumptionEmpty: buttonTapped &&
                    isManualConsumption &&
                    manualConsuptiom == 0.0,
                isDistanceEmpty: buttonTapped && newDistance == 0.0,
                isLitersEmpty: buttonTapped && newLiters == 0.0,
                isPriceEmpty: buttonTapped && newFuelPrice == 0.0);
          });
        }).then((value) {
      setState(() {
        buttonTapped = false;
      });
    });
  }

  Color getColorType() {
    switch (widget.routeType) {
      case RouteTypeEnum.city:
        return Colors.green.shade300;
      case RouteTypeEnum.highway:
        return Colors.blue.shade300;
      case RouteTypeEnum.combined:
        return Colors.deepPurple.shade300;

      default:
        return Colors.blueGrey.shade600;
    }
  }

  void initVariables() {
    setState(() {
      newDateTime = widget.dateTime;
      newDistance = widget.distance;
      newLiters = widget.liters;
      newFuelPrice = widget.fuelPrice;
      newRouteType = widget.routeType;
      manualConsuptiom = widget.currentConsumption;
      calculateConsumption = widget.calculateConsumption;
    });
  }

  void calculatePrice() {
    double calculatedUnitPrice = ((newLiters / newDistance) * newFuelPrice);
    String fixedUnitPrice = calculatedUnitPrice.toStringAsFixed(2);

    setState(() {
      if (newLiters > 0.0 && newDistance > 0.0) {
        pricePerUnit = double.parse(fixedUnitPrice);
      }

      totalPrice = parseValue((newLiters * newFuelPrice).toStringAsFixed(2));
    });
  }

  @override
  List<ModalBottomSheetElement> widgetSheetElements(BuildContext context) {
    return [
      ModalBottomSheetElement(
          label: 'Edit', icon: Icons.edit, onPress: () => editTank(context)),
      ModalBottomSheetElement(
          label: 'Delete',
          icon: Icons.delete_outline,
          onPress: () => deleteTank(context)),
    ];
  }

  @override
  void onPress(BuildContext context, int vehicleId) {
    showDialog(
        context: context,
        builder: (ctx) {
          String currentCurrency =
              Provider.of<SettingsProvider>(context, listen: false)
                  .currencyType;
          MetricTypeEnum metricType =
              Provider.of<SettingsProvider>(context, listen: false).metricType;
          DateFormat formatter = DateFormat('dd.MM.yyyy');
          String formattedDate = formatter.format(widget.dateTime);

          String titleString = widget.currentConsumption != 0.0
              ? '${widget.currentConsumption} ${metricType == MetricTypeEnum.metric ? 'L' : 'gal'}'
              : formattedDate;

          return DialogBox(
            type: DialogBoxType.custom,
            title: calculateConsumption ? titleString : formattedDate,
            centreTitle: true,
            content: [
              RowText(leftSide: 'Date', rightSide: formattedDate),
              RowText(
                  leftSide: 'Fuel',
                  rightSide:
                      '${widget.liters} ${metricType == MetricTypeEnum.metric ? 'L' : 'gal'}'),
              RowText(
                  leftSide: 'Distance',
                  rightSide:
                      '${widget.distance} ${metricType == MetricTypeEnum.metric ? 'km' : 'miles'}'),
              RowText(
                  leftSide: 'Fuel Price',
                  rightSide: '${widget.fuelPrice} $currentCurrency'),
              RowText(
                  leftSide: 'Price', rightSide: '$totalPrice $currentCurrency'),
              RowText(
                  leftSide:
                      'Price per ${metricType == MetricTypeEnum.metric ? 'km' : 'mile'}',
                  rightSide: '~$pricePerUnit $currentCurrency'),
              widget.routeType != RouteTypeEnum.none
                  ? RowText(
                      leftSide: 'Route Type',
                      rightSide:
                          EnumConverter.routeTypeEnumToString(widget.routeType))
                  : Container(),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: IconButton(
                  splashRadius: 15.0,
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              )
            ],
          );
        });
  }

  @override
  Widget widgetBody() {
    initVariables();
    calculatePrice();

    DateFormat formatter = DateFormat('dd.MM.yyyy');
    MetricTypeEnum metricType =
        Provider.of<SettingsProvider>(context, listen: false).metricType;
    String consumptionString = widget.currentConsumption != 0.0
        ? '${widget.currentConsumption}${metricType == MetricTypeEnum.metric ? 'L' : 'gal'}'
        : '-';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: SvgPicture.asset('assets/icons/fuel.svg',
                        width: 26, height: 26, color: getColorType())),
                Text(consumptionString,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        color: Colors.white60))
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatter.format(widget.dateTime),
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Colors.white)),
                    Text('${widget.fuelPrice} PLN',
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.white60))
                  ],
                ))
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
                '${widget.liters} ${metricType == MetricTypeEnum.metric ? 'L' : 'gal'}',
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.white)),
            Text(
                '${widget.distance} ${metricType == MetricTypeEnum.metric ? 'km' : 'miles'}',
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.white60))
          ],
        )
      ],
    );
  }
}
