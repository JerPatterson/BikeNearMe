import 'package:bike_near_me/entities/vehicle_type_availability.dart';

class StationStatus {
  StationStatus({
    required this.id,
    required this.numVehiclesAvailable,
    required this.numElectricVehiclesAvailable,
    required this.numVehiclesDisabled,
    this.numDocksAvailable,
    required this.numDocksDisabled,
    required this.vehicleTypesAvailable,
    required this.isInstalled,
    required this.isRenting,
    required this.isReturning,
    required this.lastReported,
  });

  String id;
  int numVehiclesAvailable;
  int numElectricVehiclesAvailable;
  int numVehiclesDisabled;
  int? numDocksAvailable;
  int numDocksDisabled;
  List<VehicleTypeAvailability> vehicleTypesAvailable;
  bool isInstalled;
  bool isRenting;
  bool isReturning;
  int? lastReported;

  factory StationStatus.fromJson(Map<String, dynamic> json) => StationStatus(
    id: json['station_id'],
    numVehiclesAvailable: json['num_bikes_available'],
    numElectricVehiclesAvailable: json['num_ebikes_available'] ?? 0,
    numVehiclesDisabled: json['num_bikes_disabled'] ?? 0,
    numDocksAvailable: json['num_docks_available'],
    numDocksDisabled: json['num_docks_disabled'] ?? 0,
    vehicleTypesAvailable: json['vehicle_types_available'] != null
      ? StationStatus._vehicleTypesAvailabilityFromJson(json['vehicle_types_available']) : [],
    isInstalled: json['is_installed'] == 1,
    isRenting: json['is_renting'] == 1,
    isReturning: json['is_returning'] == 1,
    lastReported: json['last_reported'],
  );

  static List<VehicleTypeAvailability> _vehicleTypesAvailabilityFromJson(list) => List<VehicleTypeAvailability>.from(
    list.map((x) => VehicleTypeAvailability.fromJson(Map<String, dynamic>.from(x)))
  );
}
