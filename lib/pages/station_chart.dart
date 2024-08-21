import 'package:bike_near_me/entities/availibility.dart';
import 'package:bike_near_me/entities/day.dart';
import 'package:flutter/material.dart';

class StationChart extends StatefulWidget {
  const StationChart({
    super.key,
    required this.textColor,
    required this.color,
    required this.stationCapacity,
    required this.stationAvailability,
  });

  final Color textColor;
  final Color color;
  final int stationCapacity;
  final Map<String, Map<String, Availability>> stationAvailability;

  @override
  State<StationChart> createState() => _StationChartState();
}

class _StationChartState extends State<StationChart> {
  late List<Availability> _availabilities;
  late DayOfWeek _selectedDayOfWeek;
  final List<DayOfWeek> _daysOfWeek = [1, 2, 3, 4, 5, 6, 7].map((number) => DayOfWeek.create(number)).toList();


  @override
  void initState() {
    super.initState();
    _selectedDayOfWeek = DayOfWeek.create(DateTime.now().weekday);
    _availabilities = getStationAvailabilities();
  }

  List<Availability> getStationAvailabilities() {
    return List.generate(24, (index) =>
      widget.stationAvailability[_selectedDayOfWeek.name]?[index.toString()] ?? Availability(bikesAvailable: 0.0, docksAvailable: 0.0, electricBikesFromAvailable: 0.0)
    );
  }

  int getStationAverageAvailability() {
    return 100 * List.generate(24, (index) => index)
      .reduce((value, element) => 
        value + (widget.stationAvailability[_selectedDayOfWeek.name]?[element.toString()]?.bikesAvailable.toInt() ?? 0)
      ) ~/ (24 * widget.stationCapacity);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.white,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.4,
        ),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.ideographic,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "Disponibilité par heures",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black,
                fontSize: 32,
              ),
            ),
            Text(
              "Habituellement remplie à ${getStationAverageAvailability()}%",
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 32,
              ),
            ),
            Row(
              children: [
                for (var dayOfWeek in _daysOfWeek) 
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 8, 16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedDayOfWeek = dayOfWeek;
                            _availabilities = getStationAvailabilities();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: _selectedDayOfWeek.name == dayOfWeek.name ? widget.color : widget.textColor,
                        ),
                        child: Text(
                          dayOfWeek.letterAbbreviation,
                          style: TextStyle(
                            color: _selectedDayOfWeek.name == dayOfWeek.name ? widget.textColor : widget.color,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ),
                  ),
              ],
            ),
            Text(
              "Pleine (${widget.stationCapacity} vélos)",
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
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
                for (var availability in _availabilities) Container(
                  color: widget.color,
                  width: (MediaQuery.of(context).size.width - 36) / _availabilities.length.toDouble(),
                  height: MediaQuery.of(context).size.height * 0.3 * availability.bikesAvailable / widget.stationCapacity.toDouble(),
                ),
              ],
            )
          ],
        )
      ),
    );
  }
}