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
    bikesAvailable: json['bikes_available'],
    docksAvailable: json['docks_available'],
    electricBikesFromAvailable: json['electric_bikes_from_available'],
  );
}