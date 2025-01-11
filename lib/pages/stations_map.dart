import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bike_near_me/entities/availibility.dart';
import 'package:bike_near_me/pages/search_place.dart';
import 'package:bike_near_me/pages/station_info.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

const minZoom = 8.0;
const maxZoom = 20.0;
const minOffset = 0.00000001;
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
  final Set<String> _inBoundsStationsSystems = {};
  final Map<String, StationsSystem> _stationsSystemByIds = {};
  
  
  final Set<String> _knownPositions = {};
  double _latitudeRounded = initialCenter.latitude;
  double _longitudeRounded = initialCenter.longitude;
  double _latitude = initialCenter.latitude;
  double _longitude = initialCenter.longitude;
  double _userLatitude = initialCenter.latitude;
  double _userLongitude = initialCenter.longitude;
  bool _userLocationProvided = false;
  late SharedPreferences prefs;

  List<Marker> _markers = [];
  List<StationsSystem> _stationsSystems = [];
  String _mapLocationText = "2500 Chem. de Polytechnique, Montréal, QC";
  bool _mapAtUserLocation = false;
  int _numberOfStations = 0;

  String _typeNotDisplayed = "places";
  IconData _switchMarkerTypeIcon = BikeShare.dock;
  Color _navigationBarColor = Colors.transparent;
  SystemUiOverlayStyle _statusBarStyle = SystemUiOverlayStyle.dark;

  Timer? _positionChangedCallbackTimer;
  final MapController _mapController = MapController();


  @override
  void initState() {
    super.initState();
    initLocation();
    initUserLocation();
  }


  void initLocation() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("latitude") && prefs.containsKey("longitude")) {
      _latitude = prefs.getDouble("latitude")!;
      _longitude = prefs.getDouble("longitude")!;
      _mapController.move(LatLng(_latitude, _longitude), initialZoom);
    } else {
      _latitude = initialCenter.latitude;
      _longitude = initialCenter.longitude;
    }
  }

  void initUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _userLocationProvided = true;
    final currentLocation = await Geolocator.getCurrentPosition();
    _userLatitude = currentLocation.latitude;
    _userLongitude = currentLocation.longitude;
    _mapController.move(LatLng(_userLatitude, _userLongitude), initialZoom);
    _mapAtUserLocation = true;

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position) {
      setState(() {
        if (position == null) return;
        _userLatitude = position.latitude;
        _userLongitude = position.longitude;
      });
    });
  }

  void initMapRefresh() {
    Systems.create(FirebaseDatabase.instance).then((systems) {
      _systems = systems;
      updateMapWithPosition(
        MapCamera(
          crs: Epsg3857(),
          center: _mapController.camera.center,
          zoom: initialZoom,
          rotation: 0.0,
          nonRotatedSize: Point(0.0, 0.0)
        ), 
        false
      );
      Timer.periodic(const Duration(seconds: markerUpdatesIntervallSeconds), (_) {
        updateMarkers();
      });
    });
    
  }


  void updateMapWithPosition(MapCamera position, bool _) {
    _positionChangedCallbackTimer?.cancel();
    _mapAtUserLocation = false;
    _mapLocationText = "Recherche...";

      _positionChangedCallbackTimer = Timer(Duration(milliseconds: 600), () {
        bool triggerUpdateMarkers = false;

        setState(() {
          _latitude = position.center.latitude;
          _longitude = position.center.longitude;
        });
        updateMapLocationText();
        prefs.setDouble("latitude", _latitude);
        prefs.setDouble("longitude", _longitude);

        _latitudeRounded = double.parse(_latitude.toStringAsFixed(1));
        _longitudeRounded = double.parse(_longitude.toStringAsFixed(1));
        if (_isKnownPosition(_latitudeRounded, _longitudeRounded) ) {
          double offset = minOffset * pow(2, _mapController.camera.zoom);
          if (_userLatitude - offset <= _latitude && _userLatitude + offset >= _latitude
              && _userLongitude - offset <= _longitude && _userLongitude + offset >= _longitude) {
            _mapController.move(LatLng(_userLatitude, _userLongitude), _mapController.camera.zoom);
            _mapAtUserLocation = true;
          }
          return;
        }

        List<Future<StationsSystem>> futureStationsSystems = [];
        for (System system in _systems.systems) {
          if (!_wasInBoundsStationsSystem(system.id) && system.isInBounds(_latitudeRounded, _longitudeRounded)) {
            triggerUpdateMarkers = true;
            _inBoundsStationsSystems.add(system.id);
            if (_isUnknownStationsSystem(system.id)) {
              futureStationsSystems.add(
                StationsSystem.create(system, _systems.getSystemAvailabilityById(system.id))
              );
            }
          } else if (!system.isInBounds(_latitudeRounded, _longitudeRounded)) {
            triggerUpdateMarkers = true;
            _inBoundsStationsSystems.remove(system.id);
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

          if (triggerUpdateMarkers) {
            updateMarkers();
          }
        });
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

  bool _wasInBoundsStationsSystem(String id) {
    return _inBoundsStationsSystems.contains(id);
  }

  void updateMarkers() {
    _markers.clear();
    _stationsSystems.clear();

    for (System system in _systems.systems) {
      StationsSystem? stationsSystem = _stationsSystemByIds[system.id];
      if (stationsSystem == null || !system.isInBounds(_latitude, _longitude)) continue;
      _stationsSystems.add(stationsSystem);

      for (StationInformation stationInformation in stationsSystem.getStationsInformation()) {
        _markers.add(_createMarker(stationInformation, stationsSystem));
      }

      setState(() {
        _markers = _markers;
        _stationsSystems = _stationsSystems;
      });
    }
  }

  Future<void> onMarkerTap(StationInformation stationInformation, StationsSystem stationsSystem) async {
    final navigator = Navigator.of(context);
    final showDockAvailability = _typeNotDisplayed == "vélos";
    Map<String, Map<String, Availability>>? availabilityHistory = await stationsSystem.getStationAvailabilityHistory(stationInformation.id);
    if (!context.mounted) return;
    navigator.push(
      MaterialPageRoute(
        builder: (context) => StationInfoPage(
          stationInformation: stationInformation,
          stationStatus: stationsSystem.getStationStatusById(stationInformation.id)!,
          stationAvailability: availabilityHistory,
          markerIcon: stationsSystem.getStationAvailabilityIcon(stationInformation.id, showDockAvailability),
          updateMarkerIcon: (bool showDockAvailability) => stationsSystem.getStationAvailabilityIcon(stationInformation.id, showDockAvailability),
          textColor: stationsSystem.textColor,
          color: stationsSystem.color,
          showDockAvailability: showDockAvailability,
        ),
      ),
    );
  }

  Marker _createMarker(StationInformation stationInformation, StationsSystem stationsSystem) {
    return Marker(
      width: stationMarkerIconSize,
      height: stationMarkerIconSize,
      point: LatLng(stationInformation.lat, stationInformation.lon),
      child: GestureDetector(
        onTap: () => {
          onMarkerTap(stationInformation, stationsSystem)
        },
        child: Stack(
          children: [
            const Icon(
              BikeShare.marker_background,
              color: Colors.white,
              size: stationMarkerIconSize,
            ),
            Icon(
              stationsSystem.getStationAvailabilityIcon(
                stationInformation.id,
                _typeNotDisplayed == "vélos",
              ),
              color: (
                _typeNotDisplayed == "vélos" && stationsSystem.isReturning(stationInformation.id) 
                  || _typeNotDisplayed == "places" && stationsSystem.isRenting(stationInformation.id) 
                    ? stationsSystem.color : Colors.grey
              ),
              size: stationMarkerIconSize,
            ),
          ],
        ),
      ),
    );
  }

  void updateMapLocationText() async {
    try {
      var url = Uri.parse("https://nominatim.openstreetmap.org/reverse?format=json&lat=$_latitude&lon=$_longitude&zoom=18&addressdetails=1");
      var res = await http.get(url);
      Map<String, dynamic> json = jsonDecode(res.body);
      if (json.containsKey("display_name")) {
        setState(() {
          _mapLocationText = json["display_name"];
        });
      }
    } catch (_) {
      return;
    }
  }

  void updateNbOfStations(int numberOfStations, Color lastColor) {
    setState(() {
      _numberOfStations = numberOfStations;
      _navigationBarColor = lastColor;
    });
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: _statusBarStyle,
      child: Scaffold(
        body: SlidingUpPanel(
          onPanelSlide: (position) {
            setState(() {
              if (position == 1.0 && _numberOfStations * 90.8 + 200 >= MediaQuery.of(context).size.height) {
                _statusBarStyle = SystemUiOverlayStyle.light;
              } else {
                _statusBarStyle = SystemUiOverlayStyle.dark;
              }
            });
          },
          body: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(_userLatitude, _userLongitude),
                  initialZoom: initialZoom,
                  minZoom: minZoom,
                  maxZoom: maxZoom,
                  onMapReady: initMapRefresh,
                  onPositionChanged: updateMapWithPosition,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                mapController: _mapController,
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                    retinaMode: RetinaMode.isHighDensity(context),
                    subdomains: ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.app',
                    tileProvider: CancellableNetworkTileProvider(),
                  ),
                  MarkerLayer(
                    markers: [for (int i = 0; i < _markers.length; i++) _markers[i]],
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
                ],
              ),
            ]
          ),
      
          panelBuilder: (ScrollController sc) {
            return SingleChildScrollView(
              controller: sc,
              child: Column(
                children: [
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                      ),
                      TextSourceAttribution(
                        'CARTO',
                        onTap: () => launchUrl(Uri.parse('https://carto.com/attributions')),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 52.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _numberOfStations == 0 ? 
                              Colors.transparent : _navigationBarColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: StationList(
                              updateNbOfStations: updateNbOfStations,
                              latitude: _latitude,
                              longitude: _longitude,
                              stationsSystems: _stationsSystems,
                              showDockAvailability: _typeNotDisplayed == "vélos",
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 60.0,
                        padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                        margin: const EdgeInsets.only(left: 24.0, right: 24.0),
                        decoration: BoxDecoration(
                          color: _mapAtUserLocation ? Colors.black : Color(0xFFB219B7),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              if (_userLocationProvided && !_mapAtUserLocation) InkWell(
                                  onTap: () {
                                    _mapController.move(LatLng(_userLatitude, _userLongitude), initialZoom);
                                  },
                                  child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Icon(
                                    Icons.my_location,
                                    size: 30.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (!_userLocationProvided || _mapAtUserLocation) InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => SearchPlacePage(
                                        latitude: _latitude,
                                        longitude: _longitude,
                                        systems: _systems.systems,
                                      ),
                                    ),
                                  ).then((placeItem) {
                                    if (placeItem != null) {
                                      _mapController.move(LatLng(placeItem.latitude, placeItem.longitude), initialZoom);
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Icon(
                                    Icons.search,
                                    size: 30.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                width: 21.0,
                                color: Color(0x40FFFFFF),
                                thickness: 1.0,
                                indent: 4.0,
                                endIndent: 4.0,
                              ),
                              Flexible(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => SearchPlacePage(
                                          latitude: _latitude,
                                          longitude: _longitude,
                                          systems: _systems.systems,
                                        ),
                                      ),
                                    ).then((placeItem) {
                                      if (placeItem != null) {
                                        _mapController.move(LatLng(placeItem.latitude, placeItem.longitude), initialZoom);
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Stations près de",
                                          style: TextStyle(
                                            height: 1.1,
                                            color: Colors.white,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        Text(
                                          _mapLocationText,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            height: 1.1,
                                            color: _mapLocationText == "Recherche..." ? Color(0xC0FFFFFF) : Colors.white,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          maxHeight: min(_numberOfStations * 90.8 + 200, MediaQuery.of(context).size.height),
          minHeight: min(_numberOfStations * 90.8 + 200, MediaQuery.of(context).size.height * 0.35),
          renderPanelSheet: false,
          panelSnapping: false,
          parallaxEnabled: true,
          parallaxOffset: 0.75,
        ),
      
        floatingActionButton: Column(
          spacing: 5.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            FloatingActionButton(
              onPressed: () {
                switch (_typeNotDisplayed) {
                  case "vélos":
                    _typeNotDisplayed = "places";
                    _switchMarkerTypeIcon = BikeShare.dock;
                    updateMarkers();
                  case "places":
                    _typeNotDisplayed = "vélos";
                    _switchMarkerTypeIcon = BikeShare.bike;
                    updateMarkers();
                    break;
                }
              },
              tooltip: 'Montrer plutôt les $_typeNotDisplayed',
              shape: const CircleBorder(),
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              splashColor: Colors.grey,
              mini: true,
              child: Text(
                String.fromCharCode(
                  _switchMarkerTypeIcon.codePoint,
                ),
                style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: _switchMarkerTypeIcon.fontFamily,
                  package: _switchMarkerTypeIcon.fontPackage,
                )
              ),
            ),
            if (_userLocationProvided && _userLatitude != _latitude && _userLongitude != _longitude) FloatingActionButton(
              onPressed: () {
                _mapController.move(LatLng(_userLatitude, _userLongitude), initialZoom);
              },
              tooltip: 'Retourner à ma position',
              shape: const CircleBorder(),
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              splashColor: Colors.grey,
              mini: true,
              child: Text(
                String.fromCharCode(
                  Icons.my_location.codePoint,
                ),
                style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: Icons.my_location.fontFamily,
                  package: Icons.my_location.fontPackage,
                )
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }
}
