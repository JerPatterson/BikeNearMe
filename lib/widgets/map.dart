// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

const minZoom = 10.0;
const maxZoom = 20.0;
const initialZoom = 14.0;
const initialCenter = LatLng(45.504789, -73.613187);

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng _center = initialCenter;
  final List<Marker> _markers = [];
  final Set<String> _knownPositions = {};
  //final Set<String> _knownOperators = {};

  void updateMarkers(MapPosition position, bool _) {
    double latitude = double.parse(position.center!.latitude.toStringAsFixed(1));
    double longitude = double.parse(position.center!.longitude.toStringAsFixed(1));

    String positionString = "$latitude,$longitude";
    if (_knownPositions.contains(positionString)) return;
    
    setState(() {
      _knownPositions.add(positionString);
      _center = LatLng(latitude, longitude);
      _markers.add(
        Marker(
          width: 100.0,
          height: 100.0,
          point: _center,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 35.0,
          ),
        ),
      );
    }); 
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
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
    );
  }
}
