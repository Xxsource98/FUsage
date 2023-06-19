import 'dart:io';
import 'dart:convert';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fusage/context/settings.dart';

import 'package:fusage/extra/date_functions.dart';
import 'package:fusage/extra/enums.dart';

class VehicleElementDataType {
  double averageUsage = 0.0;
  double totalLiters = 0.0;
  int averageTankTime = 0;
  double averageCosts = 0.0;
  double totalDistance = 0.0;
  int totalTanks = 0;

  VehicleElementDataType(
      {required this.averageUsage,
      required this.totalLiters,
      required this.averageTankTime,
      required this.averageCosts,
      required this.totalDistance,
      required this.totalTanks});
}

class TankElement {
  DateTime tankDate;
  double distance;
  double liters;
  double currentConsumption;
  double price;
  bool calculateConsumption;

  RouteTypeEnum routeType = RouteTypeEnum.none;

  TankElement(
      this.tankDate,
      this.distance,
      this.liters,
      this.currentConsumption,
      this.price,
      this.routeType,
      this.calculateConsumption);

  static List<TankElement> getListFromTimeRange(
      List<TankElement> tanks, SummaryTimeRangeEnum timeRange) {
    DateTime currentDate = DateTime.now();
    DateTime lastWeek = DateTime.now().subtract(const Duration(days: 7));
    DateTime lastMonth = DateTime.now().subtract(const Duration(days: 30));

    return tanks.where((element) {
      switch (timeRange) {
        case SummaryTimeRangeEnum.month:
          {
            DateTime firstDay = getFirstDayOfTheMonth(element.tankDate);
            DateTime lastDay = getLastDayOfTheMonth(element.tankDate);

            return isDateInRange(currentDate, firstDay, lastDay);
          }

        case SummaryTimeRangeEnum.lastMonth:
          {
            DateTime firstDay = getFirstDayOfTheMonth(element.tankDate);
            DateTime lastDay = getLastDayOfTheMonth(element.tankDate);

            return isDateInRange(lastMonth, firstDay, lastDay);
          }

        case SummaryTimeRangeEnum.week:
          {
            DateTime firstDay = getFirstDayOfTheWeek(element.tankDate);
            DateTime lastDay = getLastDayOfTheWeek(element.tankDate);

            return isDateInRange(currentDate, firstDay, lastDay);
          }

        case SummaryTimeRangeEnum.lastWeek:
          {
            DateTime firstDay = getFirstDayOfTheWeek(element.tankDate);
            DateTime lastDay = getLastDayOfTheWeek(element.tankDate);

            return isDateInRange(lastWeek, firstDay, lastDay);
          }

        default:
          return true;
      }
    }).toList();
  }
}

class VehicleElement {
  int vehicleID;
  String vehicleName = '';
  VehicleFuelTypeEnum fuelType = VehicleFuelTypeEnum.none;
  bool isPrimary = false;
  List<TankElement> tanks = [];
  double totalDistance = 0.0;

  VehicleElement(
      {required this.vehicleID,
      required this.vehicleName,
      required this.fuelType,
      required this.isPrimary});

  VehicleElementDataType getSummaryInformation(SummaryTimeRangeEnum timeRange) {
    var averageUsage = getTotalAverageUsage(timeRange);
    var totalLiters = getTotalLiters(timeRange);
    var averageTankTime = getAverageTankTime(timeRange);
    var averageCosts = getAverageCosts(timeRange);
    var totalDistance = getTotalDistance(timeRange);
    var totalTanks = getTotalTanks(timeRange);

    return VehicleElementDataType(
      averageUsage: averageUsage,
      totalLiters: totalLiters,
      averageTankTime: averageTankTime,
      averageCosts: averageCosts,
      totalDistance: totalDistance,
      totalTanks: totalTanks,
    );
  }

  double getTotalAverageUsage(SummaryTimeRangeEnum timeRange) {
    List<TankElement> newTanksList =
        TankElement.getListFromTimeRange(tanks, timeRange);

    if (newTanksList.isNotEmpty) {
      newTanksList.removeWhere((element) => element.currentConsumption == 0.0);

      double sum = newTanksList.fold(0.0, (previousValue, element) {
        return double.parse((previousValue + element.currentConsumption)
            .toStringAsPrecision(2));
      });

      return double.parse((sum / newTanksList.length).toStringAsPrecision(2));
    }

    return 0.0;
  }

  int getAverageTankTime(SummaryTimeRangeEnum timeRange) {
    List<TankElement> newTanksList =
        TankElement.getListFromTimeRange(tanks, timeRange);

    if (newTanksList.isNotEmpty) {
      int result = 0;

      DateTime? prevDate;

      for (var element in newTanksList) {
        if (prevDate == null) {
          prevDate = element.tankDate;

          continue;
        }

        result += DateTimeRange(start: element.tankDate, end: prevDate)
            .duration
            .inDays;

        prevDate = element.tankDate;
      }

      if (newTanksList.length > 2) {
        return (result / newTanksList.length).ceil();
      }

      return result.ceil();
    }

    return 0;
  }

  double getTotalLiters(SummaryTimeRangeEnum timeRange) {
    List<TankElement> newTanksList =
        TankElement.getListFromTimeRange(tanks, timeRange);

    return newTanksList.fold(0, (previousValue, element) {
      return double.parse((previousValue + element.liters).toStringAsFixed(2));
    });
  }

  double getAverageCosts(SummaryTimeRangeEnum timeRange) {
    List<TankElement> newTanksList =
        TankElement.getListFromTimeRange(tanks, timeRange);

    if (newTanksList.isNotEmpty) {
      int size = 0;

      double sum = newTanksList.fold(0.0, (previousValue, element) {
        if (element.price != 0.0) {
          double currentPrice =
              double.parse((element.liters * element.price).toStringAsFixed(2));

          if (currentPrice > 0) size++;

          return double.parse(
              (previousValue + currentPrice).toStringAsFixed(2));
        }

        return 0.0;
      });

      return sum == 0.0 ? 0.0 : double.parse((sum / size).toStringAsFixed(2));
    }

    return 0.0;
  }

  double getTotalDistance(SummaryTimeRangeEnum timeRange) {
    List<TankElement> newTanksList =
        TankElement.getListFromTimeRange(tanks, timeRange);

    if (newTanksList.isNotEmpty) {
      String totalDistance = newTanksList
          .fold(
              0.0, (previousValue, element) => previousValue + element.distance)
          .toStringAsFixed(2);

      return double.parse(totalDistance);
    }

    return 0.0;
  }

  int getTotalTanks(SummaryTimeRangeEnum timeRange) {
    List<TankElement> newTanksList =
        TankElement.getListFromTimeRange(tanks, timeRange);

    return newTanksList.length;
  }
}

class VehicleProvider extends ChangeNotifier {
  VehicleElement? currentVehicle;
  final List<VehicleElement> _vehicles = [];
  bool firstTimeInit = true;

  UnmodifiableListView<VehicleElement> get vehicles =>
      UnmodifiableListView(_vehicles);

  void convertTanksMetric(MetricTypeEnum newMetric) {
    if (newMetric == MetricTypeEnum.imperial) {
      for (var element in _vehicles) {
        List<TankElement> tanks = element.tanks;

        element.totalDistance = double.parse(
            (element.totalDistance * 0.62137119).toStringAsFixed(2));

        for (var tank in tanks) {
          tank.distance = double.parse((tank.distance * 0.62137119)
              .toStringAsFixed(2)); // kilometers to miles
          tank.liters = double.parse((tank.liters * 0.264172052)
              .toStringAsFixed(2)); // liters to gallons

          String newConsumption =
              (tank.distance / tank.liters).toStringAsFixed(2);

          tank.currentConsumption = double.parse(newConsumption);
        }
      }
    } else {
      for (var element in _vehicles) {
        List<TankElement> tanks = element.tanks;

        element.totalDistance =
            double.parse((element.totalDistance * 1.609344).toStringAsFixed(2));

        for (var tank in tanks) {
          tank.distance = double.parse((tank.distance * 1.609344)
              .toStringAsFixed(2)); // kilometers to miles
          tank.liters = double.parse((tank.liters * 3.78541178)
              .toStringAsFixed(2)); // liters to gallons

          String newConsumption =
              ((tank.liters / tank.distance) * 100).toStringAsFixed(2);

          tank.currentConsumption = double.parse(newConsumption);
        }
      }
    }

    saveToFile();
  }

  void updatePrimaryCar() {
    // Update Primary Car if the Vehicles Count is 1
    if (_vehicles.length == 1) {
      _vehicles[0].isPrimary = true;
    }
  }

  void sortTanks(List<TankElement> tanks) =>
      tanks.sort((a, b) => b.tankDate.compareTo(a.tankDate));

  void setCurrentVehicle(VehicleElement? vehicle) {
    currentVehicle = vehicle;
  }

  VehicleElement? getPrimaryVehicle() {
    for (var element in _vehicles) {
      if (element.isPrimary) {
        return element;
      }
    }

    return null;
  }

  VehicleElement? findVehicleByName(String name) {
    for (var element in _vehicles) {
      if (element.vehicleName == name) {
        return element;
      }
    }

    return null;
  }

  VehicleElement? findVehicleByID(int id) {
    for (var element in _vehicles) {
      if (element.vehicleID == id) {
        return element;
      }
    }

    return null;
  }

  TankElement? findTank(VehicleElement vehicle, DateTime date) {
    for (var element in vehicle.tanks) {
      if (element.tankDate == date) {
        return element;
      }
    }

    return null;
  }

  List<VehicleElement> add(VehicleElement vehicle) {
    _vehicles.add(vehicle);
    updatePrimaryCar();

    saveToFile();
    notifyListeners();

    return _vehicles;
  }

  List<VehicleElement> remove(VehicleElement vehicle) {
    _vehicles.remove(vehicle);
    updatePrimaryCar();

    saveToFile();
    notifyListeners();

    return _vehicles;
  }

  List<VehicleElement> updateVehicle(
      VehicleElement vehicle, VehicleFuelTypeEnum fuelType, String newName) {
    int index = _vehicles.indexOf(vehicle);

    if (index != -1) {
      _vehicles[index].fuelType = fuelType;
      _vehicles[index].vehicleName = newName;

      saveToFile();
    }

    return _vehicles;
  }

  List<VehicleElement> setPrimary(VehicleElement vehicle) {
    for (var element in _vehicles) {
      if (element.isPrimary) {
        element.isPrimary = false;
      }
    }

    vehicle.isPrimary = true;

    // Make primary vehicle on the top
    _vehicles.sort((a, b) => a.isPrimary != b.isPrimary ? 1 : 0);

    saveToFile();
    notifyListeners();

    return _vehicles;
  }

  List<TankElement> addTank(VehicleElement vehicle, TankElement tank) {
    vehicle.tanks.add(tank);
    vehicle.totalDistance = double.parse(
        (vehicle.totalDistance + tank.distance).toStringAsFixed(2));

    sortTanks(vehicle.tanks);
    saveToFile();
    notifyListeners();

    return vehicle.tanks;
  }

  List<TankElement> removeTank(VehicleElement vehicle, TankElement tank) {
    vehicle.tanks.remove(tank);
    vehicle.totalDistance = double.parse(
        (vehicle.totalDistance - tank.distance).toStringAsFixed(2));

    sortTanks(vehicle.tanks);
    saveToFile();
    notifyListeners();

    return vehicle.tanks;
  }

  List<TankElement> updateTank(
      VehicleElement vehicle, TankElement tank, TankElement newData) {
    int index = vehicle.tanks.indexOf(tank);

    if (index != -1) {
      vehicle.tanks[index] = newData;

      vehicle.totalDistance = double.parse(
          (vehicle.totalDistance - tank.distance + newData.distance)
              .toStringAsFixed(2));

      sortTanks(vehicle.tanks);
      saveToFile();
      notifyListeners();
    }

    return vehicle.tanks;
  }

  String getJSONData() {
    var json = {
      'vehicles': vehicles.map((element) {
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

  Future<bool> saveToFile({ bool test = false }) async {
    var jsonText = getJSONData();

    final prefs = await SharedPreferences.getInstance();
    final bool isUpdated = await prefs.setString('vehiclesData', jsonText);

    return isUpdated;
  }

  void updateVehicles(var jsonObject) {
    List<VehicleElement> fixedList = [];

    List<dynamic> vehiclesList = jsonObject['vehicles'];

    for (var vehicle in vehiclesList) {
      List<TankElement> tanks = [];
      VehicleElement newElement = VehicleElement(
          vehicleID: vehicle['vehicleID'],
          vehicleName: vehicle['vehicleName'],
          isPrimary: vehicle['isPrimary'],
          fuelType: EnumConverter.stringToVehicleFuelEnum(vehicle['fuelType']));

      for (var tank in vehicle['tanks']) {
        tanks.add(TankElement(
            DateTime.fromMillisecondsSinceEpoch(tank['tankDate']),
            tank['distance'],
            tank['liters'],
            tank['currentConsumption'],
            tank['price'],
            EnumConverter.stringToRouteTypeEnum(tank['routeType']),
            tank['calculateConsumption']));
      }

      sortTanks(tanks);

      newElement.tanks = tanks;
      newElement.totalDistance = tanks.fold(
          0.0, (previousValue, element) => previousValue + element.distance);

      fixedList.add(newElement);
    }

    updateProviderData(fixedList);
    saveToFile();
  }

  static Future<List<VehicleElement>> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('vehiclesData');
    List<VehicleElement> fixedList = [];

    if (data != null) {
      var jsonObject = jsonDecode(data);
      List<dynamic> vehiclesList = jsonObject['vehicles'];

      for (var vehicle in vehiclesList) {
        VehicleElement newElement = VehicleElement(
            vehicleID: vehicle['vehicleID'],
            vehicleName: vehicle['vehicleName'],
            isPrimary: vehicle['isPrimary'],
            fuelType:
                EnumConverter.stringToVehicleFuelEnum(vehicle['fuelType']));

        for (var tank in vehicle['tanks']) {
          newElement.tanks.add(TankElement(
              DateTime.fromMillisecondsSinceEpoch(tank['tankDate']),
              tank['distance'],
              tank['liters'],
              tank['currentConsumption'],
              tank['price'],
              EnumConverter.stringToRouteTypeEnum(tank['routeType']),
              tank['calculateConsumption']));
        }

        newElement.totalDistance = newElement.tanks.fold(
            0.0, (previousValue, element) => previousValue + element.distance);
        newElement.tanks.sort((a, b) => b.tankDate.compareTo(a.tankDate));

        fixedList.add(newElement);
      }
    }

    return fixedList;
  }

  void updateProviderData(List<VehicleElement> newVehiclesList) {
    _vehicles.clear();

    for (var vehicle in newVehiclesList) {
      _vehicles.add(vehicle);
    }

    // Make primary vehicle on the top
    _vehicles.sort((a, b) => a.isPrimary != b.isPrimary ? 0 : 1);
  }

  int generateNewVehicleID(List<VehicleElement> vehiclesList) {
    int newID = vehiclesList.fold(0, (prev, curr) {
      if (prev < curr.vehicleID) return curr.vehicleID + 1;

      return prev + 1;
    });

    return newID;
  }
}
