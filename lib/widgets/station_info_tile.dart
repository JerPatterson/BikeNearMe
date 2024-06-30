import 'package:flutter/material.dart';

class StationInfoTile extends StatelessWidget {
  const StationInfoTile({
    super.key,
    required this.icon,
    required this.value,
    required this.valueName,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String valueName;
  final Color color;


  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.ideographic,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.black,
          size: 32,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              valueName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }
}