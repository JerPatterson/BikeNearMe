import 'package:bike_near_me/entities/station_information.dart';
import 'package:bike_near_me/entities/station_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

const minZoom = 10.0;
const maxZoom = 20.0;
const initialZoom = 14.0;
const initialCenter = LatLng(45.504789, -73.613187);

const markerUpdatesIntervallSeconds = 30;
const stationMarkerIconSize = 35.0;
const positionIconSize = 20.0;


class StationInfoPage extends StatefulWidget {
  const StationInfoPage({
    super.key,
    required this.stationInformation,
    required this.stationStatus,
  });

  final StationInformation stationInformation;
  final StationStatus stationStatus;

  @override
  State<StationInfoPage> createState() => _StationInfoPageState();
}

class _StationInfoPageState extends State<StationInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        body: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: initialCenter,
                initialZoom: initialZoom,
                minZoom: minZoom,
                maxZoom: maxZoom,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                )
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                const MarkerLayer(
                  markers: [],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => {},
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: (MediaQuery.of(context).size.height - (positionIconSize + 4)) / 2,
              right: (MediaQuery.of(context).size.width - (positionIconSize + 4)) / 2,
              child: const Icon(
                Icons.circle,
                size: positionIconSize + 4,
                color: Colors.white
              ),
            ),
            Positioned(
              top: (MediaQuery.of(context).size.height - positionIconSize) / 2,
              right: (MediaQuery.of(context).size.width - positionIconSize) / 2,
              child: const Icon(
                Icons.circle,
                size: positionIconSize,
                color: Color(0xFFB219B7)
              ),
            ),
          ]
        ),
      ),
    );
  }
}