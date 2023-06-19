import 'package:flutter/material.dart';

import 'package:fusage/extra/enums.dart';

import 'package:provider/provider.dart';
import 'package:fusage/context/vehicles.dart';

import 'package:fusage/screens/subpages/tanks.dart';
import 'package:fusage/components/dialog/dialog_box.dart';
import 'package:fusage/components/widgets/input_field.dart';
import 'package:fusage/components/page_template.dart';
import 'package:fusage/components/widgets/vehicle_widget.dart';
import 'package:fusage/components/widgets/dropdown_button.dart';

class Cars extends PageTemplateBase {
  Cars({Key? key})
      : super(
            pageTitle: 'Vehicles',
            navigationData: NavigationData(
                navigationIcon: Icons.directions_car_sharp,
                navigationLabel: 'Vehicles'),
            key: key);

  @override
  CarsState createState() => CarsState();
}

class CarsState extends PageTemplate {
  static const List<String> fuelTypes = ['Gasoline', 'Diesel', 'LPG'];

  String newCarName = '';
  VehicleFuelTypeEnum fuelType = VehicleFuelTypeEnum.none;
  bool buttonTapped = false;
  List<VehicleElement> vehiclesList = [];

  void selectCar(BuildContext ctx, int vehicleID) async {
    VehicleProvider vehProvider =
        Provider.of<VehicleProvider>(ctx, listen: false);

    VehicleElement? currentVehicle = vehProvider.findVehicleByID(vehicleID);
    vehProvider.setCurrentVehicle(currentVehicle);

    if (currentVehicle != null) {
      bool shouldRefresh = await Navigator.of(ctx).push(MaterialPageRoute(
          builder: (ctx) => Tanks(vehicleName: currentVehicle.vehicleName)));

      if (shouldRefresh) {
        setState(() {}); // Just for refresh state
      }
    }
  }

  void addToContext(BuildContext ctx, void Function(void Function()) newState) {
    if (newCarName.isNotEmpty && fuelType != VehicleFuelTypeEnum.none) {
      VehicleProvider vehProvider =
          Provider.of<VehicleProvider>(ctx, listen: false);

      List<VehicleElement> newList = vehProvider.add(VehicleElement(
          vehicleID: vehProvider.generateNewVehicleID(vehiclesList),
          vehicleName: newCarName,
          isPrimary: vehProvider.vehicles.isEmpty,
          fuelType: fuelType));

      newState(() {
        newCarName = '';
        vehiclesList = newList;
      });

      Navigator.of(ctx).pop();
    }
  }

  void addAction(BuildContext mainContext) async {
    await showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (stateContext, newState) {
            return DialogBox(
                type: DialogBoxType.custom,
                title: 'Add Car',
                content: [
                  InputField(
                    labelText: 'Name',
                    isEmpty: buttonTapped && newCarName.isEmpty,
                    paddingInside: true,
                    onChanged: (value) => setState(() {
                      if (value.isNotEmpty) {
                        newCarName = value;
                      }
                    }),
                  ),
                  ExtraDropdownButton(
                    hintText: 'Fuel Type',
                    initialValue: fuelType != VehicleFuelTypeEnum.none
                        ? EnumConverter.vehicleFuelEnumToString(fuelType, false)
                        : null,
                    isEmpty:
                        buttonTapped && fuelType == VehicleFuelTypeEnum.none,
                    items: fuelTypes.map((e) {
                      return DropdownMenuItem(
                          value: e,
                          child: Text(e,
                              style: const TextStyle(color: Colors.white)));
                    }).toList(),
                    onChanged: (value) {
                      if (value!.isNotEmpty) {
                        newState(() {
                          fuelType =
                              EnumConverter.stringToVehicleFuelEnum(value);
                        });
                      }
                    },
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextButton(
                          onPressed: () {
                            addToContext(mainContext, newState);
                            newState(() {
                              buttonTapped = true;
                            });
                          },
                          child: const Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Add Car'))))
                ]);
          });
        }).then((value) {
      setState(() {
        buttonTapped = false;
      });
    });
  }

  void updateList(List<VehicleElement> newList) async {
    setState(() {
      vehiclesList = newList;
    });
  }

  List<Widget> drawChildrens(BuildContext ctx) {
    Iterable<VehicleWidget> vehList = vehiclesList.map((e) => VehicleWidget(
          isPrimary: e.isPrimary,
          vehicleID: e.vehicleID,
          fuelType: e.fuelType,
          totalDistance: e.totalDistance,
          onTap: (vehicleId) => selectCar(ctx, vehicleId),
          onUpdate: (newList) => updateList(newList),
        ));

    return vehList.toList();
  }

  @override
  void initState() {
    VehicleProvider? vehProvider =
        Provider.of<VehicleProvider>(context, listen: false);

    setState(() {
      vehiclesList = vehProvider.vehicles;
    });

    super.initState();
  }

  @override
  FloatingActionButton? floatingButton(BuildContext context) {
    return FloatingActionButton(
        onPressed: () {
          setState(() {
            fuelType = VehicleFuelTypeEnum.none;
          });
          addAction(context);
        },
        backgroundColor: const Color.fromRGBO(20, 30, 48, 1.0),
        child: const Icon(Icons.add, size: 24, color: Colors.white));
  }

  @override
  Widget pageBody(BuildContext context) {
    if (vehiclesList.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height - 172.2,
        child: const Center(
          child: Text('Nothing here :(\nAdd Your first car!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w400)),
        ),
      );
    }

    return Wrap(
      spacing: 15,
      runSpacing: 15,
      children: drawChildrens(context),
    );
  }
}
