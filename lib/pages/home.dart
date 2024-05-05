import 'package:bike_near_me/widgets/map.dart';
import 'package:flutter/material.dart';

enum MarkerType implements Comparable<MarkerType> {
  bikes(name: "bikes", otherName: "docks", icon: Icon(Icons.pedal_bike)),
  docks(name: "docks", otherName: "bikes", icon: Icon(Icons.local_parking));

  const MarkerType({
    required this.name,
    required this.otherName,
    required this.icon,
  });

  final String name;
  final String otherName;
  final Icon icon;

  @override
  int compareTo(MarkerType other) => name.compareTo(other.name);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MarkerType _markerTypeDisplayed = MarkerType.bikes;

  void _switchDisplayedMarkerType() {
    setState(() {
      _markerTypeDisplayed = _markerTypeDisplayed == MarkerType.bikes ?
        MarkerType.docks : MarkerType.bikes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const MapWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: _switchDisplayedMarkerType,
        tooltip: 'Display ${_markerTypeDisplayed.otherName} instead',
        child: _markerTypeDisplayed.icon,
      ),
    );
  }
}