class Availability {
  Availability({
    required this.bikesAvailable,
    required this.docksAvailable,
    required this.electricBikesFromAvailable,
  });

  final double bikesAvailable;
  final double docksAvailable;
  final double electricBikesFromAvailable;

  factory Availability.fromJson(Map<String, dynamic> json) => Availability(
    bikesAvailable: double.parse(json['bikes_available'].toString()),
    docksAvailable: double.parse(json['docks_available'].toString()),
    electricBikesFromAvailable: double.parse(json['electric_bikes_from_available'].toString()),
  );
}