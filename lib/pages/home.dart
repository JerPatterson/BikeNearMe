import 'dart:async';
import 'package:bike_near_me/entities/station_information.dart';
import 'package:bike_near_me/entities/system.dart';
import 'package:bike_near_me/icons/bike_share.dart';
import 'package:bike_near_me/services/stations_system.dart';
import 'package:bike_near_me/services/systems.dart';
import 'package:bike_near_me/widgets/station_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';


const minZoom = 10.0;
const maxZoom = 20.0;
const initialZoom = 14.0;
const initialCenter = LatLng(45.504789, -73.613187);
const positionIconSize = 20.0;


class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title
  });

  final String title;
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Systems _systems;
  final Map<String, StationsSystem> _stationsSystemByIds = {};
  
  List<Marker> _markers = [];
  List<StationsSystem> _stationsSystems = [];

  final Set<String> _knownPositions = {};
  double _latitudeRounded = initialCenter.latitude;
  double _longitudeRounded = initialCenter.longitude;
  double _latitude = initialCenter.latitude;
  double _longitude = initialCenter.longitude;

  String _typeNotDisplayed = "docks";
  IconData _switchMarkerTypeIcon = BikeShare.dock;


  @override
  void initState() {
    super.initState();
  }


  void initMapRefresh() {
    Systems.create(FirebaseDatabase.instance).then((systems) {
      _systems = systems;
      updateKnownPositions(const MapPosition(center: initialCenter), false);
      Timer.periodic(const Duration(seconds: 30), (_) {
        updateMarkers();
      });
    });
    
  }


  void updateKnownPositions(MapPosition position, bool _) {
    setState(() {
      _latitude = position.center!.latitude;
      _longitude = position.center!.longitude;
    });

    _latitudeRounded = double.parse(_latitude.toStringAsFixed(1));
    _longitudeRounded = double.parse(_longitude.toStringAsFixed(1));
    if (_isKnownPosition(_latitudeRounded, _longitudeRounded)) return;

    List<Future<StationsSystem>> futureStationsSystems = [];
    for (System system in _systems.systems) {
      if (_isUnknownStationsSystem(system.id)
        && system.isInBounds(_latitudeRounded, _longitudeRounded)) {
        futureStationsSystems.add(StationsSystem.create(system));
      }
    }

    futureStationsSystems.wait.then((stationsSystems) {
      for (StationsSystem stationsSystem in stationsSystems) {
        setState(() {
          _stationsSystemByIds.putIfAbsent(
            stationsSystem.id,
            () => stationsSystem
          );
        });
      }

      if (stationsSystems.isNotEmpty) updateMarkers();
    });
  }

  bool _isKnownPosition(double lat, double lon) {
    String positionString = "$lat,$lon";
    if (_knownPositions.contains(positionString)) return true;
    _knownPositions.add(positionString);
    return false;
  }

  bool _isUnknownStationsSystem(String id) {
    return !_stationsSystemByIds.containsKey(id);
  }


  void updateMarkers() {
    _markers.clear();
    _stationsSystems.clear();

    for (System system in _systems.systems) {
      StationsSystem? stationsSystem = _stationsSystemByIds[system.id];
      if (stationsSystem == null || !system.isInBounds(_latitudeRounded, _longitudeRounded)) continue;
      _stationsSystems.add(stationsSystem);

      for (StationInformation stationInformation in stationsSystem.getStationsInformation()) {
        _markers.add(
          _createMarker(
            stationsSystem.getStationAvailabilityIcon(
              stationInformation.id,
              _typeNotDisplayed == "bikes",
            ),
            system.color,
            stationInformation.lat,
            stationInformation.lon,
          ),
        );
      }

      setState(() {
        _markers = _markers;
        _stationsSystems = _stationsSystems;
      });
    }
  }

  Marker _createMarker(IconData icon, Color color, double lat, double lon) {
    return Marker(
      width: 35.0,
      height: 35.0,
      point: LatLng(lat, lon),
      child: Stack(
        children: [
          const Icon(
            BikeShare.marker_background,
            color: Colors.white,
            size: 35.0,
          ),
          Icon(
            icon,
            color: color,
            size: 35.0,
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SlidingUpPanel(
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: initialZoom,
                minZoom: minZoom,
                maxZoom: maxZoom,
                onMapReady: initMapRefresh,
                onPositionChanged: updateKnownPositions,
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
                  markers: [for (int i = 0; i < _markers.length; i++) _markers[i]],
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
        panelBuilder: (ScrollController sc) {
          return StationList(
            controller: sc,
            latitude: _latitude,
            longitude: _longitude,
            stationsSystems: _stationsSystems,
            showDockAvailability: _typeNotDisplayed == "bikes",
          );
        },
        maxHeight: MediaQuery.of(context).size.height,
        minHeight: MediaQuery.of(context).size.height * 0.25,
        panelSnapping: false,
        parallaxEnabled: true,
        parallaxOffset: 0.6,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          switch (_typeNotDisplayed) {
            case "bikes":
              _typeNotDisplayed = "docks";
              _switchMarkerTypeIcon = BikeShare.dock;
              updateMarkers();
            case "docks":
              _typeNotDisplayed = "bikes";
              _switchMarkerTypeIcon = BikeShare.bike;
              updateMarkers();
              break;
          }
        },
        tooltip: 'Display $_typeNotDisplayed instead',
        child: Icon(_switchMarkerTypeIcon),
      ),
    );
  }
}