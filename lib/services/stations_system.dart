import 'dart:async';
import 'dart:convert';
import 'package:bike_near_me/entities/availibility.dart';
import 'package:bike_near_me/entities/station_information.dart';
import 'package:bike_near_me/entities/station_status.dart';
import 'package:bike_near_me/entities/system.dart';
import 'package:bike_near_me/entities/system_availability.dart';
import 'package:bike_near_me/entities/vehicle_type.dart';
import 'package:bike_near_me/icons/bike_share.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class StationsSystem {
  StationsSystem._create({
    required this.id,
    required this.stationStatusUrl,
    required this.stationInformationUrl,
    required this.vehicleTypesUrl,
    required this.color,
    required this.textColor,
    required this.systemAvailability,
  }) {
    _initDataRefresh();
  }

  static Future<StationsSystem> create(System system, SystemAvailability? systemAvailability) async {
    var instance = StationsSystem._create(
      id: system.id,
      stationStatusUrl: system.stationStatusUrl,
      stationInformationUrl: system.stationInformationUrl,
      vehicleTypesUrl: system.vehicleTypesUrl,
      systemAvailability: systemAvailability,
      color: system.color,
      textColor: system.textColor,
    );
    
    await instance._setVehicleTypes();
    await instance._setStationsInformation();
    await instance._setStationsStatus();

    return instance;
  }


  final String id;
  final String stationStatusUrl;
  final String stationInformationUrl;
  final String vehicleTypesUrl;
  final SystemAvailability? systemAvailability;
  final Color color;
  final Color textColor;

  List<VehicleType> _vehicleTypes = [];
  List<StationStatus> _stationsStatus = [];
  List<StationInformation> _stationsInformation = [];
  final Map<String, StationStatus> stationsStatusByStationIds = {};
  final Map<String, StationInformation> stationsInformationByStationIds = {};
  final Map<String, String> propulsionByVehicleTypeId = {};


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

  Future<Map<String, Map<String, Availability>>?> getStationAvailabilityHistory(String stationId) async {
    return systemAvailability?.getStationAvailability(stationId);
  }


  int getStationAvailability(String stationId, bool showDockAvailability) {
    var stationStatus = stationsStatusByStationIds[stationId];
    var stationInformation = stationsInformationByStationIds[stationId];

    if (showDockAvailability) {
      if (stationStatus!.numDocksAvailable != null) {
        return stationStatus.numDocksAvailable!;
      } else {
        return stationInformation!.capacity! - stationStatus.numVehiclesAvailable;
      }
    }
    return stationStatus!.numVehiclesAvailable;
  }

  IconData getStationAvailabilityIcon(String stationId, bool showDockAvailability) {
    if (showDockAvailability) return _getStationAvailabilityIconForDocks(stationId);
    return _getStationAvailabilityIconForBikes(stationId);
  }

  IconData _getStationAvailabilityIconForBikes(String stationId) {
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

  IconData _getStationAvailabilityIconForDocks(String stationId) {
    var stationStatus = stationsStatusByStationIds[stationId];
    var stationInformation = stationsInformationByStationIds[stationId];

    try {
      var availability = 0.0;
      var capacity = stationInformation!.capacity;
      if (stationStatus != null && capacity != null) {
        if (stationStatus.numDocksAvailable != null) {
          availability = stationStatus.numDocksAvailable! * 10 / capacity;
        } else {
          availability = 10.0 - stationStatus.numVehiclesAvailable * 10 / capacity;
        }
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


  Future<void> _setVehicleTypes() async {
    try {
      _vehicleTypes = await _getVehicleTypes();
      for (var vehicleType in _vehicleTypes) {
        propulsionByVehicleTypeId.update(
          vehicleType.id,
          (value) => vehicleType.propulsionType,
          ifAbsent: () => vehicleType.propulsionType,
        );
      }
    } catch (_) {
      return;
    }
  }

  Future<void> _setStationsStatus() async {
    try {
      _stationsStatus = await _getStationsStatus();
      for (var stationStatus in _stationsStatus) {
        if (propulsionByVehicleTypeId.isNotEmpty) {
          stationStatus.numElectricVehiclesAvailable = 0;
          for (var vehicleTypeAvailable in stationStatus.vehicleTypesAvailable) {
            if (propulsionByVehicleTypeId.containsKey(vehicleTypeAvailable.id)) {
              if (propulsionByVehicleTypeId[vehicleTypeAvailable.id] == "electric"
                || propulsionByVehicleTypeId[vehicleTypeAvailable.id] == "electric_assist") {
                stationStatus.numElectricVehiclesAvailable += vehicleTypeAvailable.count;
              }
            }
          }
        }

        stationsStatusByStationIds.update(
          stationStatus.id,
          (value) => stationStatus,
          ifAbsent: () => stationStatus,
        );

        if (stationsInformationByStationIds[stationStatus.id]!.capacity == null) {
          stationsInformationByStationIds[stationStatus.id]!.capacity = stationStatus.numVehiclesAvailable + stationStatus.numVehiclesDisabled 
            + stationStatus.numDocksAvailable! + stationStatus.numDocksDisabled;
        }
      }
    } catch (_) {
      return;
    }
  }

  Future<void> _setStationsInformation() async {
    try {
      _stationsInformation = await _getStationsInformation();
      for (var stationInformation in _stationsInformation) {
        stationsInformationByStationIds.update(
          stationInformation.id,
          (value) => stationInformation,
          ifAbsent: () => stationInformation,
        );
      }
    } catch (_) {
      return;
    }
  }


  Future<List<VehicleType>> _getVehicleTypes() async {
    var client = http.Client();
    var url = Uri.parse(vehicleTypesUrl);
    var response = await client.get(url);

    return _vehicleTypesFromJson(json.decode(response.body)['data']['vehicle_types']);
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

  List<VehicleType> _vehicleTypesFromJson(list) => List<VehicleType>.from(
    list.map((x) => VehicleType.fromJson(Map<String, dynamic>.from(x)))
  );

  List<StationStatus> _stationsStatusFromJson(list) => List<StationStatus>.from(
    list.map((x) => StationStatus.fromJson(Map<String, dynamic>.from(x)))
  );

  List<StationInformation> _stationsInformationFromJson(list) => List<StationInformation>.from(
    list.map((x) => StationInformation.fromJson(Map<String, dynamic>.from(x)))
  );
}
