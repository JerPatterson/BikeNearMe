import 'package:bike_near_me/icons/bike_share.dart';
import 'package:bike_near_me/widgets/station_list_tile.dart';
import 'package:flutter/material.dart';

class StationList extends StatelessWidget {
  const StationList({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(
          child: Column(
            children: [
              StationListTile(
                distance: "300m",
                stationName: "Métro Montmorency",
                bikesAvailableCount: 12,
                color: Colors.red,
                textColor: Colors.white,
                markerIcon: BikeShare.marker_bikes_50,
              ),
              StationListTile(
                distance: "1.1km",
                stationName: "Terminus Carrefour",
                bikesAvailableCount: 9,
                color: Colors.red,
                textColor: Colors.white,
                markerIcon: BikeShare.marker_bikes_30,
              ),
              StationListTile(
                distance: "300km",
                stationName: "Terminus de la Faune",
                bikesAvailableCount: 8,
                color: Colors.greenAccent,
                textColor: Colors.black,
                markerIcon: BikeShare.marker_bikes_80,
              ),
            ]
          ),
        )
      ],
    );
  }
}
