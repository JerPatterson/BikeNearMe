import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class System {
  System({
    required this.id,
    required this.minPosition,
    required this.maxPosition,
    required this.color,
    required this.textColor,
    required this.stationStatusUrl,
    required this.stationInformationUrl,
  });

  final String id;
  final LatLng minPosition;
  final LatLng maxPosition;
  final Color color;
  final Color textColor;
  final String stationStatusUrl;
  final String stationInformationUrl;

  factory System.fromJson(Map<String, dynamic> json) => System(
    id: json['id'],
    minPosition: LatLng(json['min_lat'], json['min_lon']),
    maxPosition: LatLng(json['max_lat'], json['max_lon']),
    color: Color(int.parse(json['color'])),
    textColor: Color(int.parse(json['text_color'])),
    stationStatusUrl: json['station_status_url'],
    stationInformationUrl: json['station_information_url'],
  );


  bool isInBounds(double lat, double lon) =>
    maxPosition.latitude > lat && minPosition.latitude < lat
      && maxPosition.longitude > lon && minPosition.longitude < lon;
}
