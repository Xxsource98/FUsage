import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import 'package:provider/provider.dart';
import 'package:fusage/context/vehicles.dart';

import 'package:fusage/components/dialog/tank_box.dart';
import 'package:fusage/components/subpage_template.dart';
import 'package:fusage/components/widgets/tank_widget.dart';

import 'package:fusage/extra/enums.dart';

class Tanks extends SubpageTemplateBase {
  final String vehicleName;
  const Tanks({Key? key, required this.vehicleName})
      : super(key: key, title: vehicleName);

  @override
  TanksState createState() => TanksState();
}

class TanksState extends SubpageTemplate {
  List<TankElement> tanksList = [];
  bool buttonTapped = false;

  double liters = 0.0;
  double distance = 0.0;
  double price = 0.0;
  RouteTypeEnum routeTypeEnum = RouteTypeEnum.none;
  DateTime dateTime = DateTime.now();

  double newCustomConsumption = 0.0;
  bool calculateConsumption = true;
  bool isManualConsumption = false;

  int currentLazyListSize = 20;

  Future<void> selectDate(void Function(void Function()) newState) async {
    DateTime? newDate = await showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: DateTime(1900),
        lastDate: DateTime(2420));

    if (newDate == null) return;

    newState(() {
      dateTime = newDate;
    });
  }

  void addTank(BuildContext ctx, void Function(void Function()) newState) {
    if (distance != 0.0 &&
        liters != 0.0 &&
        (isManualConsumption ? newCustomConsumption != 0.0 : true)) {
      VehicleProvider vehProvider =
          Provider.of<VehicleProvider>(ctx, listen: false);
      VehicleElement? currentVehicle = vehProvider.currentVehicle;

      if (currentVehicle != null) {
        TankElement tankElement = TankElement(dateTime, distance, liters,
            newCustomConsumption, price, routeTypeEnum, calculateConsumption);

        List<TankElement> newList =
            vehProvider.addTank(currentVehicle, tankElement);

        newState(() {
          tanksList = newList;

          // Reset Variables
          liters = 0.0;
          distance = 0.0;
          dateTime = DateTime.now();
          price = 0.0;
          newCustomConsumption = 0.0;
          calculateConsumption = true;
          isManualConsumption = false;
          routeTypeEnum = RouteTypeEnum.none;
        });

        Navigator.of(ctx).pop();
      }
    }
  }

  double parseValue(String value) {
    if (value.isNotEmpty) {
      return double.parse(value);
    }

    return 0.0;
  }

  void addAction() async {
    await showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (stateContext, newState) {
            return TankBox(
              type: TankBoxType.add,
              currentDate: dateTime,
              liters: liters,
              distance: distance,
              fuelConsumption: newCustomConsumption,
              isManualConsumption: isManualConsumption,
              fuelPrice: price,
              onSubmit: (consumption) {
                newState(() {
                  if (!isManualConsumption) {
                    newCustomConsumption = consumption;
                  }
                  buttonTapped = true;
                });

                addTank(stateContext, newState);
              },
              onDistanceChange: (newValue) => newState(() {
                distance = parseValue(newValue);
              }),
              onLitersChange: (newValue) => newState(() {
                liters = parseValue(newValue);
              }),
              onRouteTypeChange: (newValue) => newState(() {
                routeTypeEnum = EnumConverter.stringToRouteTypeEnum(newValue!);
              }),
              onPriceChange: (newValue) => newState(() {
                price = parseValue(newValue);
              }),
              onSelectDate: () => selectDate(newState),
              onConsumptionSwitch: (newValue) => newState(() {
                calculateConsumption = newValue;
              }),
              onManualConsumptionToggle: (newValue) => newState(() {
                isManualConsumption = newValue;
              }),
              onConsumptionChange: (newValue) => newState(() {
                newCustomConsumption = parseValue(newValue);
              }),
              isManualConsumptionEmpty: buttonTapped &&
                  isManualConsumption &&
                  newCustomConsumption == 0.0,
              isDistanceEmpty: buttonTapped && distance == 0.0,
              isLitersEmpty: buttonTapped && liters == 0.0,
              isPriceEmpty: buttonTapped && price == 0.0,
            );
          });
        }).then((value) {
      setState(() {
        buttonTapped = false;
      });
    });
  }

  List<Widget> drawChildrens(BuildContext ctx) {
    VehicleElement? currentVehicle =
        Provider.of<VehicleProvider>(ctx, listen: false).currentVehicle;

    if (currentVehicle != null) {
      Iterable<TankWidget> vehList = tanksList.map((e) => TankWidget(
          currentConsumption: e.currentConsumption,
          routeType: e.routeType,
          distance: e.distance,
          liters: e.liters,
          fuelPrice: e.price,
          calculateConsumption: e.calculateConsumption,
          dateTime: e.tankDate,
          onUpdate: (newList) => setState(() {
                tanksList = newList;
              })));

      return vehList.toList();
    }

    return [];
  }

  void loadMoreTanks() {
    int newTanksSize = tanksList.length + 10;
    int newLazySize = currentLazyListSize + 10;

    if (newTanksSize < newLazySize) {
      setState(() {
        currentLazyListSize = tanksList.length;
      });
    } else {
      setState(() {
        currentLazyListSize = newLazySize;
      });
    }
  }

  @override
  void initState() {
    VehicleElement? currentVehicle =
        Provider.of<VehicleProvider>(context, listen: false).currentVehicle;

    if (currentVehicle != null) {
      setState(() {
        tanksList = currentVehicle.tanks.toList();
      });
    }

    super.initState();
  }

  @override
  FloatingActionButton? floatingButton() {
    return FloatingActionButton(
        onPressed: addAction,
        backgroundColor: const Color.fromRGBO(20, 30, 48, 1.0),
        child: const Icon(Icons.add, size: 24, color: Colors.white));
  }

  @override
  Widget pageBody(BuildContext context) {
    List<Widget> tanks = drawChildrens(context);

    if (tanksList.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height - 172.2,
        child: const Center(
          child: Text('Nothing here :(\nAdd Your first tank!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w400)),
        ),
      );
    }

    return SizedBox(
        // I used Windows for main test platform but on phone there is another media query height
        height: Platform.isWindows
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.height - 172.2,
        child: LazyLoadScrollView(
            onEndOfPage: loadMoreTanks,
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: tanksList.length > currentLazyListSize
                    ? currentLazyListSize
                    : tanksList.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: tanks[index]);
                })));
  }
}
