import 'package:flutter_test/flutter_test.dart';

import 'package:fusage/context/vehicles.dart';
import 'package:fusage/extra/enums.dart';

void main() {
  group('Testing Vehicle Provider', () {
    test('New Vehicle Element', () {
      VehicleProvider vehicleProvider = VehicleProvider();
      VehicleElement exampleVehicle = VehicleElement(
        vehicleID: 0, 
        vehicleName: 'Audi A4', 
        fuelType: VehicleFuelTypeEnum.gasoline, 
        isPrimary: true
      );

      vehicleProvider.add(exampleVehicle);

      expect(vehicleProvider.vehicles.length, 1);
    });  

    test('Delete Vehicle Element', () {
      VehicleProvider vehicleProvider = VehicleProvider();
      VehicleElement exampleVehicle = VehicleElement(
        vehicleID: 0, 
        vehicleName: 'Audi A4', 
        fuelType: VehicleFuelTypeEnum.gasoline, 
        isPrimary: true
      );

      vehicleProvider.add(exampleVehicle);
      vehicleProvider.add(exampleVehicle);
      vehicleProvider.remove(exampleVehicle);

      expect(vehicleProvider.vehicles.length, 1);
    });

   test('Update Vehicle Element', () {
      VehicleProvider vehicleProvider = VehicleProvider();
      VehicleElement exampleVehicle = VehicleElement(
        vehicleID: 0, 
        vehicleName: 'Audi A4', 
        fuelType: VehicleFuelTypeEnum.gasoline, 
        isPrimary: true
      );

      vehicleProvider.add(exampleVehicle);
      vehicleProvider.updateVehicle(exampleVehicle, VehicleFuelTypeEnum.gasoline, 'BMW X6');

      expect(
        vehicleProvider.getPrimaryVehicle()!.vehicleName,
        'BMW X6', 
        );
    });
  });
}