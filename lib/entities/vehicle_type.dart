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
    id: json['vehicle_type_id'].toString(),
    formFactor: json['form_factor'].toString(),
    propulsionType: json['propulsion_type'].toString(),
  );
}
