import 'dart:convert';
import 'dart:io';

import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:fusage/context/settings.dart';
import 'package:fusage/context/vehicles.dart';
import 'package:fusage/extra/enums.dart';

class MainAppData {
  late List<VehicleElement> vehicles;
  late SettingDataType settings;

  MainAppData(List<VehicleElement> vehiclesList, SettingDataType settingsData) {
    vehicles = vehiclesList;
    settings = settingsData;
  }
}

class CreateBackupDataResult {
  bool success;
  String fileName;

  CreateBackupDataResult({
    required this.success,
    required this.fileName
  });
}

Future<MainAppData> loadFileData() async {
  List<VehicleElement> vehiclesList = await VehicleProvider.loadSavedData();
  SettingDataType settingsData = await SettingsProvider.loadSavedData();

  FlutterNativeSplash.remove();

  return MainAppData(vehiclesList, settingsData);
}

String backupFileJsonData(
    List<VehicleElement> vehiclesList, SettingDataType settingsData) {
  var json = {
    'settings': {
      'currencyType': settingsData.currencyType,
      'metricType':
          EnumConverter.metricTypeEnumToString(settingsData.metricType),
      'summaryTimeRange':
          EnumConverter.summaryRangeEnumToString(settingsData.summaryTimeRange)
    },
    'vehicles': vehiclesList.map((element) {
      return {
        'vehicleID': element.vehicleID,
        'vehicleName': element.vehicleName,
        'fuelType':
            EnumConverter.vehicleFuelEnumToString(element.fuelType, false),
        'isPrimary': element.isPrimary,
        'tanks': element.tanks.map((tank) {
          return {
            'tankDate': tank.tankDate.millisecondsSinceEpoch,
            'distance': tank.distance,
            'liters': tank.liters,
            'price': tank.price,
            'currentConsumption': tank.currentConsumption,
            'routeType': EnumConverter.routeTypeEnumToString(tank.routeType),
            'calculateConsumption': tank.calculateConsumption
          };
        }).toList()
      };
    }).toList()
  };

  return jsonEncode(json);
}

Future<CreateBackupDataResult> createBackupData(String fileDir, List<VehicleElement> vehiclesList,
    SettingDataType settingsData) async {
  String jsonData = backupFileJsonData(vehiclesList, settingsData);
  DateTime now = DateTime.now();
  String fileName = '${now.millisecondsSinceEpoch}.json';

  File file = await File('$fileDir/$fileName').create(recursive: true);

  bool status = await file
      .writeAsString(jsonData)
      .then((value) => true)
      .catchError((err, stackTrace) {
    throw Exception(err);
  });

  return CreateBackupDataResult(
    success: status, 
    fileName: fileName
  );
}

Future<dynamic> loadBackupData(String fileDir) async {
  File file = File(fileDir);

  if (await file.exists()) {
    String data = await file.readAsString();

    return jsonDecode(data);
  }

  return null;
}
