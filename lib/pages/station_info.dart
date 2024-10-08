import 'package:bike_near_me/entities/station_information.dart';
import 'package:bike_near_me/entities/station_status.dart';
import 'package:bike_near_me/icons/bike_share.dart';
import 'package:bike_near_me/widgets/station_info_tile.dart';
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
    required this.hasOnlyElectricBikes,
  });

  final StationInformation stationInformation;
  final StationStatus stationStatus;
  final IconData markerIcon;
  final Color textColor;
  final Color color;
  final bool hasOnlyElectricBikes;

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

        panel: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.ideographic,
                    children: [
                      Text(
                        "${widget.stationStatus.numVehiclesAvailable}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.color,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "/${widget.stationInformation.capacity}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.color,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.bar_chart,
                      color: widget.textColor,
                      size: 20,
                    ),
                    label: Text(
                      "Disponibilité",
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 20,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: widget.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    onPressed: () {
                      
                    },
                  ),
                ],
              ),
            ),
            Stack(
                children: [
                  Container(
                    color: Colors.white,
                    margin: const EdgeInsets.only(top: 40),
                    padding: const EdgeInsets.fromLTRB(16, 40, 8, 24),
                    child: Column(
                      children: [
                        StationInfoTile(
                          icon: BikeShare.bike,
                          value: "${widget.stationStatus.numVehiclesAvailable}",
                          valueName: "vélos",
                          color: widget.color
                        ),
                        const Divider(
                          height: 1,
                        ),
                        StationInfoTile(
                          icon: BikeShare.bike_electric,
                          value: "${widget.hasOnlyElectricBikes ? widget.stationStatus.numVehiclesAvailable
                            : widget.stationStatus.numElectricBikesAvailable}",
                          valueName: "vélos électriques",
                          color: widget.color
                        ),
                        const Divider(
                          height: 1,
                        ),
                        StationInfoTile(
                          icon: BikeShare.bike_disabled,
                          value: "${widget.stationStatus.numVehiclesDisabled}",
                          valueName: "vélos désactivés",
                          color: widget.color
                        ),
                        const Divider(
                          height: 1,
                        ),
                        StationInfoTile(
                          icon: BikeShare.dock,
                          value: "${widget.stationStatus.numDocksAvailable}",
                          valueName: "places",
                          color: widget.color
                        ),
                        const Divider(
                          height: 1,
                        ),
                        StationInfoTile(
                          icon: BikeShare.dock_disabled,
                          value: "${widget.stationStatus.numDocksDisabled}",
                          valueName: "places désactivés",
                          color: widget.color
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            widget.markerIcon,
                            color: Colors.black,
                            size: stationMarkerIconSize * 1.25,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Text(
                                widget.stationInformation.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        maxHeight: 470,
        minHeight: 170,
        renderPanelSheet: false,
        panelSnapping: false,
        parallaxEnabled: true,
        parallaxOffset: 0.75,
      ),
    );
  }
}