import 'package:bike_near_me/widgets/map.dart';
import 'package:flutter/material.dart';

enum Markers implements Comparable<Markers> {
  bikes(name: "bikes", otherName: "docks", icon: Icon(Icons.pedal_bike)),
  docks(name: "docks", otherName: "bikes", icon: Icon(Icons.local_parking));

  const Markers({
    required this.name,
    required this.otherName,
    required this.icon,
  });

  final String name;
  final String otherName;
  final Icon icon;

  @override
  int compareTo(Markers other) => name.compareTo(other.name);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;
  

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Markers _markersDisplayed = Markers.bikes;

  void _switchDisplayedMarkers() {
    setState(() {
      _markersDisplayed = _markersDisplayed == Markers.bikes ?
        Markers.docks : Markers.bikes;
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
        onPressed: _switchDisplayedMarkers,
        tooltip: 'Display ${_markersDisplayed.otherName} instead',
        child: _markersDisplayed.icon,
      ),
    );
  }
}