import 'package:bike_near_me/entities/station_information.dart';
import 'package:bike_near_me/entities/station_status.dart';
import 'package:bike_near_me/icons/bike_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

const minZoom = 10.0;
const maxZoom = 20.0;
const initialZoom = 14.0;

const stationMarkerIconSize = 45.0;
const positionIconSize = 20.0;


class StationInfoPage extends StatefulWidget {
  const StationInfoPage({
    super.key,
    required this.stationInformation,
    required this.stationStatus,
    required this.markerIcon,
    required this.textColor,
    required this.color,
  });

  final StationInformation stationInformation;
  final StationStatus stationStatus;
  final IconData markerIcon;
  final Color textColor;
  final Color color;

  @override
  State<StationInfoPage> createState() => _StationInfoPageState();
}

class _StationInfoPageState extends State<StationInfoPage> {
  @override
  Widget build(BuildContext context) {
    final stationPosition = LatLng(widget.stationInformation.lat, widget.stationInformation.lon);
  
    return Scaffold(
      body: SlidingUpPanel(
        body: FlutterMap(
          options: MapOptions(
            initialCenter: stationPosition,
            initialZoom: initialZoom,
            minZoom: minZoom,
            maxZoom: maxZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            )
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: stationPosition,
                  child: Stack(
                    children: [
                      const Icon(
                        BikeShare.marker_background,
                        color: Colors.white,
                        size: stationMarkerIconSize,
                      ),
                      Icon(
                        widget.markerIcon,
                        color: widget.color,
                        size: stationMarkerIconSize,
                      ),
                    ],
                  ),
                ),
              ],
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

        panel: const Placeholder(),
      ),
    );
  }
}