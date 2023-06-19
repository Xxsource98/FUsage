import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:fusage/context/settings.dart';
import 'package:fusage/context/vehicles.dart';

import 'package:fusage/components/dialog/dialog_box.dart';
import 'package:fusage/components/widgets/input_field.dart';
import 'package:fusage/components/modal_bottom_sheet.dart';
import 'package:fusage/components/widgets/widget_base.dart';
import 'package:fusage/components/widgets/dropdown_button.dart';

import 'package:fusage/extra/enums.dart';
import 'package:fusage/extra/date_functions.dart';

class VehicleWidget extends WidgetBase {
  final bool isPrimary;
  final double totalDistance;
  final VehicleFuelTypeEnum fuelType;
  final Function(int vehicleID) onTap;
  final Function(List<VehicleElement> newList) onUpdate;

  const VehicleWidget(
      {Key? key,
      required super.vehicleID,
      required this.fuelType,
      required this.onTap,
      required this.totalDistance,
      required this.onUpdate,
      this.isPrimary = false})
      : super(key: key);

  @override
  VehicleWidgetState createState() => VehicleWidgetState();
}

class VehicleWidgetState extends WidgetTemplate<VehicleWidget> {
  static const List<String> fuelTypes = ['Gasoline', 'Diesel', 'LPG'];

  String newVehicleName = 'Invalid';
  VehicleFuelTypeEnum newFuelType = VehicleFuelTypeEnum.none;

  void deleteVehicle(BuildContext ctx) {
    showDialog(
        context: context,
        builder: (builderCtx) {
          return DialogBox(
            title: 'Are You Sure?',
            onConfirm: () {
              VehicleProvider vehProvider =
                  Provider.of<VehicleProvider>(ctx, listen: false);
              VehicleElement? currentVehicle =
                  vehProvider.findVehicleByID(widget.vehicleID ?? 0);

              if (currentVehicle != null) {
                List<VehicleElement> newList =
                    vehProvider.remove(currentVehicle);

                widget.onUpdate(newList);
              }

              Navigator.of(ctx).pop();
            },
          );
        });
  }

  VehicleProvider geVehicleProvider(BuildContext ctx) {
    return Provider.of<VehicleProvider>(ctx, listen: false);
  }

  void updateVehicle(BuildContext ctx) {
    VehicleProvider vehProvider = geVehicleProvider(ctx);
    VehicleElement? currentVehicle =
        vehProvider.findVehicleByID(widget.vehicleID ?? 0);

    if (currentVehicle != null) {
      List<VehicleElement> newList = vehProvider.updateVehicle(
          currentVehicle, newFuelType, newVehicleName);

      widget.onUpdate(newList);
    }

    Navigator.of(ctx).pop();
  }

  void updateVehicleDialog(BuildContext context) {
    VehicleProvider vehProvider = geVehicleProvider(context);
    VehicleElement? currentVehicle =
        vehProvider.findVehicleByID(widget.vehicleID ?? 0);

    showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (stateContext, newState) {
            return DialogBox(
              type: DialogBoxType.custom,
              title: 'Update Vehicle',
              content: [
                InputField(
                  initialValue: currentVehicle!.vehicleName,
                  labelText: 'New Name',
                  paddingInside: true,
                  onChanged: (value) {
                    newState(() {
                      if (value.isNotEmpty) {
                        newVehicleName = value;
                      }
                    });
                  },
                ),
                ExtraDropdownButton(
                  hintText: 'New Fuel Type',
                  initialValue: widget.fuelType != VehicleFuelTypeEnum.none
                      ? EnumConverter.vehicleFuelEnumToString(
                          widget.fuelType, false)
                      : null,
                  items: fuelTypes.map((e) {
                    return DropdownMenuItem(
                        value: e,
                        child: Text(e,
                            style: const TextStyle(color: Colors.white)));
                  }).toList(),
                  onChanged: (value) {
                    if (value!.isNotEmpty) {
                      newState(() {
                        newFuelType =
                            EnumConverter.stringToVehicleFuelEnum(value);
                      });
                    }
                  },
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextButton(
                        onPressed: () {
                          updateVehicle(ctx);
                        },
                        child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              'Update Vehicle',
                              style: TextStyle(
                                fontFamily: 'Inter',
                              ),
                            ))))
              ],
            );
          });
        });
  }

  void setPrimary(BuildContext ctx) {
    VehicleProvider vehProvider =
        Provider.of<VehicleProvider>(ctx, listen: false);
    VehicleElement? currentVehicle =
        vehProvider.findVehicleByID(widget.vehicleID ?? 0);

    if (currentVehicle != null) {
      List<VehicleElement> newList = vehProvider.setPrimary(currentVehicle);
      widget.onUpdate(newList);

      Navigator.of(ctx).pop();
    }
  }

  String getLastTank(BuildContext ctx) {
    VehicleProvider vehProvider =
        Provider.of<VehicleProvider>(ctx, listen: false);
    VehicleElement? currentVehicle =
        vehProvider.findVehicleByID(widget.vehicleID ?? 0);

    if (currentVehicle!.tanks.isNotEmpty) {
      return getLastDateString(currentVehicle.tanks[0].tankDate);
    }

    return 'Never';
  }

  @override
  void initState() {
    VehicleProvider vehProvider =
        Provider.of<VehicleProvider>(context, listen: false);
    VehicleElement? currentVehicle =
        vehProvider.findVehicleByID(widget.vehicleID ?? 0);

    setState(() {
      newVehicleName =
          currentVehicle != null ? currentVehicle.vehicleName : "Invalid";
      newFuelType = widget.fuelType;
    });

    super.initState();
  }

  @override
  List<ModalBottomSheetElement> widgetSheetElements(BuildContext context) {
    List<ModalBottomSheetElement> bottomElements = [
      ModalBottomSheetElement(
          label: 'Edit',
          icon: Icons.edit,
          onPress: () => updateVehicleDialog(context)),
      ModalBottomSheetElement(
          label: 'Delete',
          icon: Icons.delete_outline,
          onPress: () => deleteVehicle(context)),
    ];

    if (!widget.isPrimary) {
      bottomElements.add(
        ModalBottomSheetElement(
            label: 'Set Primary',
            icon: Icons.star_border,
            onPress: () => setPrimary(context)),
      );
    }

    return bottomElements;
  }

  @override
  void onPress(BuildContext context, int vehicleId) => widget.onTap(vehicleId);

  @override
  Widget widgetBody() {
    VehicleProvider vehProvider =
        Provider.of<VehicleProvider>(context, listen: false);
    VehicleElement? currentVehicle =
        vehProvider.findVehicleByID(widget.vehicleID ?? 0);

    String vehicleName = currentVehicle!.vehicleName;

    MetricTypeEnum metricType =
        Provider.of<SettingsProvider>(context, listen: false).metricType;
    String metric = metricType == MetricTypeEnum.metric ? 'km' : 'miles';
    String totalDistanceString =
        '${widget.totalDistance.toStringAsFixed(2)} $metric';
    String lastTank = getLastTank(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car,
                    size: 32,
                    color: widget.isPrimary
                        ? Colors.yellow.shade200
                        : Colors.blueGrey.shade600),
                Text(
                  EnumConverter.vehicleFuelEnumToString(widget.fuelType, true),
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      color: Colors.white60),
                )
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vehicleName,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Colors.white)),
                    Text(totalDistanceString,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.white60)),
                    Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text('Last Tank: $lastTank',
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.white60)))
                  ],
                )),
          ],
        ),
        const Icon(Icons.arrow_forward_ios, size: 26, color: Colors.white),
      ],
    );
  }
}
