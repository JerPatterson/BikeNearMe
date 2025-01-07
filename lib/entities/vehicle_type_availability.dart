class VehicleTypeAvailability {
  VehicleTypeAvailability({
    required this.id,
    required this.count,
  });

  String id;
  int count;

  factory VehicleTypeAvailability.fromJson(Map<String, dynamic> json) => VehicleTypeAvailability(
    id: json['vehicle_type_id'],
    count: json['count'],
  );
}
