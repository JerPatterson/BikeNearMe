import 'package:bike_near_me/entities/station_information.dart';
import 'package:bike_near_me/services/stations_system.dart';
import 'package:flutter/material.dart';

class StationListTile extends StatelessWidget {
  const StationListTile({
    super.key,
    required this.distance,
    required this.stationInformation,
    required this.stationsSystem,
    required this.showDockAvailability,
  });

  final double distance;
  final StationInformation stationInformation;
  final StationsSystem stationsSystem;
  final bool showDockAvailability;


  String getDistanceString(double distance) {
    if (distance > 1000) {
      return "${double.parse((distance / 1000.0).toStringAsFixed(2))}km";
    } else {
      return "${distance.round()}m";
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
          decoration: BoxDecoration(
            color: stationsSystem.color,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      stationsSystem.getStationAvailabilityIcon(stationInformation.id, showDockAvailability),
                      color: stationsSystem.textColor,
                      size: 60,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getDistanceString(distance),
                              style: TextStyle(
                                color: stationsSystem.textColor,
                                height: 1,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              stationInformation.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: stationsSystem.textColor,
                                fontSize: 18,
                              ),
                            ),
                          ]
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    stationsSystem.getStationAvailability(stationInformation.id, showDockAvailability).toString(),
                    style: TextStyle(
                      color: stationsSystem.textColor,
                      height: 1,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    showDockAvailability ? "places" : "vélos",
                    style: TextStyle(
                      color: stationsSystem.textColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const Divider(
          height: 1,
        )
      ]
    );
  }
}