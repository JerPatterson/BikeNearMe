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


const minZoom = 10.0;
const maxZoom = 20.0;
const initialZoom = 14.0;
const initialCenter = LatLng(45.504789, -73.613187);


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
    _latitude = double.parse(position.center!.latitude.toStringAsFixed(1));
    _longitude = double.parse(position.center!.longitude.toStringAsFixed(1));
    if (_isKnownPosition(_latitude, _longitude)) return;

    List<Future<StationsSystem>> stationSystems = [];
    for (System system in _systems.systems) {
      if (_isUnknownStationsSystem(system.id)
        && system.isInBounds(_latitude, _longitude)) {
        stationSystems.add(StationsSystem.create(system));
      }
    }

    stationSystems.wait.then((stationsSystems) {
      for (StationsSystem stationsSystem in stationsSystems) {
        _stationsSystemByIds.putIfAbsent(
          stationsSystem.id,
          () => stationsSystem
        );
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
      if (stationsSystem == null || !system.isInBounds(_latitude, _longitude)) continue;
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
          StationList(
            stationsSystems: _stationsSystems,
            showDockAvailability: _typeNotDisplayed == "bikes",
          ),
        ]
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