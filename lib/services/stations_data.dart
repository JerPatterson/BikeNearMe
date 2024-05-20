import 'dart:convert';
import 'package:bike_near_me/entities/station_status.dart';
import 'package:http/http.dart' as http;


class StationsData {
  StationsData({
    required this.stationStatusUrl,
    required this.stationInformationUrl,
  });

  final String stationStatusUrl;
  final String stationInformationUrl;


  Future<List<StationStatus>> getStationsStatus() async {
    var client = http.Client();
    var url = Uri.parse(stationStatusUrl);
    var response = await client.get(url);

    var test = _stationsStatusFromJson(json.decode(response.body)['data']['stations']);
    print(test);

    return test;
  }

  List<StationStatus> _stationsStatusFromJson(list) => List<StationStatus>.from(
    list.map((x) => StationStatus.fromJson(Map<String, dynamic>.from(x)))
  );
}