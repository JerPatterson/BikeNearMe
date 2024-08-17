import 'package:flutter/material.dart';

class StationChart extends StatefulWidget {
  const StationChart({
    super.key,
    required this.textColor,
    required this.color,
  });

  final Color textColor;
  final Color color;

  @override
  State<StationChart> createState() => _StationChartState();
}

class _StationChartState extends State<StationChart> {
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
            Text(
              "Disponibilité par heures",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: widget.color,
                fontSize: 32,
              ),
            ),
            Text(
              "Habituellement rempli à 80%",
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: widget.color,
                fontSize: 32,
              ),
            ),
            Row(
              children: [
                for (var dayAbbreviation in ["D", "L", "M", "M", "J", "V", "S"]) 
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 8, 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                          
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: Text(
                          dayAbbreviation,
                          style: TextStyle(
                            color: widget.color,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ),
                  ),
              ],
            )
          ],
        )
      ),
    );
  }
}