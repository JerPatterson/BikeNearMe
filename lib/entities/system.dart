import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class System {
  System({
    required this.id,
    required this.name,
    required this.locationName,
    required this.minPosition,
    required this.maxPosition,
    required this.color,
    required this.textColor,
    required this.stationStatusUrl,
    required this.stationInformationUrl,
    required this.vehicleTypesUrl,
  }) {
    longitude = (minPosition.longitude + maxPosition.longitude) / 2;
    latitude = (minPosition.latitude + maxPosition.latitude) / 2;
  }

  final String id;
  final String name;
  final String locationName;
  final LatLng minPosition;
  final LatLng maxPosition;
  late double longitude;
  late double latitude;
  final Color color;
  final Color textColor;
  final String stationStatusUrl;
  final String stationInformationUrl;
  final String vehicleTypesUrl;

  factory System.fromJson(Map<String, dynamic> json) => System(
    id: json['id'].toString(),
    name: json['name'].toString(),
    locationName: json['location_name'].toString(),
    minPosition: LatLng(json['min_lat'], json['min_lon']),
    maxPosition: LatLng(json['max_lat'], json['max_lon']),
    color: Color(int.parse(json['color'])),
    textColor: Color(int.parse(json['text_color'])),
    stationStatusUrl: json['station_status_url'].toString(),
    stationInformationUrl: json['station_information_url'].toString(),
    vehicleTypesUrl: json['vehicle_types_url'].toString(),
  );


  bool isInBounds(double lat, double lon) =>
    maxPosition.latitude > lat && minPosition.latitude < lat
      && maxPosition.longitude > lon && minPosition.longitude < lon;
}
