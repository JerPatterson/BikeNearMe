import 'dart:convert';
import 'package:bike_near_me/entities/station_information.dart';
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

    return _stationsStatusFromJson(json.decode(response.body)['data']['stations']);
  }

  Future<List<StationInformation>> getStationsInformation() async {
    var client = http.Client();
    var url = Uri.parse(stationInformationUrl);
    var response = await client.get(url);

    return _stationsInformationFromJson(json.decode(response.body)['data']['stations']);
  }

  List<StationStatus> _stationsStatusFromJson(list) => List<StationStatus>.from(
    list.map((x) => StationStatus.fromJson(Map<String, dynamic>.from(x)))
  );

  List<StationInformation> _stationsInformationFromJson(list) => List<StationInformation>.from(
    list.map((x) => StationInformation.fromJson(Map<String, dynamic>.from(x)))
  );
}