import 'package:flutter/material.dart';

class StationChart extends StatelessWidget {
  const StationChart({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.fromLTRB(16, 40, 8, 24),
      child: const Column(
        children: [
          Placeholder()
        ],
      )
    );
  }
}