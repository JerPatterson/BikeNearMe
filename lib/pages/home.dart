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
  

  @override
  void initState() {
    super.initState();
    FirebaseDatabase database = FirebaseDatabase.instance;
    _systemsData = SystemsData(database: database);
  }


  void updateMarkers(MapPosition position, bool _) {
    double lat = double.parse(position.center!.latitude.toStringAsFixed(1));
    double lon = double.parse(position.center!.longitude.toStringAsFixed(1));

    String positionString = "$lat,$lon";
    if (_knownPositions.contains(positionString)) return;
    _knownPositions.add(positionString);

    for (var system in _systemsData.systems) {
      if (_stationsData.containsKey(system.id)) continue;
      if (system.isInBounds(lat, lon)) {
        _stationsData.putIfAbsent(
          system.id,
          () => StationsData(
            stationStatusUrl: system.stationStatusUrl,
            stationInformationUrl: system.stationInformationUrl,
          )
        );

        _stationsData[system.id]?.getStationsInformation().then((stations) {
          for (var station in stations) {
            _markers.add(
              Marker(
                width: 100.0,
                height: 100.0,
                point: LatLng(station.lat, station.lon),
                child: Stack(
                  children: [
                    const Icon(
                      BikeShare.marker_background,
                      color: Colors.white,
                      size: 35.0,
                    ),
                    Icon(
                      BikeShare.marker_bikes_100,
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
          onPositionChanged: updateMarkers,
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
        onPressed: () => {},
        tooltip: 'Display ${"bikes"} instead',
        child: const Icon(Icons.pedal_bike),
      ),
    );
  }
}