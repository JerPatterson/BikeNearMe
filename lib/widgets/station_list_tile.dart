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

  final String distance;
  final String stationName;
  final int bikesAvailableCount;
  final Color color;
  final Color textColor;
  final IconData markerIcon;

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
              Row(
                children: [
                  Icon(
                    markerIcon,
                    color: textColor,
                    size: 60,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        distance,
                        style: TextStyle(
                          color: textColor,
                          height: 1,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        stationName,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                        ),
                      ),
                    ]
                  ),
                ],
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