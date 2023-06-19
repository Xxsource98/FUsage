import 'package:flutter_test/flutter_test.dart';

import 'package:fusage/context/vehicles.dart';
import 'package:fusage/extra/enums.dart';

void main() {
  group('Testing Vehicles Tanks', () {
    test('New Tank Element', () {
      VehicleProvider vehicleProvider = VehicleProvider();
      VehicleElement exampleVehicle = VehicleElement(
        vehicleID: 0, 
        vehicleName: 'Audi A4',
        fuelType: VehicleFuelTypeEnum.gasoline, 
        isPrimary: true
      );

      TankElement exampleTank = TankElement(
        DateTime.now(), 
        227.1, 
        25.3, 
        11.14, 
        6.85, 
        RouteTypeEnum.city, 
        false
      );

      vehicleProvider.addTank(exampleVehicle, exampleTank);

      expect(exampleVehicle.tanks.length, 1);
    });

    test('Delete Tank Element', () {
      VehicleProvider vehicleProvider = VehicleProvider();
      VehicleElement exampleVehicle = VehicleElement(
        vehicleID: 0, 
        vehicleName: 'Audi A4',
        fuelType: VehicleFuelTypeEnum.gasoline, 
        isPrimary: true
      );

      TankElement exampleTank = TankElement(
        DateTime.now(), 
        227.1, 
        25.3, 
        11.14, 
        6.85, 
        RouteTypeEnum.city, 
        false
      );

      vehicleProvider.addTank(exampleVehicle, exampleTank);
      vehicleProvider.addTank(exampleVehicle, exampleTank);
      vehicleProvider.removeTank(exampleVehicle, exampleTank);

      expect(exampleVehicle.tanks.length, 1);
    });

    test('Update Tank Element', () {
      VehicleProvider vehicleProvider = VehicleProvider();
      VehicleElement exampleVehicle = VehicleElement(
        vehicleID: 0, 
        vehicleName: 'Audi A4',
        fuelType: VehicleFuelTypeEnum.gasoline, 
        isPrimary: true
      );

      TankElement exampleTank = TankElement(
        DateTime.now(), 
        227.1, 
        25.3, 
        11.14, 
        6.85, 
        RouteTypeEnum.city, 
        false
      );
      TankElement exampleTank2 = TankElement(
        DateTime.now(), 
        174.5, 
        20.3, 
        11.63, 
        6.84, 
        RouteTypeEnum.city, 
        false
      );

      vehicleProvider.addTank(exampleVehicle, exampleTank);
      vehicleProvider.updateTank(exampleVehicle, exampleTank, exampleTank2);

      expect(exampleVehicle.tanks[0].distance, 174.5);
    });
  });
}