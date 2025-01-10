class PlaceItem {
  PlaceItem({
    required this.name,
    required this.country,
    required this.state,
    required this.city,
    required this.street,
    required this.houseNumber,
    required this.type,
    required this.longitude,
    required this.latitude,
  });

  final String name;
  final String country;
  final String? state;
  final String? city;
  final String? street;
  final String? houseNumber;
  final String type;

  final double longitude;
  final double latitude;

  String get subName {
    switch(type) {
      case "house":
        return "${city != null ? "$city, " : ""}${state != null ? "$state, " : ""}$country";
      case "street":
        return "${city != null ? "$city, " : ""}${state != null ? "$state, " : ""}$country";
      case "city":
        return "${city != null ? "$city, " : ""}$country";
      case "state":
        return country;
      default:
        return "";
    }
  }
  
  factory PlaceItem.fromJson(Map<String, dynamic> json) => PlaceItem(
    name: json["properties"]["name"],
    country: json["properties"]["country"],
    state: json["properties"]["state"],
    city: json["properties"]["city"],
    street: json["properties"]["street"],
    houseNumber: json["properties"]["housenumber"],
    type: json["properties"]["type"],
    longitude: json["geometry"]["coordinates"][0],
    latitude: json["geometry"]["coordinates"][1],
  );
}
