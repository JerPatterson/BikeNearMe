import 'dart:async';

import 'package:bike_near_me/icons/bike_share.dart';
import 'package:bike_near_me/services/stations_data.dart';
import 'package:bike_near_me/services/systems_data.dart';
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
  const HomePage({super.key, required this.title});

  final String title;
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final SystemsData _systemsData;
  final Map<String, StationsData> _stationsData = {};
  
  
  List<Marker> _markers = [];
  final Set<String> _knownPositions = {};
  MapPosition _position = MapPosition(center: initialCenter);

  String _typeNotDisplayed = "docks";
  IconData _switchMarkerTypeIcon = BikeShare.dock;


  @override
  void initState() {
    super.initState();
    _systemsData = SystemsData(database: FirebaseDatabase.instance);
  }


  void initMapContent() {
    Timer(const Duration(seconds: 1), () {
      updateKnownPositions(_position, false);
    });
    Timer.periodic(const Duration(seconds: 30), (_) {
      updateMarkers();
    });
  }

  void updateKnownPositions(MapPosition position, bool _) {
    _position = position;
    double lat = double.parse(position.center!.latitude.toStringAsFixed(1));
    double lon = double.parse(position.center!.longitude.toStringAsFixed(1));

    String positionString = "$lat,$lon";
    if (_knownPositions.contains(positionString)) return;
    _knownPositions.add(positionString);

    var needToUpdateMarkers = false;
    for (var system in _systemsData.systems) {
      if (_stationsData.containsKey(system.id)) continue;
      if (!system.isInBounds(lat, lon)) continue;
      needToUpdateMarkers = true;
      _stationsData.putIfAbsent(
        system.id,
        () => StationsData(
          systemId: system.id,
          stationStatusUrl: system.stationStatusUrl,
          stationInformationUrl: system.stationInformationUrl,
        )
      );
    }

    if (needToUpdateMarkers) updateMarkers();
  }

  void updateMarkers() {
    for (var system in _systemsData.systems) {
      if (!system.isInBounds(_position.center!.latitude, _position.center!.longitude)) continue;
      var stationsDataOfSystem = _stationsData[system.id];
      stationsDataOfSystem?.getStationsInformation().then((stations) {
        for (var station in stations) {
          _markers.add(
            Marker(
              width: 35.0,
              height: 35.0,
              point: LatLng(station.lat, station.lon),
              child: Stack(
                children: [
                  const Icon(
                    BikeShare.marker_background,
                    color: Colors.white,
                    size: 35.0,
                  ),
                  Icon(
                    _typeNotDisplayed == "docks" ? stationsDataOfSystem.getStationIconFromBikesAvailability(system.id, station.id)
                      : stationsDataOfSystem.getStationIconFromDocksAvailability(system.id, station.id),
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
        });
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
      body: FlutterMap(
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: initialZoom,
          minZoom: minZoom,
          maxZoom: maxZoom,
          onMapReady: initMapContent,
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