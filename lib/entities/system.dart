import 'package:latlong2/latlong.dart';

class System {
  System({
    required this.id,
    required this.minPosition,
    required this.maxPosition,
    required this.stationStatusUrl,
    required this.stationInformationUrl,
  });

  String id;
  LatLng minPosition;
  LatLng maxPosition;
  String stationStatusUrl;
  String stationInformationUrl;

  factory System.fromJson(Map<String, dynamic> json) => System(
    id: json['id'],
    minPosition: LatLng(json['min_lat'], json['min_lon']),
    maxPosition: LatLng(json['max_lat'], json['max_lon']),
    stationStatusUrl: json['station_status_url'],
    stationInformationUrl: json['station_information_url'],
  );
}