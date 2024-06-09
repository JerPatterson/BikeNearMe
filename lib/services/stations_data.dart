import 'dart:async';
import 'dart:convert';
import 'package:bike_near_me/entities/station_information.dart';
import 'package:bike_near_me/entities/station_status.dart';
import 'package:bike_near_me/entities/system.dart';
import 'package:bike_near_me/icons/bike_share.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class StationsData {
  StationsData._create({
    required this.systemId,
    required this.stationStatusUrl,
    required this.stationInformationUrl,
  }) {
    _initDataRefresh();
  }

  static Future<StationsData> create(System system) async {
    var instance = StationsData._create(
      systemId: system.id,
      stationStatusUrl: system.stationStatusUrl,
      stationInformationUrl: system.stationInformationUrl,
    );
    
    await instance._setStationsInformation();
    await instance._setStationsStatus();

    return instance;
  }


  final String systemId;
  final String stationStatusUrl;
  final String stationInformationUrl;

  List<StationStatus> _stationsStatus = [];
  List<StationInformation> _stationsInformation = [];
  final Map<String, StationStatus> stationsStatusByStationIds = {};
  final Map<String, StationInformation> stationsInformationByStationIds = {};


  void _initDataRefresh() {
    Timer.periodic(const Duration(seconds: 30), (_) {
      _setStationsStatus();
    });
  }


  List<StationStatus> getStationsStatus() {
    return _stationsStatus;
  }

  StationStatus? getStationStatusById(String stationId) {
    return stationsStatusByStationIds[stationId];
  }

  List<StationInformation> getStationsInformation() {
    return _stationsInformation;
  }

  StationInformation? getStationInformationById(String stationId) {
    return stationsInformationByStationIds[stationId];
  }


  IconData getStationIconFromBikesAvailability(String stationId) {
    var stationStatus = stationsStatusByStationIds[stationId];
    var stationInformation = stationsInformationByStationIds[stationId];

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

  IconData getStationIconFromDocksAvailability(String stationId) {
    var stationStatus = stationsStatusByStationIds[stationId];
    var stationInformation = stationsInformationByStationIds[stationId];

    try {
      var availability = 0.0;
      var capacity = stationInformation!.capacity;
      if (stationStatus != null && capacity != null) {
        availability = 10.0 - stationStatus.numVehiclesAvailable * 10 / capacity;
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


  Future<void> _setStationsStatus() async {
    _stationsStatus = await _getStationsStatus();
    for (var stationStatus in _stationsStatus) {
      stationsStatusByStationIds.update(
        stationStatus.id,
        (value) => stationStatus,
        ifAbsent: () => stationStatus,
      );
    }
  }

  Future<void> _setStationsInformation() async {
    _stationsInformation = await _getStationsInformation();
    for (var stationInformation in _stationsInformation) {
      stationsInformationByStationIds.update(
        stationInformation.id,
        (value) => stationInformation,
        ifAbsent: () => stationInformation,
      );
    }
  }


  Future<List<StationStatus>> _getStationsStatus() async {
    var client = http.Client();
    var url = Uri.parse(stationStatusUrl);
    var response = await client.get(url);

    return _stationsStatusFromJson(json.decode(response.body)['data']['stations']);
  }

  Future<List<StationInformation>> _getStationsInformation() async {
    var client = http.Client();
    var url = Uri.parse(stationInformationUrl);
    var response = await client.get(url);

    return _stationsInformationFromJson(json.decode(response.body)['data']['stations']);
  }

  List<StationStatus> _stationsStatusFromJson(list) => List<StationStatus>.from(
    list.map((x) => StationStatus.fromJson(Map<String, dynamic>.from(x)))
  );

  List<StationInformation> _stationsInformationFromJson(list) => List<StationInformation>.from(
    list.map((x) => StationInformation.fromJson(Map<String, dynamic>.from(x)))
  );
}