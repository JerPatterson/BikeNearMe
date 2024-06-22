import 'package:flutter/material.dart';

class StationListTile extends StatelessWidget {
  const StationListTile({
    super.key,
    required this.distance,
    required this.stationName,
    required this.bikesAvailableCount,
    required this.color,
    required this.textColor,
    required this.markerIcon,
  });

  final double distance;
  final String stationName;
  final int bikesAvailableCount;
  final Color color;
  final Color textColor;
  final IconData markerIcon;


  String getDistanceString(double distance) {
    if (distance > 1000) {
      return "${double.parse((distance / 1000.0).toStringAsFixed(2))}km";
    } else {
      return "${double.parse(distance.toStringAsFixed(0))}m";
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
          decoration: BoxDecoration(
            color: color,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      markerIcon,
                      color: textColor,
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
                                color: textColor,
                                height: 1,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              stationName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textColor,
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
                    bikesAvailableCount.toString(),
                    style: TextStyle(
                      color: textColor,
                      height: 1,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "vélos",
                    style: TextStyle(
                      color: textColor,
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