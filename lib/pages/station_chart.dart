import 'package:flutter/material.dart';

class StationChart extends StatefulWidget {
  const StationChart({super.key}); 

  @override
  State<StationChart> createState() => _StationChartState();
}

class _StationChartState extends State<StationChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.4,
      ),
      padding: const EdgeInsets.fromLTRB(16, 40, 8, 24),
      child: const Column(
        children: [
          Placeholder()
        ],
      )
    );
  }
}