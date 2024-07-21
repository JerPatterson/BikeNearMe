import 'dart:async';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:location/location.dart';
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

const markerUpdatesIntervallSeconds = 30;
const stationMarkerIconSize = 35.0;
const positionIconSize = 20.0;


class StationsMapPage extends StatefulWidget {
  const StationsMapPage({super.key});
  
  @override
  State<StationsMapPage> createState() => _StationsMapPageState();
}

class _StationsMapPageState extends State<StationsMapPage> {
  late final Systems _systems;
  final Map<String, StationsSystem> _stationsSystemByIds = {};
  
  final Set<String> _knownPositions = {};
  double _latitudeRounded = initialCenter.latitude;
  double _longitudeRounded = initialCenter.longitude;
  double _latitude = initialCenter.latitude;
  double _longitude = initialCenter.longitude;
  double _userLatitude = initialCenter.latitude;
  double _userLongitude = initialCenter.longitude;
  bool _userLocationProvided = false;

  List<Marker> _markers = [];
  List<StationsSystem> _stationsSystems = [];
  int _numberOfStations = 0;

  String _typeNotDisplayed = "docks";
  IconData _switchMarkerTypeIcon = BikeShare.dock;

  final MapController _mapController = MapController();


  @override
  void initState() {
    super.initState();
    initUserLocation();
  }


  void initUserLocation() async {
    var location = Location();
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    var permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _userLocationProvided = true;
    final currentLocation = await location.getLocation();
    _userLatitude = currentLocation.latitude!;
    _userLongitude = currentLocation.longitude!;
    _mapController.move(LatLng(_userLatitude, _userLongitude), initialZoom);
    location.onLocationChanged.listen((currentLocation) {
      _userLatitude = currentLocation.latitude!;
      _userLongitude = currentLocation.longitude!;
    });
  }

  void initMapRefresh() {
    Systems.create(FirebaseDatabase.instance).then((systems) {
      _systems = systems;
      updateKnownPositions(const MapPosition(center: initialCenter), false);
      Timer.periodic(const Duration(seconds: markerUpdatesIntervallSeconds), (_) {
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
      width: stationMarkerIconSize,
      height: stationMarkerIconSize,
      point: LatLng(lat, lon),
      child: Stack(
        children: [
          const Icon(
            BikeShare.marker_background,
            color: Colors.white,
            size: stationMarkerIconSize,
          ),
          Icon(
            icon,
            color: color,
            size: stationMarkerIconSize,
          ),
        ],
      ),
    );
  }

  void updateNbOfStations(int numberOfStations) {
    setState(() {
      _numberOfStations = numberOfStations;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(_userLatitude, _userLongitude),
                initialZoom: initialZoom,
                minZoom: minZoom,
                maxZoom: maxZoom,
                onMapReady: initMapRefresh,
                onPositionChanged: updateKnownPositions,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              mapController: _mapController,
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.circle,
                    size: positionIconSize + 4,
                    color: Colors.white
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.circle,
                    size: positionIconSize,
                    color: Color(0xFFB219B7)
                  ),
                ),
                MarkerLayer(
                  markers: !_userLocationProvided ? [] : [
                    Marker(
                      point: LatLng(_userLatitude, _userLongitude),
                      child: const Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.circle,
                            size: positionIconSize + 4,
                            color: Colors.white
                          ),
                          Icon(
                            Icons.circle,
                            size: positionIconSize,
                            color: Color(0xFF217DFC)
                          ),
                        ],
                      ),
                    ),
                  ],
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
          ]
        ),
        panelBuilder: (ScrollController sc) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: _numberOfStations == 0 ? 
                Colors.transparent : _stationsSystems.last.color,
            ),
            child: StationList(
              controller: sc,
              updateNbOfStations: updateNbOfStations,
              latitude: _latitude,
              longitude: _longitude,
              stationsSystems: _stationsSystems,
              showDockAvailability: _typeNotDisplayed == "bikes",
            ),
          );
        },
        maxHeight: min(_numberOfStations * 90.8 + 24, MediaQuery.of(context).size.height),
        minHeight: min(_numberOfStations * 90.8 + 24, MediaQuery.of(context).size.height * 0.35),
        renderPanelSheet: false,
        panelSnapping: false,
        parallaxEnabled: true,
        parallaxOffset: 0.75,
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
              _switchMarkerTypeIcon = Icons.pedal_bike;
              updateMarkers();
              break;
          }
        },
        tooltip: 'Display $_typeNotDisplayed instead',
        mini: true,
        child: Icon(_switchMarkerTypeIcon),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
    );
  }
}