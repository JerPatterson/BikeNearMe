import 'dart:async';
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
  final Map<String, StationsSystem> _stationsSystemById = {};
  
  List<Marker> _markers = [];
  List<StationsSystem> _stationsSystems = [];

  final Set<String> _knownPositions = {};
  MapPosition _position = const MapPosition(center: initialCenter);

  String _typeNotDisplayed = "docks";
  IconData _switchMarkerTypeIcon = BikeShare.dock;


  @override
  void initState() {
    super.initState();
  }


  void initMapRefresh() {
    Systems.create(FirebaseDatabase.instance).then((systems) {
      _systems = systems;
      updateKnownPositions(_position, false);
      Timer.periodic(const Duration(seconds: 30), (_) {
        updateMarkers();
      });
    });
    
  }


  void updateKnownPositions(MapPosition position, bool _) {
    _position = position;
    double lat = double.parse(position.center!.latitude.toStringAsFixed(1));
    double lon = double.parse(position.center!.longitude.toStringAsFixed(1));

    String positionString = "$lat,$lon";
    if (_knownPositions.contains(positionString)) return;
    _knownPositions.add(positionString);

    List<Future<StationsSystem>> futureStationSystems = [];
    for (var system in _systems.systems) {
      if (_stationsSystemById.containsKey(system.id) || !system.isInBounds(lat, lon)) continue;
      futureStationSystems.add(StationsSystem.create(system));
    }

    futureStationSystems.wait.then((stationsSystems) {
      for (StationsSystem stationsSystem in stationsSystems) {
        _stationsSystemById.putIfAbsent(
          stationsSystem.systemId,
          () => stationsSystem
        );
      }

      if (stationsSystems.isNotEmpty) updateMarkers();
    });

    
  }

  void updateMarkers() {
    _markers.clear();
    _stationsSystems.clear();
    for (var system in _systems.systems) {
      if (!system.isInBounds(_position.center!.latitude, _position.center!.longitude)) continue;
      var stationsSystem = _stationsSystemById[system.id];
      if (stationsSystem == null) return;
      _stationsSystems.add(stationsSystem);
      for (var stationInformation in stationsSystem.getStationsInformation()) {
        _markers.add(
          Marker(
            width: 35.0,
            height: 35.0,
            point: LatLng(stationInformation.lat, stationInformation.lon),
            child: Stack(
              children: [
                const Icon(
                  BikeShare.marker_background,
                  color: Colors.white,
                  size: 35.0,
                ),
                Icon(
                  _typeNotDisplayed == "docks" ? 
                    stationsSystem.getStationIconFromBikesAvailability(stationInformation.id)
                    : stationsSystem.getStationIconFromDocksAvailability(stationInformation.id),
                  color: system.color,
                  size: 35.0,
                ),
              ],
            ),
          ),
        );
      }

      setState(() {
        _markers = _markers;
        _stationsSystems = _stationsSystems;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FlutterMap(
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
          ),
          const Expanded(
            child: StationList()
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