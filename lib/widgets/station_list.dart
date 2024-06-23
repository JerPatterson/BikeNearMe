import 'dart:math';
import 'package:bike_near_me/entities/station_information.dart';
import 'package:bike_near_me/services/stations_system.dart';
import 'package:bike_near_me/widgets/station_list_tile.dart';
import 'package:flutter/material.dart';

class StationList extends StatelessWidget {
  StationList({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.stationsSystems,
    required this.showDockAvailability,
  }) {
    for (StationsSystem stationsSystem in stationsSystems) {
      for (StationInformation stationInformation in stationsSystem.getStationsInformation()) {
        final double distance = getDistance(latitude, longitude, stationInformation.lat, stationInformation.lon);
        if (distance > maxDistanceToDisplay) continue;
        _stationListTiles.add(
          StationListTile(
            distance: distance,
            stationName: stationInformation.name,
            bikesAvailableCount: stationsSystem.getStationStatusById(stationInformation.id)!.numVehiclesAvailable,
            color: stationsSystem.color,
            textColor: stationsSystem.textColor,
            markerIcon: stationsSystem.getStationAvailabilityIcon(stationInformation.id, showDockAvailability),
          ),
        );
      }
    }

    _stationListTiles.sort((a, b) => a.distance.compareTo(b.distance));
  }

  final double latitude;
  final double longitude;
  final List<StationsSystem> stationsSystems;
  final bool showDockAvailability;

  static const maxDistanceToDisplay = 2000;
  final List<StationListTile> _stationListTiles = [];


  double getDistance(double latA, double lonA, double latB, double lonB) {
    const double earthRadius = 6371.0;     
    
    const double factor = 0.017453292519943295;
    latA *= factor;
    lonA *=  factor;
    latB *= factor;
    lonB *=  factor;

    final double dLat = latA - latB;
    final double dLon = lonA - lonB;

    final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(latA) * cos(latB) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance * 1000;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      builder: (context, scrollController) {
        return ListView.builder(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          itemCount: _stationListTiles.length,
          itemBuilder: (context, index) {
            return _stationListTiles[index];
          },
        );
      },
    );
  }
}
