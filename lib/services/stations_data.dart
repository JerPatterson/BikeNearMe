import 'dart:convert';
import 'package:bike_near_me/entities/station_information.dart';
import 'package:bike_near_me/entities/station_status.dart';
import 'package:bike_near_me/icons/bike_share.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class StationsData {
  StationsData({
    required this.systemId,
    required this.stationStatusUrl,
    required this.stationInformationUrl,
  }) {
    setStationStatusById(systemId);
    setStationInformationById(systemId);
  }


  final String systemId;
  final String stationStatusUrl;
  final String stationInformationUrl;

  final Map<String, Map<String, StationStatus>> stationsStatusOfSystemByIds = {};
  final Map<String, Map<String, StationInformation>> stationsInformationOfSystemByIds = {};


  void setStationStatusById(String systemId) async {
    if (!stationsStatusOfSystemByIds.containsKey(systemId)) {
      var stationsStatusOfSystem = <String, StationStatus>{};
      for (var stationStatus in await getStationsStatus()) {
        stationsStatusOfSystem.putIfAbsent(stationStatus.id, () => stationStatus);
      }
      stationsStatusOfSystemByIds.putIfAbsent(systemId, () => stationsStatusOfSystem);
    }
  }

  void setStationInformationById(String systemId) async {
    if (!stationsInformationOfSystemByIds.containsKey(systemId)) {
      var stationsInformationOfSystem = <String, StationInformation>{};
      for (var stationInformation in await getStationsInformation()) {
        stationsInformationOfSystem.putIfAbsent(stationInformation.id, () => stationInformation);
      }
      stationsInformationOfSystemByIds.putIfAbsent(systemId, () => stationsInformationOfSystem);
    }
  }


  Future<List<StationStatus>> getStationsStatus() async {
    var client = http.Client();
    var url = Uri.parse(stationStatusUrl);
    var response = await client.get(url);

    return _stationsStatusFromJson(json.decode(response.body)['data']['stations']);
  }

  Future<List<StationInformation>> getStationsInformation() async {
    var client = http.Client();
    var url = Uri.parse(stationInformationUrl);
    var response = await client.get(url);

    return _stationsInformationFromJson(json.decode(response.body)['data']['stations']);
  }

  StationStatus? getStationStatusById(String systemId, String stationId)  {
    return stationsStatusOfSystemByIds[systemId]?[stationId];
  }

  StationInformation? getStationInformationById(String systemId, String stationId) {
    return stationsInformationOfSystemByIds[systemId]?[stationId];
  }

  IconData getStationIconFromBikesAvailability(String systemId, String stationId) {
    var stationStatus = stationsStatusOfSystemByIds[systemId]?[stationId];
    var stationInformation = stationsInformationOfSystemByIds[systemId]?[stationId];

    try {
      var availability = 0.0;
      var capacity = stationInformation!.capacity;
      if (stationStatus != null && capacity != null) {
        availability = stationStatus.numVehiclesAvailable * 10 / capacity;
      }
      
      if (availability == 0.0) return BikeShare.marker_bikes_0;

      switch (availability.floor()) {
        case 0:
        case 1:
          return BikeShare.marker_bikes_10;
        case 2:
          return BikeShare.marker_bikes_20;
        case 3:
          return BikeShare.marker_bikes_30;
        case 4:
          return BikeShare.marker_bikes_40;
        case 5:
          return BikeShare.marker_bikes_50;
        case 6:
          return BikeShare.marker_bikes_60;
        case 7:
          return BikeShare.marker_bikes_70;
        case 8:
          return BikeShare.marker_bikes_80;
        case 9:
          return BikeShare.marker_bikes_90;
        case 10:
          return BikeShare.marker_bikes_100;
        default:
          return BikeShare.marker_bikes_0;
      }
    } catch (_) {
      return BikeShare.marker_bikes_0;
    }
  }

  IconData getStationIconFromDocksAvailability(String systemId, String stationId) {
    var stationStatus = stationsStatusOfSystemByIds[systemId]?[stationId];
    var stationInformation = stationsInformationOfSystemByIds[systemId]?[stationId];

    try {
      var availability = 0.0;
      var capacity = stationInformation!.capacity;
      if (stationStatus != null && capacity != null) {
        availability = 10 - stationStatus.numVehiclesAvailable * 10 / capacity;
      }
      
      if (availability == 0.0) return BikeShare.marker_docks_0;

      switch (availability.floor()) {
        case 0:
        case 1:
          return BikeShare.marker_docks_10;
        case 2:
          return BikeShare.marker_docks_20;
        case 3:
          return BikeShare.marker_docks_30;
        case 4:
          return BikeShare.marker_docks_40;
        case 5:
          return BikeShare.marker_docks_50;
        case 6:
          return BikeShare.marker_docks_60;
        case 7:
          return BikeShare.marker_docks_70;
        case 8:
          return BikeShare.marker_docks_80;
        case 9:
          return BikeShare.marker_docks_90;
        case 10:
          return BikeShare.marker_docks_100;
        default:
          return BikeShare.marker_docks_0;
      }
    } catch (_) {
      return BikeShare.marker_docks_0;
    }
  }

  List<StationStatus> _stationsStatusFromJson(list) => List<StationStatus>.from(
    list.map((x) => StationStatus.fromJson(Map<String, dynamic>.from(x)))
  );

  List<StationInformation> _stationsInformationFromJson(list) => List<StationInformation>.from(
    list.map((x) => StationInformation.fromJson(Map<String, dynamic>.from(x)))
  );
}