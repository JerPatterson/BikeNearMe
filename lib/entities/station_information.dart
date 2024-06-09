import 'dart:convert';

class StationInformation {
  StationInformation({
    required this.id,
    required this.name,
    this.shortName,
    required this.lat,
    required this.lon,
    this.isVirtualStation,
    this.capacity,
    this.isChargingStation,
  });

  final String id;
  final String name;
  final String? shortName;
  final double lat;
  final double lon;
  final bool? isVirtualStation;
  final int? capacity;
  final bool? isChargingStation;

  factory StationInformation.fromJson(Map<String, dynamic> json) => StationInformation(
    id: json['station_id'],
    name: const Utf8Decoder().convert(json['name']!.toString().codeUnits),
    shortName: const Utf8Decoder().convert(json['short_name']!.toString().codeUnits),
    lat: json['lat'],
    lon: json['lon'],
    isVirtualStation: json['is_virtual_station'],
    capacity: json['capacity'],
    isChargingStation: json['is_charging_station'],
  );
}