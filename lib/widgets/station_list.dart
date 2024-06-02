import 'package:bike_near_me/widgets/station_list_tile.dart';
import 'package:flutter/material.dart';

class StationList extends StatefulWidget {
  const StationList({super.key});

  @override
  State<StationList> createState() => _StationListState();
}

class _StationListState extends State<StationList> {
  // late final SystemsData _systemsData;
  // final Map<String, StationsData> _stationsData = {};

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(
          child: Column(
            children: [
              StationListTile(),
              StationListTile(),
              StationListTile(),
            ]
          ),
        )
      ],
    );
  }
}