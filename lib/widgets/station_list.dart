import 'package:bike_near_me/entities/station_information.dart';
import 'package:bike_near_me/services/stations_system.dart';
import 'package:bike_near_me/widgets/station_list_tile.dart';
import 'package:flutter/material.dart';

class StationList extends StatelessWidget {
  StationList({
    super.key,
    required this.stationsSystems,
    required this.showDockAvailability,
  }) {
    for (StationsSystem stationsSystem in stationsSystems) {
      for (StationInformation stationInformation in stationsSystem.getStationsInformation()) {
        _stationListTiles.add(
          StationListTile(
            distance: "100m",
            stationName: stationInformation.name,
            bikesAvailableCount: stationsSystem.getStationStatusById(stationInformation.id)!.numVehiclesAvailable,
            color: stationsSystem.color,
            textColor: stationsSystem.textColor,
            markerIcon: stationsSystem.getStationAvailabilityIcon(stationInformation.id, showDockAvailability),
          ),
        );
      }
    }
  }

  final List<StationsSystem> stationsSystems;
  final bool showDockAvailability;

  final List<StationListTile> _stationListTiles = [];


  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      builder: (context, scrollController) {
        return ListView.builder(
          controller: scrollController,
          itemCount: _stationListTiles.length,
          itemBuilder: (context, index) {
            return _stationListTiles[index];
          },
        );
      },
    );
  }
}
