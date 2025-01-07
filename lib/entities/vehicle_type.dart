class VehicleType {
  VehicleType({
    required this.id,
    required this.formFactor,
    required this.propulsionType,
  });

  String id;
  String formFactor;
  String propulsionType;

  factory VehicleType.fromJson(Map<String, dynamic> json) => VehicleType(
    id: json['vehicle_type_id'],
    formFactor: json['form_factor'],
    propulsionType: json['propulsion_type'],
  );
}
