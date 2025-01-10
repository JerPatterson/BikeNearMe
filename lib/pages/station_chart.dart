import 'dart:math';
import 'package:bike_near_me/entities/availibility.dart';
import 'package:bike_near_me/entities/day.dart';
import 'package:bike_near_me/icons/bike_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef UpdateShowDockAvailability = void Function(bool showDockAvailability);


class StationChart extends StatefulWidget {
  const StationChart({
    super.key,
    required this.textColor,
    required this.color,
    required this.stationCapacity,
    required this.stationAvailability,
    required this.showDockAvailability,
    required this.updateShowDockAvailability,
  });

  final Color textColor;
  final Color color;
  final int stationCapacity;
  final Map<String, Map<String, Availability>> stationAvailability;
  final bool showDockAvailability;
  final UpdateShowDockAvailability updateShowDockAvailability;

  @override
  State<StationChart> createState() => _StationChartState();
}

class _StationChartState extends State<StationChart> {
  late List<Availability> _availabilities;
  late DayOfWeek _selectedDayOfWeek;
  final List<DayOfWeek> _daysOfWeek = [1, 2, 3, 4, 5, 6, 7].map((number) => DayOfWeek.create(number)).toList();

  late String _typeNotDisplayed;
  late IconData _switchMarkerTypeIcon;
  late bool localShowDockAvailability;


  @override
  void initState() {
    super.initState();
    localShowDockAvailability = widget.showDockAvailability;
    if (localShowDockAvailability) {
      _typeNotDisplayed = "vélos";
      _switchMarkerTypeIcon = BikeShare.bike;
    } else {
      _typeNotDisplayed = "places";
      _switchMarkerTypeIcon = BikeShare.dock;
    }
  
    _selectedDayOfWeek = DayOfWeek.create(DateTime.now().weekday);
    _availabilities = getStationAvailabilities();
  }


  List<Availability> getStationAvailabilities() {
    return List.generate(24, (index) =>
      widget.stationAvailability[_selectedDayOfWeek.name]?["_${index.toString()}"] ?? Availability(bikesAvailable: 0.0, docksAvailable: 0.0, electricBikesFromAvailable: 0.0)
    );
  }

  int getStationAverageAvailability() {
    return 100 * List.generate(24, (index) => index)
      .reduce((value, element) => 
        value + (widget.stationAvailability[_selectedDayOfWeek.name]?["_${element.toString()}"]?.bikesAvailable.toInt() ?? 0)
      ) ~/ (24 * widget.stationCapacity);
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.4,
          ),
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.ideographic,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.bar_chart,
                color: widget.color,
                size: 36,
              ),
              const Text(
                "Disponibilité par heures",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                ),
              ),
              Row(
                children: [
                  Text(
                    localShowDockAvailability ?
                      "Habituellement libre à " :
                      "Habituellement remplie à ",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    "${localShowDockAvailability ?
                      100 - getStationAverageAvailability() :
                      getStationAverageAvailability()}%",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (DayOfWeek dayOfWeek in _daysOfWeek) 
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 18, 0, 16),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedDayOfWeek = dayOfWeek;
                            _availabilities = getStationAvailabilities();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          fixedSize: Size.square(
                            (MediaQuery.of(context).size.width - (_daysOfWeek.length * 5) - 36) / _daysOfWeek.length,
                          ),
                          shape: const CircleBorder(),
                          backgroundColor: _selectedDayOfWeek.name == dayOfWeek.name ?
                            widget.color : widget.textColor,
                        ),
                        child: Text(
                          dayOfWeek.letterAbbreviation,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedDayOfWeek.name == dayOfWeek.name ? 
                              widget.textColor : widget.color,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                "${widget.stationCapacity} vélos",
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: List.generate(500 ~/ 10, (index) => 
                  Expanded(
                    child: Container(
                      color: index % 2 == 0 ?Colors.grey : Colors.transparent,
                      height: 1,
                    ),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                  for (Availability availability in _availabilities) Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: widget.color,
                    ),
                    width: (MediaQuery.of(context).size.width - 36) / _availabilities.length,
                    height: min(
                      MediaQuery.of(context).size.height * 0.3,
                      localShowDockAvailability ?
                        MediaQuery.of(context).size.height * 0.3 * availability.docksAvailable / widget.stationCapacity :
                        MediaQuery.of(context).size.height * 0.3 * availability.bikesAvailable / widget.stationCapacity,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var tick in ["0:00", "8:00", "16:00", ""]) Text(
                    tick,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          )
        ),
      
        floatingActionButton: Column(
          spacing: 5.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              tooltip: 'Retourner à l\'information de la station',
              shape: const CircleBorder(),
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              splashColor: Colors.grey,
              mini: true,
              child: Text(
                String.fromCharCode(
                  Icons.close.codePoint,
                ),
                style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: Icons.close.fontFamily,
                  package: Icons.close.fontPackage,
                )
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                switch (_typeNotDisplayed) {
                  case "vélos":
                    _typeNotDisplayed = "places";
                    _switchMarkerTypeIcon = BikeShare.dock;
                    setState(() {
                      localShowDockAvailability = false;
                      widget.updateShowDockAvailability(localShowDockAvailability);
                    });
                  case "places":
                    _typeNotDisplayed = "vélos";
                    _switchMarkerTypeIcon = BikeShare.bike;
                    setState(() {
                      localShowDockAvailability = true;
                      widget.updateShowDockAvailability(localShowDockAvailability);
                    });
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
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }
}
