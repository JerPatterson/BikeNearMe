import 'package:bike_near_me/icons/bike_share.dart';
import 'package:flutter/material.dart';

class StationListTile extends StatelessWidget {
  const StationListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
          decoration: const BoxDecoration(
            color: Colors.red,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    BikeShare.marker_bikes_50,
                    color: Colors.white,
                    size: 60,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "300m",
                        style: TextStyle(
                          color: Colors.white,
                          height: 1,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Métro Montmorency",
                        style: TextStyle(
                          color: Colors.white,
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
                    "12",
                    style: TextStyle(
                      color: Colors.white,
                      height: 1,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "vélos",
                    style: TextStyle(
                      color: Colors.white,
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