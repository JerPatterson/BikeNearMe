class StationStatus {
  StationStatus({
    required this.id,
    required this.numVehiclesAvailable,
    this.numVehiclesDisabled,
    this.numDocksAvailable,
    this.numDocksDisabled,
    required this.isInstalled,
    required this.isRenting,
    required this.isReturning,
    required this.lastReported,
  });

  String id;
  int numVehiclesAvailable;
  int? numVehiclesDisabled;
  int? numDocksAvailable;
  int? numDocksDisabled;
  bool isInstalled;
  bool isRenting;
  bool isReturning;
  int lastReported;

  factory StationStatus.fromJson(Map<String, dynamic> json) => StationStatus(
    id: json['station_id'],
    numVehiclesAvailable: json['num_bikes_available'],
    numVehiclesDisabled: json['num_bikes_disabled'],
    numDocksAvailable: json['num_docks_available'],
    numDocksDisabled: json['num_docks_disabled'],
    isInstalled: json['is_installed'] == 1,
    isRenting: json['is_renting'] == 1,
    isReturning: json['is_returning'] == 1,
    lastReported: json['last_reported'],
  );
}